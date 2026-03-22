package budgetpal.budget;

import java.time.LocalDate;
import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonProperty;

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
@Table(name = "budgets")
public class Budget {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String name;

    private double limitAmount;

    @Enumerated(EnumType.STRING)
    private BudgetPeriod period;

    private LocalDate startDate;

    private LocalDate endDate;

    private boolean isActive;

    @ManyToOne
    @JoinColumn(name = "user_id")
    @JsonBackReference(value = "budgets-users")
    private User user;

    @ManyToOne
    @JoinColumn(name = "category_id")
    @JsonBackReference(value = "budgets-categories")  // Changed this
    private Category category;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    // Add this getter to expose categoryId in JSON
    @JsonProperty("categoryId")
    public Integer getCategoryId() {
        return category != null ? category.getId() : null;
    }

    public Budget(String name, double limitAmount, BudgetPeriod period, LocalDate startDate, LocalDate endDate,
            User user, Category category) {
        this.name = name;
        this.limitAmount = limitAmount;
        this.period = period;
        this.startDate = startDate;
        this.endDate = endDate;
        this.isActive = true;
        this.user = user;
        this.category = category;
    }
}