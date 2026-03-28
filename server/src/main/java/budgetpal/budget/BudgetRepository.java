package budgetpal.budget;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.repository.CrudRepository;

public interface BudgetRepository extends CrudRepository<Budget, Integer>  {
    List<Budget> findByUserIdAndIsActiveTrueAndStartDateLessThanEqualAndEndDateGreaterThanEqual(
        Integer userId,
        LocalDate currentDate1,
        LocalDate currentDate2
    );
}
