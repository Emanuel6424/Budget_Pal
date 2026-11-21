package budgetpal.notification;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

// NOTE: there is no auth yet (MVP). Ownership is verified against a client-supplied
// userId instead of a token-derived identity. See README for the real-auth caveat.
@RestController
@RequestMapping("/api/notification")
public class NotificationController {

    private final NotificationService notificationService;

    public record NotificationResponse(
            Integer id,
            Integer budgetId,
            NotificationType type,
            String title,
            String body,
            LocalDateTime readAt,
            LocalDateTime createdAt) {
    }

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    // Same MVP caveat as the class-level NOTE: userId is client-supplied, not
    // token-derived, so this returns whichever user's notifications are asked for.
    @GetMapping("/{userId}")
    public ResponseEntity<List<NotificationResponse>> getNotifications(@PathVariable Integer userId) {
        List<NotificationResponse> responses = notificationService.getForUser(userId).stream()
                .map(NotificationController::toResponse)
                .toList();

        return ResponseEntity.ok(responses);
    }

    @PostMapping("/{id}/read")
    public ResponseEntity<NotificationResponse> markRead(@PathVariable Integer id,
            @RequestParam Integer userId) {
        try {
            Notification notification = notificationService.markRead(id, userId);
            return ResponseEntity.ok(toResponse(notification));
        } catch (SecurityException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    private static NotificationResponse toResponse(Notification n) {
        return new NotificationResponse(
                n.getId(),
                n.getBudget().getId(),
                n.getType(),
                n.getTitle(),
                n.getBody(),
                n.getReadAt(),
                n.getCreatedAt());
    }
}
