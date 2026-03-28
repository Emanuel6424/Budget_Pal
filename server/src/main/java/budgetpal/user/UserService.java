package budgetpal.user;

import java.time.LocalDate;
import java.util.*;

import org.springframework.stereotype.Service;

import budgetpal.budget.Budget;
import budgetpal.budget.BudgetService;
import budgetpal.transaction.TransactionService;
import budgetpal.user.UserController.UserResponse;
import budgetpal.transaction.Transaction;
import budgetpal.transaction.TransactionController;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final BudgetService budgetService;
    private final TransactionService transactionService;

    public UserService(UserRepository userRepository, BudgetService budgetService,
            TransactionService transactionService) {
        this.userRepository = userRepository;
        this.budgetService = budgetService;
        this.transactionService = transactionService;
    }

    public User save(User u) {
        return userRepository.save(u);
    }

    public void delete(User u) {
        userRepository.delete(u);
    }

    public Optional<User> findById(Integer id) {
        return userRepository.findById(id);
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public List<User> findAll() {
        List<User> users = new ArrayList<>();
        userRepository.findAll().forEach((s) -> users.add(s));
        return users;
    }

    public UserResponse toUserReponseBuilder(User u) {

        List<Budget> currBudgets = budgetService.getCurrentBudgets(u.getId());
        List<Transaction> recentTransactions = transactionService.getTransactionsByPeriod(u.getId(), "month");

         List<TransactionController.TransactionResponse> transactionResponses = recentTransactions.stream()
        .map(transactionService::toTransactionResponseBuilder)
        .toList();

        return new UserResponse(
                u.getId(),
                u.getFirstName(),
                u.getLastName(),
                u.getEmail(),
                u.getAccounts(),
                currBudgets,
                transactionResponses,
                u.getCreatedAt(),
                u.getUpdatedAt());
    }
}
