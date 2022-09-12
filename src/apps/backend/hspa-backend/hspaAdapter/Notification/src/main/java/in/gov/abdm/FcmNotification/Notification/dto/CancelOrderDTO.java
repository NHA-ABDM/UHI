package in.gov.abdm.FcmNotification.Notification.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;

import in.gov.abdm.uhi.common.dto.Descriptor;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
public class CancelOrderDTO {
	    private String orderId;	
	    private String categoryId;
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
	    private String abhaId;
	    private String patientName;
}
