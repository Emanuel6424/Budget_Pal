package budgetpal.controllers;

import java.time.LocalDateTime;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import budgetpal.models.User;
import budgetpal.services.AccountService;

@RestController
@RequestMapping("/api/account")
public class AccountController {
    private final AccountService accountService;

    public static record AccountResponse(
        Integer id,
        String name,
        String type,
        double balance,
        boolean isActive,
        User user,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
    ) {}

    public AccountController (AccountService accountService){
        this.accountService = accountService;
    }

    
}
