package budgetpal.notification;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import budgetpal.budget.Budget;
import budgetpal.user.User;

@ExtendWith(MockitoExtension.class)
class NotificationServiceTest {

    @Mock
    private NotificationRepository notificationRepository;

    private NotificationService notificationService;
    private User owner;
    private Budget budget;

    @BeforeEach
    void setUp() {
        notificationService = new NotificationService(notificationRepository);
        owner = new User();
        owner.setId(1);
        budget = new Budget();
        budget.setId(10);
    }

    @Test
    void createUnderspentNotificationIfAbsent_noneExists_createsOne() {
        when(notificationRepository.findByBudgetIdAndType(10, NotificationType.BUDGET_UNDERSPENT))
                .thenReturn(Optional.empty());

        notificationService.createUnderspentNotificationIfAbsent(owner, budget, 42.50);

        verify(notificationRepository, times(1)).save(any(Notification.class));
    }

    @Test
    void createUnderspentNotificationIfAbsent_alreadyExists_doesNotDuplicate() {
        Notification existing = new Notification(owner, budget, NotificationType.BUDGET_UNDERSPENT, "t", "b");
        when(notificationRepository.findByBudgetIdAndType(10, NotificationType.BUDGET_UNDERSPENT))
                .thenReturn(Optional.of(existing));

        notificationService.createUnderspentNotificationIfAbsent(owner, budget, 42.50);

        verify(notificationRepository, never()).save(any(Notification.class));
    }

    @Test
    void markRead_ownerMatches_setsReadAt() {
        Notification notification = new Notification(owner, budget, NotificationType.BUDGET_UNDERSPENT, "t", "b");
        notification.setId(99);
        when(notificationRepository.findById(99)).thenReturn(Optional.of(notification));
        when(notificationRepository.save(any(Notification.class))).thenAnswer(inv -> inv.getArgument(0));

        Notification result = notificationService.markRead(99, 1);

        assertNotNull(result.getReadAt());
    }

    @Test
    void markRead_differentUser_isDenied() {
        Notification notification = new Notification(owner, budget, NotificationType.BUDGET_UNDERSPENT, "t", "b");
        notification.setId(99);
        when(notificationRepository.findById(99)).thenReturn(Optional.of(notification));

        assertThrows(SecurityException.class, () -> notificationService.markRead(99, 2));
        verify(notificationRepository, never()).save(any(Notification.class));
    }
}
