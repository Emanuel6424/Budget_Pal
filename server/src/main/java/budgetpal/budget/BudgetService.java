package budgetpal.budget;

import java.util.Optional;

import org.springframework.stereotype.Service;

import budgetpal.budget.BudgetController.BudgetResponse;
import budgetpal.user.UserRepository;

@Service
public class BudgetService {
    private final BudgetRepository budgetRepository;
    private final UserRepository userRepository;

    public BudgetService(BudgetRepository budgetRepository, UserRepository userRepository){
        this.budgetRepository = budgetRepository;
        this.userRepository = userRepository;
    }

    public Budget save(Budget b){
        return budgetRepository.save(b);
    }

    public void delete(Budget b){
        budgetRepository.delete(b);
    }

    public Optional<Budget> findById(Integer id){
        return budgetRepository.findById(id);
    }

    public BudgetResponse toBudgetReponseBuilder(Budget b){
        return new BudgetResponse(
            b.getId(),
            b.getName(),
            b.getLimitAmount(),
            b.getPeriod(),
            b.getStartDate(),
            b.getEndDate(),
            b.isActive(),
            b.getUser().getId(),
            b.getCategory().getId()
        );
    }
}
