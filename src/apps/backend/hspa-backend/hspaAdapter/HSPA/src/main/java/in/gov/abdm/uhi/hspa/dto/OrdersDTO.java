package in.gov.abdm.uhi.hspa.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = true)
@Data
@JsonDeserialize(using = LocalDateTimeDeserializer.class)
@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class OrdersDTO extends ServiceResponseDTO {
    private String orderId;

    private String categoryId;

    private String appointmentId;

    private String orderDate;
    private String healthcareServiceName;
    private String healthcareServiceId;
    private String healthcareProviderName;
    private String healthcareProviderId;
    private String healthcareProviderUrl;
    private String healthcareServiceProviderEmail;
    private String healthcareServiceProviderPhone;
    private String healthcareProfessionalName;
    private String healthcareProfessionalImage;
    private String healthcareProfessionalEmail;
    private String healthcareProfessionalPhone;
    private String healthcareProfessionalId;
    private String healthcareProfessionalGender;
    private String serviceFulfillmentStartTime;
    private String serviceFulfillmentEndTime;
    private String serviceFulfillmentType;

    private String symptoms;
    private String languagesSpokenByHealthcareProfessional;
    private String healthcareProfessionalExperience;
    private String isServiceFulfilled;
    private String healthcareProfessionalDepartment;
    private String message;
    private String slotId;
    private String transId;
    private String primaryDoctor;
    private String secondaryDoctor;
    private String groupConsultStatus;
    private String abhaId;
    private String patientName;

}
