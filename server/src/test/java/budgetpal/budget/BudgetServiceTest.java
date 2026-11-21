package budgetpal.budget;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;

import budgetpal.category.Category;
import budgetpal.notification.Notification;
import budgetpal.notification.NotificationRepository;
import budgetpal.notification.NotificationService;
import budgetpal.transaction.TransactionRepository;
import budgetpal.user.User;
import budgetpal.user.UserRepository;

@ExtendWith(MockitoExtension.class)
class BudgetServiceTest {

    @Mock
    private BudgetRepository budgetRepository;
    @Mock
    private UserRepository userRepository;
    @Mock
    private TransactionRepository transactionRepository;
    // Real NotificationService backed by a mocked repository, rather than mocking
    // NotificationService itself - it's a concrete class, and this also exercises
    // the real underspend/no-duplicate logic end to end.
    @Mock
    private NotificationRepository notificationRepository;
    private NotificationService notificationService;

    private BudgetService budgetService;
    private User user;
    private Category category;

    @BeforeEach
    void setUp() {
        notificationService = new NotificationService(notificationRepository);
        budgetService = new BudgetService(budgetRepository, userRepository, transactionRepository,
                notificationService);

        user = new User();
        user.setId(1);
        category = new Category();
        category.setId(2);

        // No transactions by default -> full amount saved. lenient() because not every
        // test exercises a path that reaches these calls (e.g. the already-current case).
        Mockito.lenient().when(transactionRepository.findByUserIdAndCategoryIdAndDateBetween(any(), any(), any(), any()))
                .thenReturn(Collections.emptyList());
        Mockito.lenient().when(budgetRepository.save(any(Budget.class))).thenAnswer(invocation -> invocation.getArgument(0));
    }

    private Budget expiredMonthlyBudget(LocalDate startDate, LocalDate endDate) {
        Budget budget = new Budget("Groceries", 100.0, BudgetPeriod.MONTHLY, startDate, endDate, user, category);
        return budget;
    }

    @Test
    void renewUntilCurrent_singlePeriod_deactivatesOldAndCreatesNewWithSameLimit() {
        LocalDate today = LocalDate.of(2026, 2, 1);
        Budget old = expiredMonthlyBudget(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 31));

        budgetService.renewUntilCurrent(old, today);

        ArgumentCaptor<Budget> captor = ArgumentCaptor.forClass(Budget.class);
        verify(budgetRepository, times(2)).save(captor.capture());

        Budget savedOld = captor.getAllValues().get(0);
        Budget savedNew = captor.getAllValues().get(1);

        assertFalse(savedOld.isActive());
        assertEquals(LocalDate.of(2026, 1, 1), savedOld.getStartDate());
        assertEquals(LocalDate.of(2026, 1, 31), savedOld.getEndDate());

