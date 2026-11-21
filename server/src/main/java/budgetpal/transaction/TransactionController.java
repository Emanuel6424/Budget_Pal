package budgetpal.transaction;

import java.time.LocalDate;
import java.util.List;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import budgetpal.account.Account;
import budgetpal.account.AccountService;
import budgetpal.category.Category;
import budgetpal.category.CategoryRepository; // Add this import
import budgetpal.user.User;
import budgetpal.user.UserService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.DeleteMapping;

@RestController
@RequestMapping("/api/transaction")
public class TransactionController {
        private final TransactionService transactionService;
        private final UserService userService;
        private final AccountService accountService;
        private final CategoryRepository categoryRepository; // Add this field

        public record NewTransactionRequest(
                        Integer userId,
                        Integer accountId,
                        LocalDate date,
                        String description,
                        String merchant,
                        double amount,
                        TransactionType type,
                        Integer categoryId) {
        }

        public record UpdateTransactionRequest(
                        Integer userId,
                        Integer accountId,
                        LocalDate date,
                        String description,
                        String merchant,
                        Double amount,
                        TransactionType type,
                        Integer categoryId) {
        }

        public record TransactionResponse(
                        Integer id,
                        Integer accountId,
                        LocalDate date,
                        String description,
                        String merchant,
                        double amount,
                        TransactionType type,
                        Integer categoryId) {
        }

        // Update constructor to include CategoryRepository
        public TransactionController(TransactionService transactionService, UserService userService,
                        AccountService accountService,
                        CategoryRepository categoryRepository) {
                this.transactionService = transactionService;
                this.userService = userService;
                this.accountService = accountService;
                this.categoryRepository = categoryRepository; // Inject it here
        }

        @PostMapping(value = "/new")
        public ResponseEntity<TransactionResponse> newTransaction(
                        @RequestBody NewTransactionRequest request) {
                try {
                        // Checking if the necessary fields are present
                        if (request.userId() == null || request.accountId() == null ||
                                        request.date() == null || request.description() == null ||
                                        request.merchant() == null || request.type() == null ||
                                        request.categoryId() == null)
                                throw new IllegalArgumentException("Missing required fields");

                        User user = userService.findById(request.userId())
                                        .orElseThrow(() -> new IllegalArgumentException("User not found"));

                        // Find the account that this transaction will be associated to
                        Account account = accountService.findById(request.accountId())
                                        .orElseThrow(() -> new IllegalArgumentException("Account not found"));

                        // Security check: verify the account belongs to the authenticated user
                        if (!account.getUser().getId().equals(user.getId()))
                                throw new IllegalArgumentException("Account does not belong to user");

                        // Find the category that this transaction will be associated to
                        Category category = categoryRepository.findById(request.categoryId())
                                        .orElseThrow(() -> new IllegalArgumentException("Category not found"));

                        Transaction newTransaction = new Transaction(
                                        user,
                                        account,
                                        request.date(),
                                        request.description(),
                                        request.merchant(),
                                        request.amount(),
                                        request.type(),
                                        category);

                        transactionService.save(newTransaction);

                        return new ResponseEntity<TransactionResponse>(
                                        transactionService.toTransactionResponseBuilder(newTransaction),
                                        HttpStatus.CREATED);
                } catch (Exception e) {
                        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
                }
        }

        @GetMapping("/account/{accountId}") // Also fixed missing closing brace
        public ResponseEntity<List<TransactionResponse>> getTransactionsByAccount(
                        @PathVariable Integer accountId,
                        @RequestParam(required = false) LocalDate startDate,
                        @RequestParam(required = false) LocalDate endDate) {

                Account account = accountService.findById(accountId)
                                .orElseThrow(() -> new IllegalArgumentException("Account not found"));

                List<Transaction> transactions = transactionService.findByAccountId(accountId, startDate, endDate);

                List<TransactionResponse> responses = transactions.stream()
                                .map(transactionService::toTransactionResponseBuilder)
                                .toList();

                return ResponseEntity.ok(responses);
        }

        @GetMapping("/recent/{userId}")
        public ResponseEntity<List<TransactionResponse>> getRecentTransactions(
                        @PathVariable Integer userId,
                        @RequestParam(defaultValue = "month") String period) {

                List<Transaction> transactions = transactionService.getTransactionsByPeriod(userId, period);

                List<TransactionResponse> responses = transactions.stream()
                                .map(transactionService::toTransactionResponseBuilder)
                                .toList();

                return ResponseEntity.ok(responses);
        }

        @PatchMapping("/{transactionId}")
        public ResponseEntity<TransactionResponse> updateTransaction(
                        @PathVariable Integer transactionId,
                        @RequestBody UpdateTransactionRequest request) {
                try {
                        Transaction transaction = transactionService.findById(transactionId)
                                        .orElseThrow(() -> new IllegalArgumentException("Transaction not found"));

                        if (request.userId() == null || !transaction.getUser().getId().equals(request.userId()))
                                throw new IllegalArgumentException("Transaction does not belong to user");

                        if (request.accountId() != null) {
                                Account account = accountService.findById(request.accountId())
                                                .orElseThrow(() -> new IllegalArgumentException("Account not found"));

                                if (!account.getUser().getId().equals(request.userId()))
                                        throw new IllegalArgumentException("Account does not belong to user");

                                transaction.setAccount(account);
                        }
                        if (request.date() != null)
                                transaction.setDate(request.date());
                        if (request.description() != null)
                                transaction.setDescription(request.description());
                        if (request.merchant() != null)
                                transaction.setMerchant(request.merchant());
                        if (request.amount() != null)
                                transaction.setAmount(request.amount());
                        if (request.type() != null)
                                transaction.setType(request.type());
                        if (request.categoryId() != null) {
                                Category category = categoryRepository.findById(request.categoryId())
                                                .orElseThrow(() -> new IllegalArgumentException("Category not found"));

                                transaction.setCategory(category);
                        }

                        transactionService.update(transaction);

                        return ResponseEntity.ok(transactionService.toTransactionResponseBuilder(transaction));
                } catch (Exception e) {
                        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
                }
        }

        @DeleteMapping("/{transactionId}")
        public ResponseEntity<Void> deleteTransaction(
                        @PathVariable Integer transactionId,
                        @RequestParam Integer userId) {
                try {
                        Transaction transaction = transactionService.findById(transactionId)
                                        .orElseThrow(() -> new IllegalArgumentException("Transaction not found"));

                        if (!transaction.getUser().getId().equals(userId))
                                throw new IllegalArgumentException("Transaction does not belong to user");

                        transactionService.delete(transaction);

                        return ResponseEntity.noContent().build();
                } catch (Exception e) {
                        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
                }
        }

}