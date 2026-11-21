package budgetpal.budget;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.time.LocalDate;

import org.junit.jupiter.api.Test;

class BudgetPeriodTest {

    @Test
    void weekly_addsSixDays() {
        assertEquals(LocalDate.of(2026, 1, 7), BudgetPeriod.WEEKLY.endDateFrom(LocalDate.of(2026, 1, 1)));
    }

    @Test
    void monthly_januaryThirtyFirst_endsOnFebruary28_nonLeapYear() {
        // Jan 31 2026 -> +1 month = Feb 28 2026 (2026 is not a leap year, Feb 28 is month end)
        // then -1 day lands on Feb 27.
        assertEquals(LocalDate.of(2026, 2, 27), BudgetPeriod.MONTHLY.endDateFrom(LocalDate.of(2026, 1, 31)));
    }

    @Test
    void monthly_januaryThirtyFirst_leapYear() {
        // 2028 is a leap year: Jan 31 2028 + 1 month = Feb 29 2028, -1 day = Feb 28 2028.
        assertEquals(LocalDate.of(2028, 2, 28), BudgetPeriod.MONTHLY.endDateFrom(LocalDate.of(2028, 1, 31)));
    }

    @Test
    void monthly_regularMonth() {
        assertEquals(LocalDate.of(2026, 2, 28), BudgetPeriod.MONTHLY.endDateFrom(LocalDate.of(2026, 2, 1)));
    }

    @Test
    void yearly_leapDayStart() {
        // Feb 29 2028 (leap) + 1 year = Feb 28 2029 (non-leap, no Feb 29), -1 day = Feb 27 2029.
        assertEquals(LocalDate.of(2029, 2, 27), BudgetPeriod.YEARLY.endDateFrom(LocalDate.of(2028, 2, 29)));
    }

    @Test
    void yearly_regularStart() {
        assertEquals(LocalDate.of(2026, 12, 31), BudgetPeriod.YEARLY.endDateFrom(LocalDate.of(2026, 1, 1)));
    }
}
