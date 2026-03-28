package budgetpal.transaction;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import budgetpal.account.Account;
import budgetpal.account.AccountRepository;
import budgetpal.transaction.TransactionController.TransactionResponse; // Fix this import
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

    public Optional<Transaction> findById(Integer id) {
        return transactionRepository.findById(id);
    }

    public List<Transaction> findByAccountId(Integer accountId, LocalDate startDate, LocalDate endDate) {
        if (startDate != null && endDate != null) {
            return transactionRepository.findByAccountIdAndDateBetween(accountId, startDate, endDate);
        }

        return transactionRepository.findByAccountId(accountId);
    }

    public List<Transaction> getTransactionsByPeriod(Integer userId, String period) {
    LocalDate today = LocalDate.now();
    LocalDate startDate;
    LocalDate endDate = today;
    
    switch (period.toLowerCase()) {
        case "week":
            startDate = today.minusWeeks(1);
            break;
        case "month":
            startDate = today.withDayOfMonth(1);
            endDate = today.withDayOfMonth(today.lengthOfMonth());
            break;
        case "year":
            startDate = today.withDayOfYear(1);
            endDate = today.withDayOfYear(today.lengthOfYear());
            break;
        default:
            startDate = today.withDayOfMonth(1);
            endDate = today.withDayOfMonth(today.lengthOfMonth());
    }
    
    return transactionRepository.findByUserIdAndDateBetween(userId, startDate, endDate);
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
                t.getCategory().getId());
    }
}