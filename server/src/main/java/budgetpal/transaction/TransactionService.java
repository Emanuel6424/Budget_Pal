package budgetpal.transaction;

import java.util.Optional;

import org.springframework.stereotype.Service;

import budgetpal.account.Account;
import budgetpal.account.AccountRepository;
import budgetpal.transaction.TransactionController.TransactionResponse;  // Fix this import
import jakarta.transaction.Transactional;

@Service
public class TransactionService {
    private final TransactionRepository transactionRepository;
    private final AccountRepository accountRepository;

    public TransactionService(TransactionRepository transactionRepository,
                             AccountRepository accountRepository) {
        this.transactionRepository = transactionRepository;
        this.accountRepository = accountRepository;
    }

    @Transactional
    public Transaction save(Transaction t) {
        Account account = t.getAccount();
        
        if (t.getType() == TransactionType.EXPENSE) {
            account.setBalance(account.getBalance() - t.getAmount());
        } else if (t.getType() == TransactionType.INCOME) {
            account.setBalance(account.getBalance() + t.getAmount());
        }
        
        accountRepository.save(account);
        return transactionRepository.save(t);
    }
    
    // ... rest of methods


    public Optional<Transaction> findById(Integer id) {
        return transactionRepository.findById(id);
    }

    public TransactionResponse toTransactionResponseBuilder(Transaction t) {
        return new TransactionResponse(
            t.getId(),
            t.getAccount().getId(),
            t.getDate(),
            t.getDescription(),
            t.getMerchant(),
            t.getAmount(),
            t.getType(),
            t.getCategory().getId()
        );
    }
}