package in.gov.abdm.uhi.EUABookingService.constants;

public class ConstantsUtils {
	
	 public static final String INITIALIZED = "INITIALIZED";
	 public static final String ON_CONFIRM = "on_confirm";
	 public static final String ON_INIT = "on_init";
	 
    // ENDPOINTS
 
    public static final String WEBSOCKET_CONNECT_ENDPOINT = "/api/v1/bookingService/eua-chat";
    public static final String WEBSOCKET_CONNECT_TEST_ENDPOINT = "/test-chat";
    
    // BROKER CONFIG
    public static final String DESTINATION = "/client";
    public static final String USER_DESTINATION_PREFIX = "/msg";
    public static final String APPLICATION_DESTINATION_PREFIX = "/msg-eua";
    public static final String ON_MESSAGE = "on_message";
	public static final String CHAT = "chat";
	public static final String MEDIA = "media";
	public static final String TEXT = "text";
    		

  
}
