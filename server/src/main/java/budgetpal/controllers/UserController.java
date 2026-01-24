package budgetpal.controllers;

import java.time.LocalDateTime;

import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import budgetpal.models.User;
import budgetpal.services.UserService;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserService userService;

    public static record NewUserRequest(
            String firstName,
            String lastName,
            String email,
            String password) {
    }

    public static record UserResponse(
            Integer id,
            String firstName,
            String lastName,
            String email,
            LocalDateTime createdAt,
            LocalDateTime updatedAt) {
    }

    public static record LoginRequest(
            String email,
            String password) {
    }

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * This api endpoint takes a request body anc creates a new user in the database
     * Each account must have a first name, last name, email, and password
     */
    @PostMapping(value = "/new")
    public ResponseEntity<UserResponse> newUser(@RequestBody NewUserRequest request) {
        try {
            if (request.firstName() == null || request.lastName() == null ||
                    request.email() == null || request.password() == null) // Use () methods
                throw new IllegalArgumentException("Missing required fields");

            Optional<User> testUser = userService.findByEmail(request.email()); // Use ()

            if (testUser.isPresent()) {
                return new ResponseEntity<>(userService.toUserReponseBuilder(testUser.get()), HttpStatus.OK);
            }

            User user = new User(
                    request.firstName(), // Use constructor
                    request.lastName(),
                    request.email(),
                    request.password());

            User savedUser = userService.save(user); // Use savedUser for response

            return new ResponseEntity<>(userService.toUserReponseBuilder(savedUser), HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping(value = "/get/email/{email}")
    public ResponseEntity<UserResponse> getUserByEmail(@PathVariable String email) {
        try {
            if (email == null)
                throw new IllegalArgumentException("Missing email input");

            User user = userService.findByEmail(email)
                    .orElseThrow(() -> new IllegalArgumentException("User not found: " + email));

            return ResponseEntity.ok(userService.toUserReponseBuilder(user));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @PostMapping(value = "/post/login")
    public ResponseEntity<UserResponse> loginUser(@RequestBody LoginRequest request) {
        try {
            if (request.email() == null || request.password() == null)
                throw new IllegalArgumentException("Missing email or password");

            User user = userService.findByEmail(request.email())
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));

            if (request.password().equals(user.getPassword()))
                return ResponseEntity.ok(userService.toUserReponseBuilder(user));

            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
