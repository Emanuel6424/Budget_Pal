package budgetpal.budget;

import java.time.LocalDate;
import java.util.*;

import org.springframework.stereotype.Service;

import budgetpal.budget.BudgetController.BudgetResponse;
import budgetpal.transaction.TransactionRepository;
import budgetpal.transaction.TransactionType;
import budgetpal.user.UserRepository;
import budgetpal.transaction.Transaction;

@Service
public class BudgetService {
    private final BudgetRepository budgetRepository;
    private final TransactionRepository transactionRepository;

    public BudgetService(BudgetRepository budgetRepository, UserRepository userRepository,
            TransactionRepository transactionRepsitory) {
        this.budgetRepository = budgetRepository;
        this.transactionRepository = transactionRepsitory;
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

    public double getCurrentSpending(Budget budget) {
        // Find all transactions for this cugdte's cateogir within the date range
        List<Transaction> relevantTransactions = transactionRepository.findByUserIdAndCategoryIdAndDateBetween(
                budget.getUser().getId(), budget.getCategory().getId(), budget.getStartDate(), budget.getEndDate());

        return relevantTransactions.stream().filter(t -> t.getType() == TransactionType.EXPENSE)
                .mapToDouble(Transaction::getAmount).sum();
    }

    public BudgetStatus getBudgetStatus(Integer budgetId) {
        Budget budget = findById(budgetId)
                .orElseThrow(() -> new IllegalArgumentException("Budget not found"));

        double spent = getCurrentSpending(budget);
        double remaining = budget.getLimitAmount() - spent;
        double percentUsed = (spent / budget.getLimitAmount()) * 100;

        return new BudgetStatus(
                budget.getId(),
                budget.getName(),
                budget.getLimitAmount(),
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

    public record BudgetStatus(
            Integer id,
            String name,
            double limit,
            double spent,
            double remaining,
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
