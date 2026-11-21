package budgetpal.budget;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class BudgetRenewalServiceTest {

    @Mock
    private BudgetService budgetService;

    @Test
    void renewExpiredBudgets_rendersDueBudgets() {
        BudgetRenewalService job = new BudgetRenewalService(budgetService);
        Budget due = new Budget();
        due.setId(1);
        when(budgetService.findBudgetsDueForRenewal(any())).thenReturn(List.of(due));

        job.renewExpiredBudgets();

        verify(budgetService, times(1)).renewUntilCurrent(eq(due), any(LocalDate.class));
    }

    @Test
    void renewExpiredBudgets_secondRunWithNothingDue_doesNothing() {
        BudgetRenewalService job = new BudgetRenewalService(budgetService);
        // After a prior run, the repository no longer returns the already-renewed budget.
        when(budgetService.findBudgetsDueForRenewal(any())).thenReturn(Collections.emptyList());

        job.renewExpiredBudgets();

        verify(budgetService, never()).renewUntilCurrent(any(), any());
    }

    @Test
    void renewExpiredBudgets_oneBudgetFailing_doesNotBlockTheOthers() {
        BudgetRenewalService job = new BudgetRenewalService(budgetService);
        Budget failing = new Budget();
        failing.setId(1);
        Budget healthy = new Budget();
        healthy.setId(2);
        when(budgetService.findBudgetsDueForRenewal(any())).thenReturn(List.of(failing, healthy));
        doThrow(new RuntimeException("boom")).when(budgetService).renewUntilCurrent(eq(failing), any());

        job.renewExpiredBudgets();

        verify(budgetService, times(1)).renewUntilCurrent(eq(healthy), any(LocalDate.class));
    }
}
