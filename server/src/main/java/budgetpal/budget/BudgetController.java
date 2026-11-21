package budgetpal.budget;

import java.time.LocalDate;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import budgetpal.budget.BudgetService.BudgetHistoryEntry;
import budgetpal.budget.BudgetService.BudgetStatus;
import budgetpal.category.Category;
import budgetpal.category.CategoryRepository;
import budgetpal.transaction.TransactionController.TransactionResponse;
import budgetpal.user.User;
import budgetpal.user.UserService;

@RestController
@RequestMapping("api/budget")
public class BudgetController {

        private final BudgetService budgetService;
        private final UserService userService;
        private final CategoryRepository categoryRepository;

        public static record NewBudgetRequest(
                        String name,
                        double limitAmount,
                        BudgetPeriod period,
                        LocalDate startDate,
                        LocalDate endDate,
                        Integer userId,
                        Integer categoryId

        ) {
        }

        public static record UpdateBudgetRequest(
                        Integer userId,
                        String name,
                        Double limitAmount,
                        BudgetPeriod period,
                        LocalDate startDate,
                        LocalDate endDate,
                        Integer categoryId) {
        }

        public static record BudgetResponse(
                        Integer id,
                        String name,
                        double limitAmount,
                        BudgetPeriod period,
                        LocalDate startDate,
                        LocalDate endDate,
                        boolean isActive,
                        Integer userId,
                        Integer categoryId) {
        }

        public BudgetController(BudgetService budgetService, UserService userService,
                        CategoryRepository categoryRepository) {
                this.budgetService = budgetService;
                this.userService = userService;
                this.categoryRepository = categoryRepository;
        }

        @PostMapping(value = "/new")
        public ResponseEntity<BudgetResponse> newBudget(@RequestBody NewBudgetRequest request) {
                try {
                        if (request.userId() == null || request.categoryId() == null || request.name() == null
                                        || request.period() == null || request.startDate() == null
                                        || request.endDate() == null)
                                throw new IllegalArgumentException("Miss required fields");

                        User user = userService.findById(request.userId())
                                        .orElseThrow(() -> new IllegalArgumentException("User not found"));

                        Category category = categoryRepository.findById(request.categoryId())
                                        .orElseThrow(() -> new IllegalArgumentException("Category not found"));

                        Budget newBudget = new Budget(
                                        request.name(),
                                        request.limitAmount(),
                                        request.period(),
                                        request.startDate(),
                                        request.endDate(),
                                        user,
                                        category);

                        budgetService.save(newBudget);

                        return new ResponseEntity<BudgetResponse>(budgetService.toBudgetReponseBuilder(newBudget),
                                        HttpStatus.CREATED);

                } catch (Exception e) {
                        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
                }
        }

        @GetMapping("/{budgetId}/status")
        public ResponseEntity<BudgetStatus> getBudgetStatus(@PathVariable Integer budgetId) {
                try {
                        BudgetStatus status = budgetService.getBudgetStatus(budgetId);
                        return ResponseEntity.ok(status);
                } catch (IllegalArgumentException e) {
                        return ResponseEntity.notFound().build();
                }
        }

        @GetMapping("/{budgetId}/transactions")
        public ResponseEntity<List<TransactionResponse>> getBudgetTransactions(@PathVariable Integer budgetId) {
                try {
                        List<TransactionResponse> transactions = budgetService.getBudgetTransactions(budgetId);
                        return ResponseEntity.ok(transactions);
                } catch (IllegalArgumentException e) {
                        return ResponseEntity.notFound().build();
                }
        }

        // Past (inactive) budgets for this user, with spent/saved computed on the fly.
        // NOTE: there is no auth yet (MVP). userId is client-supplied, not token-derived,
        // so this returns whichever user's history is asked for. See README for the caveat.
        @GetMapping("/history/{userId}")
        public ResponseEntity<List<BudgetHistoryEntry>> getBudgetHistory(@PathVariable Integer userId) {
                return ResponseEntity.ok(budgetService.getBudgetHistory(userId));
        }

        @PatchMapping("/{budgetId}")
        public ResponseEntity<BudgetResponse> updateBudget(
                        @PathVariable Integer budgetId,
                        @RequestBody UpdateBudgetRequest request) {
                try {
                        Budget budget = budgetService.findById(budgetId)
                                        .orElseThrow(() -> new IllegalArgumentException("Budget not found"));

                        if (request.userId() == null || !budget.getUser().getId().equals(request.userId()))
                                throw new IllegalArgumentException("Budget does not belong to user");

                        if (request.name() != null)
                                budget.setName(request.name());
                        if (request.limitAmount() != null)
                                budget.setLimitAmount(request.limitAmount());
                        if (request.period() != null)
                                budget.setPeriod(request.period());
                        if (request.startDate() != null)
                                budget.setStartDate(request.startDate());
                        if (request.endDate() != null)
                                budget.setEndDate(request.endDate());
                        if (request.categoryId() != null) {
                                Category category = categoryRepository.findById(request.categoryId())
                                                .orElseThrow(() -> new IllegalArgumentException("Category not found"));

                                budget.setCategory(category);
                        }

                        budgetService.save(budget);

                        return ResponseEntity.ok(budgetService.toBudgetReponseBuilder(budget));
                } catch (Exception e) {
                        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
                }
        }

        @DeleteMapping("/{budgetId}")
        public ResponseEntity<Void> deleteBudget(
                        @PathVariable Integer budgetId,
                        @RequestParam Integer userId) {
                try {
                        Budget budget = budgetService.findById(budgetId)
                                        .orElseThrow(() -> new IllegalArgumentException("Budget not found"));

                        if (!budget.getUser().getId().equals(userId))
                                throw new IllegalArgumentException("Budget does not belong to user");

                        budgetService.delete(budget);

                        return ResponseEntity.noContent().build();
                } catch (Exception e) {
                        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
                }
        }

}
