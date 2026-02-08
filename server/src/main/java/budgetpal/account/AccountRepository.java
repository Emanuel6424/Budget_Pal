package budgetpal.account;

import java.util.Optional;

import org.springframework.data.repository.CrudRepository;

public interface AccountRepository extends CrudRepository<Account, Integer> {
    public Optional<Account> findByAccountNumber(String accountNumber);
} 