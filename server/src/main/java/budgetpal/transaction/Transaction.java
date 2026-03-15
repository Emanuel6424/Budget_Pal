package budgetpal.transaction;

import java.time.LocalDate;
import java.time.LocalDateTime;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.fasterxml.jackson.annotation.JsonBackReference;

import budgetpal.account.Account;
import budgetpal.category.Category;
import budgetpal.user.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@Table(name = "transactions")
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    @JsonBackReference(value = "transactions-users")
    private User user;

    @ManyToOne
    @JoinColumn(name = "account_id")
    @JsonBackReference(value = "transactions-accounts")
    private Account account;

    private LocalDate date;

    private String description;

    private String merchant;

    private double amount;

    @Enumerated(EnumType.STRING)  // <-- Add this annotation
    private TransactionType type;  // <-- Change from String to TransactionType

    @ManyToOne
    @JoinColumn(name = "category_id")
    @JsonBackReference(value = "transactions-categories")
    private Category category;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    public Transaction(User user, Account account, LocalDate date, String description, String merchant,
            double amount, TransactionType type, Category category) {
        this.user = user;
        this.account = account;
        this.date = date;
        this.description = description;
        this.merchant = merchant;
        this.amount = amount;
        this.type = type;
        this.category = category;
    }
}

