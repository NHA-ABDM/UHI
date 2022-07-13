package in.gov.abdm.uhi.hspa.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
public class IntermediatePatientAppointmentModel {

    private String slotId;
    private String patientId;
    private String appointmentTypeId;
    private String appointmentTypeName;
    private String status;
    private String appointmentId;
    private String name;
    private String gender;
}
