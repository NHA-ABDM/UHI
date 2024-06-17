package in.gov.abdm.eua.service.constants;

public class GlobalConstants {

    public static final String ACK = "ACK";
    public static final String NACK = "NACK";
    public static final String HSPA = "HSPA";
    public static final String EUA = "EUA";
    public static final String SUBSCRIBED = "SUBSCRIBED";
    public static final String AUTH_HEADER_NOT_FOUND = "AUTHORIZATION HEADER NOT FOUND";
    public static final String SIGN_HEADER_VALIDATION_FAILED = "SIGNING HEADER VERIFICATION FAILED";
    public static final String LOOKUP_FAILED = "INTERNAL SERVER ERROR";
    public static final String EUA_VALIDATION_FAILED = "EUA not registered with UHI. Pls get yourself registered.";
    public static final String ON_SEARCH = "on_search";
    public static final String SEARCH = "search";
    public static final String AUTHORIZATION = "Authorization";
    public static final String ED_25519 = "Ed25519";
    public static final String SUBSCRIBER_ID = "subscriber_id";
    public static final String PUB_KEY_ID = "pub_key_id";
    public static final String EUA_HSPA_EXCEPTION = "EUA/HSPA exception";
    public static final String X_GATEWAY_AUTHORIZATION = "X-Gateway-Authorization";
    public static final String REQUESTER_SERVICE_PROCESSOR = "RequesterService::processor::{}";
    public static final String SEARCH_ENDPOINT = "/search";
    public static final String ON_SEARCH_ENDPOINT = "/on_search";
    public static final String EUA_UTILITY = "EuaUtility";
    public static final String REQUEST_BODY_LOG_STMT = "{} | Request Body : {}";
    public static final String REQUEST_BODY_ENQUEUED_LOG_STMT = "{} | Request Body enqueued successfully: {}";
    public static final String RESPONSE_FROM_BOOKING_SERVICE_LOG_STMT = "{} | printing response from booking service :: {}";
    public static final String HEADER = "{} | Header {}";
    public static final String PROVIDER_URI_LOG_STMT = "Provider URI : {}";
    public static final String MESSAGE = "message";

    private GlobalConstants() {
    }
}
