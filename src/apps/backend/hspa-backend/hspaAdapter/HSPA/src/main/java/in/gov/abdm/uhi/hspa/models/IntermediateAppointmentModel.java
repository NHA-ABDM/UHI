package in.gov.abdm.uhi.hspa.models;

import lombok.Data;

@Data
public class IntermediateAppointmentModel {

    public String appointmentTypeName;
    public String appointmentTypeUUID;
    public String appointmentTypeDisplay;
    public String startDate;
    public String endDate;

}
