package in.gov.abdm.uhi.hspa.models;

import lombok.Data;

import java.util.List;

@Data
public class IntermediateAppointmentSearchModel {
    public List<IntermediateProviderModel> providers;
    public List<IntermediateAppointmentModel> appointmentTypes;
    public String startDate;
    public String endDate;
    public String view;

}
