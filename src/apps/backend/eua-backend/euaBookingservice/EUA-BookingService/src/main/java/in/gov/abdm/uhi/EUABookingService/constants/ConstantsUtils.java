package in.gov.abdm.uhi.EUABookingService.constants;

public class ConstantsUtils {
	
	public static final String INITIALIZED = "INITIALIZED";
	public static final String ON_CONFIRM = "on_confirm";
	public static final String ON_INIT = "on_init"; 
    public static final String WEBSOCKET_CONNECT_ENDPOINT = "/api/v1/bookingService/eua-chat";
    public static final String WEBSOCKET_CONNECT_ENDPOINT_CANCEL = "/api/v1/bookingService/eua-cancel";
    public static final String WEBSOCKET_CONNECT_TEST_ENDPOINT = "/test-chat";

	public static final String AUTHORIZATION = "Authorization";
   
    public static final String DESTINATION = "/client";
    public static final String USER_DESTINATION_PREFIX = "/msg";
    public static final String APPLICATION_DESTINATION_PREFIX = "/msg-eua";
    public static final String ON_MESSAGE = "on_message";
	public static final String CHAT = "chat";
	public static final String MEDIA = "media";
	public static final String TEXT = "text";
	public static final String DOWNLOADFILE= "/downloadFile/";
	public static final String ABDM_GOV_IN_TELECONSULTATION_URI = "@abdm/gov.in/teleconsultation/uri";
	public static final Object ABDM_GOV_IN_PRIMARY_DOCTOR_NAME =  "@abdm/gov.in/primaryDoctorName";
	public static final Object ABDM_GOV_IN_PRIMARY_DOCTOR_HPR =  "@abdm/gov.in/primaryHprAddress";
	public static final Object ABDM_GOV_IN_PRIMARY_DOCTOR_PROVIDER_URL = "@abdm/gov.in/primaryDoctorProviderUrl";
	public static final Object ABDM_GOV_IN_PRIMARY_DOCTOR_GENDER =  "@abdm/gov.in/primaryDoctorGender";

	public static final Object ABDM_GOV_IN_SECONDARY_DOCTOR_NAME =  "@abdm/gov.in/secondaryDoctorName";
	public static final Object ABDM_GOV_IN_SECONDARY_DOCTOR_HPR =  "@abdm/gov.in/secondaryHprAddress";
	public static final Object ABDM_GOV_IN_SECONDARY_DOCTOR_PROVIDER_URL = "@abdm/gov.in/secondaryDoctorProviderUrl";
	public static final Object ABDM_GOV_IN_SECONDARY_GENDER =  "@abdm/gov.in/secondaryDoctorGender";

	public static final String ABDM_GOV_IN_PATIENT_GENDER = "@abdm/gov.in/patientGender";
	public static final Object ABDM_GOV_IN_GROUPCONSULT = "@abdm/gov.in/groupConsultation";
	public static final String False = "false";
    		

  
}