        assertEquals(100.0, savedNew.getLimitAmount());
        assertEquals(LocalDate.of(2026, 2, 1), savedNew.getStartDate());
        assertEquals(LocalDate.of(2026, 2, 28), savedNew.getEndDate());
        assertEquals(BudgetPeriod.MONTHLY, savedNew.getPeriod());
    }

    @Test
    void renewUntilCurrent_multiPeriodCatchUp_createsEveryMissedPeriodUntilNewestContainsToday() {
        LocalDate today = LocalDate.of(2026, 5, 15);
        // Ended Jan 31, today is May 15 -> Feb, Mar, Apr and May periods have all
        // already started/elapsed, so four periods need to be caught up.
        Budget old = expiredMonthlyBudget(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 31));

        budgetService.renewUntilCurrent(old, today);

        ArgumentCaptor<Budget> captor = ArgumentCaptor.forClass(Budget.class);
        verify(budgetRepository, times(8)).save(captor.capture()); // 4 deactivated + 4 created

        Budget newest = captor.getAllValues().get(captor.getAllValues().size() - 1);
        assertFalse(today.isAfter(newest.getEndDate()));
        assertFalse(newest.getStartDate().isAfter(today));
        assertEquals(LocalDate.of(2026, 5, 1), newest.getStartDate());
        assertEquals(LocalDate.of(2026, 5, 31), newest.getEndDate());
        assertEquals(100.0, newest.getLimitAmount());
    }

    @Test
    void renewUntilCurrent_alreadyCurrent_doesNothing() {
        LocalDate today = LocalDate.of(2026, 1, 15);
        Budget current = expiredMonthlyBudget(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 31));

        budgetService.renewUntilCurrent(current, today);

        verify(budgetRepository, never()).save(any());
        verify(notificationRepository, never()).save(any());
    }

    @Test
    void renewUntilCurrent_underspent_createsNotification() {
        LocalDate today = LocalDate.of(2026, 2, 1);
        Budget old = expiredMonthlyBudget(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 31));
        // No transactions recorded -> saved = 100 - 0 = 100 > 0.

        budgetService.renewUntilCurrent(old, today);

        ArgumentCaptor<Notification> captor = ArgumentCaptor.forClass(Notification.class);
        verify(notificationRepository, times(1)).save(captor.capture());
        assertEquals(user, captor.getValue().getUser());
        assertEquals(old, captor.getValue().getBudget());
    }

    @Test
    void renewUntilCurrent_notificationAlreadyExists_doesNotDuplicate() {
        LocalDate today = LocalDate.of(2026, 2, 1);
        Budget old = expiredMonthlyBudget(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 31));
        old.setId(7);
        // Simulates a prior run of this same period's renewal having already recorded the notification.
        when(notificationRepository.findByBudgetIdAndType(7, budgetpal.notification.NotificationType.BUDGET_UNDERSPENT))
                .thenReturn(Optional.of(
                        new Notification(user, old, budgetpal.notification.NotificationType.BUDGET_UNDERSPENT, "t",
                                "b")));

        budgetService.renewUntilCurrent(old, today);

        verify(notificationRepository, never()).save(any());
    }

    @Test
    void renewUntilCurrent_overspent_createsNoNotification() {
        LocalDate today = LocalDate.of(2026, 3, 1);
        Budget old = expiredMonthlyBudget(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 31));

        budgetpal.transaction.Transaction expense = new budgetpal.transaction.Transaction(
                user, null, LocalDate.of(2026, 1, 15), "over", "store", 150.0,
                budgetpal.transaction.TransactionType.EXPENSE, category);
        when(transactionRepository.findByUserIdAndCategoryIdAndDateBetween(any(), any(), any(), any()))
                .thenReturn(List.of(expense));

        budgetService.renewUntilCurrent(old, today);

        verify(notificationRepository, never()).save(any());
    }

    @Test
    void renewUntilCurrent_exactlyAtLimit_createsNoNotification() {
        LocalDate today = LocalDate.of(2026, 3, 1);
        Budget old = expiredMonthlyBudget(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 31));

        budgetpal.transaction.Transaction expense = new budgetpal.transaction.Transaction(
                user, null, LocalDate.of(2026, 1, 15), "exact", "store", 100.0,
                budgetpal.transaction.TransactionType.EXPENSE, category);
        when(transactionRepository.findByUserIdAndCategoryIdAndDateBetween(any(), any(), any(), any()))
                .thenReturn(List.of(expense));

        budgetService.renewUntilCurrent(old, today);

        verify(notificationRepository, never()).save(any());
    }

    @Test
    void getBudgetStatus_zeroLimit_doesNotDivideByZero() {
        Budget budget = new Budget("Misc", 0.0, BudgetPeriod.MONTHLY, LocalDate.of(2026, 1, 1),
                LocalDate.of(2026, 1, 31), user, category);
        budget.setId(5);
        when(budgetRepository.findById(5)).thenReturn(java.util.Optional.of(budget));

        BudgetService.BudgetStatus status = budgetService.getBudgetStatus(5);

        assertEquals(0.0, status.percentUsed());
    }
}
