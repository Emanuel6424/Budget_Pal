package budgetpal.budget;

import java.time.LocalDateTime;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import budgetpal.category.Category;
import budgetpal.category.CategoryRepository;
import budgetpal.user.User;
import budgetpal.user.UserService;

@Controller
@RequestMapping("api/budget")
public class BudgetController {

    private final BudgetService budgetService;
    private final UserService userService;
    private final CategoryRepository categoryRepository;

    public static record NewBudgetRequest(
            String name,
            double limitAmount,
            String period,
            LocalDateTime startDate,
            LocalDateTime endDate,
            Integer userId,
            Integer categoryId

    ) {
    }

    public static record BudgetResponse(
            Integer id,
            String name,
            double limitAmount,
            String period,
            LocalDateTime startDate,
            LocalDateTime endDate,
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
                    || request.period() == null || request.startDate() == null || request.endDate() == null)
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

}
