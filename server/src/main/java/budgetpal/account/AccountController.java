package budgetpal.account;

import java.time.LocalDateTime;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import budgetpal.user.User;
import budgetpal.user.UserService;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

@RestController
@RequestMapping("/api/account")
public class AccountController {
    private final AccountService accountService;
    private final UserService userService;

    public static record NewAccountRequest(
            String name,
            String type,
            String accountNumber,
            double balance,
            Integer userId) {

    }

    public static record UpdateAccountRequest(
            String name,
            String accountNumber,
            Integer userId) {

    }

    public static record AccountResponse(
        Integer id,
        String name,
        String type,
        String accountNumber,
        double balance,
        boolean isActive,
        Integer userId,
        LocalDateTime createdAt,
        LocalDateTime updatedAt) {
}

    public AccountController(AccountService accountService, UserService userService) {
        this.accountService = accountService;
        this.userService = userService;
    }

    @PostMapping(value = "/new")
    public ResponseEntity<AccountResponse> newAccount(@RequestBody NewAccountRequest request) {
        try {

            // Checking if the the nesscary fields are present
            if (request.name() == null || request.type() == null || request.accountNumber() == null
                    || request.userId() == null)
                throw new IllegalArgumentException("Missing required fields");

            // declare a general new account and use setters in order to input info

            // Find the user that this account will be assoicated to
            User user = userService.findById(request.userId())
                    .orElseThrow(() -> new IllegalArgumentException("user not found"));

            Account newAccount = new Account(
                    request.name(),
                    request.type(),
                    request.accountNumber(),
                    request.balance(),
                    user);

            accountService.save(newAccount);

            return new ResponseEntity<AccountResponse>(accountService.toAccountResponseBuilder(newAccount),
                    HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

   @GetMapping(value = "/get/account/{accountId}")
    public ResponseEntity<AccountResponse> getAccountById(@PathVariable Integer accountId) {
        try {
            Account account = accountService.findById(accountId)
                    .orElseThrow(() -> new IllegalArgumentException("Account not found"));

            return ResponseEntity.ok(accountService.toAccountResponseBuilder(account));
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @PatchMapping(value = "/{accountId}")
    public ResponseEntity<AccountResponse> updateAccount(@PathVariable Integer accountId,
            @RequestBody UpdateAccountRequest request) {
        try {
            Account account = accountService.findById(accountId)
                    .orElseThrow(() -> new IllegalArgumentException("Account not found"));

            if (request.userId() == null || !account.getUser().getId().equals(request.userId()))
                throw new IllegalArgumentException("Account does not belong to user");

            if (request.name() != null)
                account.setName(request.name());
            if (request.accountNumber() != null)
                account.setAccountNumber(request.accountNumber());

            accountService.save(account);

            return ResponseEntity.ok(accountService.toAccountResponseBuilder(account));
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping(value = "/{accountId}")
    public ResponseEntity<Void> deleteAccount(@PathVariable Integer accountId, @RequestParam Integer userId) {
        try {
            Account account = accountService.findById(accountId)
                    .orElseThrow(() -> new IllegalArgumentException("Account not found"));

            if (!account.getUser().getId().equals(userId))
                throw new IllegalArgumentException("Account does not belong to user");

            accountService.delete(account);

            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

}
