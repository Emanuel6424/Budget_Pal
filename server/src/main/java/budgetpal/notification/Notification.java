package budgetpal.notification;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;

import budgetpal.budget.Budget;
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
@Table(name = "notifications")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne
    @JoinColumn(name = "budget_id")
    private Budget budget;

    @Enumerated(EnumType.STRING)
    private NotificationType type;

    private String title;

    private String body;

    private LocalDateTime readAt;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    public Notification(User user, Budget budget, NotificationType type, String title, String body) {
        this.user = user;
        this.budget = budget;
        this.type = type;
        this.title = title;
        this.body = body;
    }
}
