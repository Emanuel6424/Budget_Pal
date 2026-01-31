package budgetpal.controllers;

import java.time.LocalDateTime;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import budgetpal.models.Account;
import budgetpal.models.User;
import budgetpal.services.AccountService;
import budgetpal.services.UserService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

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

   @GetMapping(value = "/get/accountId/{accountId}")
    public ResponseEntity<AccountResponse> getAccountById(@PathVariable Integer accountId) {
        try {
            Account account = accountService.findById(accountId)
                    .orElseThrow(() -> new IllegalArgumentException("Account not found"));

            return ResponseEntity.ok(accountService.toAccountResponseBuilder(account));
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

}
