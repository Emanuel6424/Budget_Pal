package budgetpal.budget;

import org.springframework.data.repository.CrudRepository;

public interface BudgetRepository extends CrudRepository<Budget, Integer>  {
    
}
