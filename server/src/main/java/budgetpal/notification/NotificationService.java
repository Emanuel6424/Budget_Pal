package budgetpal.notification;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;

import budgetpal.budget.Budget;
import budgetpal.user.User;

@Service
public class NotificationService {
    private final NotificationRepository notificationRepository;

    public NotificationService(NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    public List<Notification> getForUser(Integer userId) {
        return notificationRepository.findByUserIdUnreadFirst(userId);
    }

    /**
     * Creates a BUDGET_UNDERSPENT notification for the given budget, unless one
     * already exists (budget_id, type) is unique, so this is safe to call again
     * on a re-run of the renewal job.
     */
    public void createUnderspentNotificationIfAbsent(User user, Budget budget, double saved) {
        if (notificationRepository.findByBudgetIdAndType(budget.getId(), NotificationType.BUDGET_UNDERSPENT)
                .isPresent())
            return;

        String title = "You're under budget on " + budget.getName();
        String body = String.format("You underspent your %s budget by $%.2f last period.", budget.getName(), saved);

        notificationRepository.save(
                new Notification(user, budget, NotificationType.BUDGET_UNDERSPENT, title, body));
    }

    /**
     * Marks a notification read, verifying it belongs to the requesting user.
     */
    public Notification markRead(Integer notificationId, Integer requestingUserId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new IllegalArgumentException("Notification not found"));

        if (!notification.getUser().getId().equals(requestingUserId))
            throw new SecurityException("Notification does not belong to user");

        if (notification.getReadAt() == null)
            notification.setReadAt(LocalDateTime.now());

        return notificationRepository.save(notification);
    }
}
