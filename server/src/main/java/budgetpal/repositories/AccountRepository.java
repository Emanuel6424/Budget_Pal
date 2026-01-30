package budgetpal.repositories;

import java.util.Optional;

import org.springframework.data.repository.CrudRepository;

import budgetpal.models.Account;

public interface AccountRepository extends CrudRepository<Account, Integer> {
    public Optional<Account> findByAccountNumber(String accountNumber);
} 