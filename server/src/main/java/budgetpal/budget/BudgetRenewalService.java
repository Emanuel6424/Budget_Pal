package budgetpal.budget;

import java.time.LocalDate;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Daily job that rolls over any budget whose period has ended into a fresh
 * period at the same limit (no rollover), and raises an underspend
 * notification for any period that closed with money left over.
 */
@Component
public class BudgetRenewalService {

    private static final Logger log = LoggerFactory.getLogger(BudgetRenewalService.class);

    private final BudgetService budgetService;

    public BudgetRenewalService(BudgetService budgetService) {
        this.budgetService = budgetService;
    }

    // Runs once a day, early morning, after the previous day's transactions have settled.
    @Scheduled(cron = "0 0 2 * * *")
    public void renewExpiredBudgets() {
        LocalDate today = LocalDate.now();
        List<Budget> dueForRenewal = budgetService.findBudgetsDueForRenewal(today);

        for (Budget budget : dueForRenewal) {
            try {
                // Each budget's full catch-up chain runs in its own transaction
                // (see @Transactional on renewUntilCurrent) so one failure doesn't
                // block renewal of the others.
                budgetService.renewUntilCurrent(budget, today);
            } catch (Exception e) {
                log.error("Failed to renew budget {}", budget.getId(), e);
            }
        }
    }
}
