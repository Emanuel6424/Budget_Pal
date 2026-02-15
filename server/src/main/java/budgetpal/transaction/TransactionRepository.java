package budgetpal.transaction;

import org.springframework.data.repository.CrudRepository;

import java.time.LocalDate;
import java.util.List;

public interface TransactionRepository extends CrudRepository<Transaction, Integer> {
    List<Transaction> findByAccountId(Integer id);

    List<Transaction> findByAccountIdAndDateBetween(Integer accountId, LocalDate startDate, LocalDate endDate);
}
