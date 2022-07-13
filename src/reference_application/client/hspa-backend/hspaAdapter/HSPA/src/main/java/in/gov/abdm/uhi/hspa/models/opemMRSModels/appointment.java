package in.gov.abdm.uhi.hspa.models.opemMRSModels;

import lombok.Data;

@Data
public class appointment {

    public String timeSlot;
    public String patient;
    public String status;
    public String appointmentType;
    public String visit;

}
