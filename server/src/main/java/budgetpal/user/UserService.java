package budgetpal.user;

import java.time.LocalDate;
import java.util.*;

import org.springframework.stereotype.Service;

import budgetpal.budget.Budget;
import budgetpal.budget.BudgetService;
import budgetpal.user.UserController.UserResponse;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final BudgetService budgetService;

    public UserService (UserRepository userRepository, BudgetService budgetService){
        this.userRepository = userRepository;
        this.budgetService = budgetService;
    }

    public User save (User u){
        return userRepository.save(u);
    }

    public void delete (User u){
        userRepository.delete(u);
    }

    public Optional<User> findById (Integer id){
        return userRepository.findById(id);
    }

    public Optional<User> findByEmail (String email){
        return userRepository.findByEmail(email);
    }

    public List<User> findAll (){
        List<User> users = new ArrayList<>();
        userRepository.findAll().forEach((s) -> users.add(s));
        return users;
    }

    public UserResponse toUserReponseBuilder(User u){
       
        List<Budget> currBudgets = budgetService.getCurrentBudgets(u.getId());

        return new UserResponse(
            u.getId(),
            u.getFirstName(),
            u.getLastName(),
            u.getEmail(),
            u.getAccounts(),
            currBudgets,
            u.getCreatedAt(),
            u.getUpdatedAt()
        );
    }
}
