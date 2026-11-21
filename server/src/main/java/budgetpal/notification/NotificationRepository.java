package budgetpal.notification;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

public interface NotificationRepository extends CrudRepository<Notification, Integer> {

    // Unread (readAt IS NULL) first, then newest first within each group.
    // Ordering via a CASE expression rather than a derived "OrderByReadAtAsc" method
    // because plain ORDER BY readAt ASC puts NULLs last on Postgres, not first.
    @Query("SELECT n FROM Notification n WHERE n.user.id = :userId "
            + "ORDER BY CASE WHEN n.readAt IS NULL THEN 0 ELSE 1 END, n.createdAt DESC")
    List<Notification> findByUserIdUnreadFirst(@Param("userId") Integer userId);

    Optional<Notification> findByBudgetIdAndType(Integer budgetId, NotificationType type);
}
