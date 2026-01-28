package budgetpal.repositories;

import org.springframework.data.repository.CrudRepository;

import budgetpal.models.Account;

public interface AccountRepository extends CrudRepository<Account, Integer> {
    
} 