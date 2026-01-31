package budgetpal.services;

import java.util.*;

import org.springframework.stereotype.Service;

import budgetpal.controllers.AccountController.AccountResponse;
import budgetpal.models.Account;
import budgetpal.repositories.AccountRepository;

@Service
public class AccountService {
    private final AccountRepository accountRepository;

    public AccountService(AccountRepository accountRepository) {
        this.accountRepository = accountRepository;
    }

    public Account save(Account a) {
        return accountRepository.save(a);
    }

    public void delete(Account a) {
        accountRepository.delete(a);
    }

    public Optional<Account> findById(Integer id) {
        return accountRepository.findById(id);
    }

    public Optional<Account> findByAccountNumber(String accountNumber) {
        return accountRepository.findByAccountNumber(accountNumber);
    }

    public List<Account> finalAll() {
        List<Account> accounts = new ArrayList<>();
        accountRepository.findAll().forEach((a) -> accounts.add(a));
        return accounts;
    }

    public AccountResponse toAccountResponseBuilder(Account a) {
        return new AccountResponse(
                a.getId(),
                a.getName(),
                a.getType(),
                a.getAccountNumber(),
                a.getBalance(),
                a.isActive(),
                a.getUser().getId(),
                a.getCreatedAt(),
                a.getUpdatedAt());
    }
}
