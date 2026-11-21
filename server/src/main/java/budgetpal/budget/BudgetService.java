package budgetpal.budget;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.*;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import budgetpal.budget.BudgetController.BudgetResponse;
import budgetpal.notification.NotificationService;
import budgetpal.transaction.TransactionRepository;
import budgetpal.transaction.TransactionType;
import budgetpal.user.UserRepository;
import budgetpal.transaction.Transaction;

@Service
public class BudgetService {
    private final BudgetRepository budgetRepository;
    private final TransactionRepository transactionRepository;
    private final NotificationService notificationService;

    public BudgetService(BudgetRepository budgetRepository, UserRepository userRepository,
            TransactionRepository transactionRepsitory, NotificationService notificationService) {
        this.budgetRepository = budgetRepository;
        this.transactionRepository = transactionRepsitory;
        this.notificationService = notificationService;
    }

    public Budget save(Budget b) {
        return budgetRepository.save(b);
    }

    public void delete(Budget b) {
        budgetRepository.delete(b);
    }

    public Optional<Budget> findById(Integer id) {
        return budgetRepository.findById(id);
    }

    public BigDecimal getCurrentSpending(Budget budget) {
        // Find all transactions for this cugdte's cateogir within the date range
        List<Transaction> relevantTransactions = transactionRepository.findByUserIdAndCategoryIdAndDateBetween(
                budget.getUser().getId(), budget.getCategory().getId(), budget.getStartDate(), budget.getEndDate());

        return relevantTransactions.stream().filter(t -> t.getType() == TransactionType.EXPENSE)
                .map(t -> BigDecimal.valueOf(t.getAmount()))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public BudgetStatus getBudgetStatus(Integer budgetId) {
        Budget budget = findById(budgetId)
                .orElseThrow(() -> new IllegalArgumentException("Budget not found"));

        BigDecimal limitAmount = BigDecimal.valueOf(budget.getLimitAmount());
        BigDecimal spent = getCurrentSpending(budget);
        BigDecimal remaining = limitAmount.subtract(spent);
        double percentUsed = limitAmount.signum() == 0 ? 0
                : spent.divide(limitAmount, 4, RoundingMode.HALF_UP).doubleValue() * 100;

        return new BudgetStatus(
                budget.getId(),
                budget.getName(),
                limitAmount,
                spent,
                remaining,
                percentUsed,
                budget.getStartDate(),
                budget.getEndDate());
    }

    public List<Budget> getCurrentBudgets(Integer userId){
        LocalDate today = LocalDate.now();
        return budgetRepository.findByUserIdAndIsActiveTrueAndStartDateLessThanEqualAndEndDateGreaterThanEqual(userId, today, today);
    }

    /**
     * Amount under (positive) or over (negative/zero) the limit for a closed budget.
     * Computed on demand - never stored on the Budget row.
     */
    public BigDecimal getSaved(Budget budget) {
        return BigDecimal.valueOf(budget.getLimitAmount()).subtract(getCurrentSpending(budget));
    }

    public List<Budget> findBudgetsDueForRenewal(LocalDate today) {
        return budgetRepository.findByIsActiveTrueAndEndDateLessThan(today);
    }

    /**
     * Renews a single expired budget, repeating as many periods as needed to catch
     * up to today (e.g. if the server was down for a while). Always resets to the
     * base limit - no rollover. Each closed period that was underspent gets a
     * BUDGET_UNDERSPENT notification. Safe to re-run: once the newest period
     * contains today, findBudgetsDueForRenewal no longer returns this chain.
     */
    @Transactional
    public void renewUntilCurrent(Budget expiredBudget, LocalDate today) {
        Budget current = expiredBudget;

        while (current.getEndDate().isBefore(today)) {
            BigDecimal saved = getSaved(current);
            current.setActive(false);
            budgetRepository.save(current);

            if (saved.signum() > 0)
                notificationService.createUnderspentNotificationIfAbsent(current.getUser(), current,
                        saved.doubleValue());

            LocalDate nextStart = current.getEndDate().plusDays(1);
            LocalDate nextEnd = current.getPeriod().endDateFrom(nextStart);

            Budget next = new Budget(
                    current.getName(),
                    current.getLimitAmount(),
                    current.getPeriod(),
                    nextStart,
                    nextEnd,
                    current.getUser(),
                    current.getCategory());
            budgetRepository.save(next);

            current = next;
        }
    }

    public List<BudgetHistoryEntry> getBudgetHistory(Integer userId) {
        return budgetRepository.findByUserIdAndIsActiveFalse(userId).stream()
                .map(b -> new BudgetHistoryEntry(
                        b.getId(),
                        b.getName(),
                        BigDecimal.valueOf(b.getLimitAmount()),
                        b.getPeriod(),
                        b.getStartDate(),
                        b.getEndDate(),
                        getCurrentSpending(b),
                        getSaved(b),
                        b.getCategoryId()))
                .toList();
    }

    public record BudgetHistoryEntry(
            Integer id,
            String name,
            BigDecimal limitAmount,
            BudgetPeriod period,
            LocalDate startDate,
            LocalDate endDate,
            BigDecimal spent,
            BigDecimal saved,
            Integer categoryId) {
    }

    public record BudgetStatus(
            Integer id,
            String name,
            BigDecimal limit,
            BigDecimal spent,
            BigDecimal remaining,
            double percentUsed,
            LocalDate startDate,
            LocalDate endDate) {
    }

    public BudgetResponse toBudgetReponseBuilder(Budget b) {
        return new BudgetResponse(
                b.getId(),
                b.getName(),
                b.getLimitAmount(),
                b.getPeriod(),
                b.getStartDate(),
                b.getEndDate(),
                b.isActive(),
                b.getUser().getId(),
                b.getCategory().getId());
    }
}
