package budgetpal.budget;

import java.time.LocalDate;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import budgetpal.budget.BudgetService.BudgetStatus;
import budgetpal.category.Category;
import budgetpal.category.CategoryRepository;
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

}
