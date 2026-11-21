package budgetpal.budget;

import java.time.LocalDate;

public enum BudgetPeriod {
    WEEKLY,
    MONTHLY,
    YEARLY;

    /**
     * Given the start date of a period, returns the end date of that same period
     * (inclusive), per this period's length.
     */
    public LocalDate endDateFrom(LocalDate startDate) {
        switch (this) {
            case WEEKLY:
                return startDate.plusWeeks(1).minusDays(1);
            case MONTHLY:
                return startDate.plusMonths(1).minusDays(1);
            case YEARLY:
                return startDate.plusYears(1).minusDays(1);
            default:
                throw new IllegalStateException("Unhandled BudgetPeriod: " + this);
        }
    }
}
