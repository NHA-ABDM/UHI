package in.gov.abdm.eua.service.constants;

public class ConstantsUtils {

    // ENDPOINTS
    public static final String STATUS_ENDPOINT = "/status";
    public static final String CONFIRM_ENDPOINT = "/confirm";
    public static final String INIT_ENDPOINT = "/init";
    public static final String SELECT_ENDPOINT = "/select";
    public static final String SEARCH_ENDPOINT = "/search";
    public static final String WEBSOCKET_CONNECT_ENDPOINT = "/api/v1/euaService/ws-client";
    public static final String EUA_TO_CLIENT_WEBSOCKET_CONNECT_ENDPOINT = "/euaToClient";
    public static final String ON_SEARCH_ENDPOINT = "/on_search";



    // BROKER CONFIG
    public static final String DESTINATION = "/client";
    public static final String BROKER = "/user/queue/specific-user";
    public static final String USER_DESTINATION_PREFIX = "/user";
    public static final String APPLICATION_DESTINATION_PREFIX = "/eua";


    // RABBIT MQ CONFIG
    public static final String QUEUE_EUA_TO_GATEWAY = "search_queue";
    public static final String QUEUE_GATEWAY_TO_EUA = "on_search_queue";
    public static final String EXCHANGE = "eua_exchange";
    public static final String ROUTING_KEY_EUA_TO_GATEWAY = "search_routingKey";
    public static final String ROUTING_KEY_GATEWAY_TO_EUA = "on_search_routingKey";


    public static final Object HEALTH_ID_NO_PATTERN = "^[0-9]{2}-*[0-9]{4}-*[0-9]{4}-*[0-9]{4}$";

    public static final String NACK_RESPONSE = "{ \"message\": { \"ack\": { \"status\": \"NACK\" } }, \"error\": { \"type\": \"\", \"code\": \"500\", \"path\": \"string\", \"message\": \"Something went wrong\" } }";
    public static final String ACK_RESPONSE = "{ \"message\": { \"ack\": { \"status\": \"ACK\" } }, \"error\": { \"type\": \"\", \"code\": \"\", \"path\": \"\", \"message\": \"\" } }";

    public static final String QUEUE_SPECIFIC_USER = "/queue/specific-user";
    public static final String BOOKING_SERVICE_URL = "http://100.65.158.41:3030/api/v1/bookingService";
    public static final String GATEWAY_URL = "http://100.65.158.41:8083/api/v1";
    public static final String EUA_URL = "http://100.65.158.41:8901/api/v1/euaService";



    public static final String EUA_CLIENT_DESCRIPTION = """
            UHI(Unified Health Interface) is envisioned as an open protocol for various digital health services. UHI Network will be an open network of End User Applications (EUAs) and participating Health Service Provider (HSP) applications. UHI will enable a wide variety of digital health services between patients and health service providers (HSPs) including appointment booking, teleconsultation, service discovery and others. This is a reference application for EUA client. This set Apis focuses on user login and registration. 
            
            <b>API Security</b></br>
            JWE (JSON WEB ENCRYPTION). Requests shall be encrypted using JWE.

            <b>Gateway Signing</b></br>
            The BG will send its signature in the Proxy-Authorization header in the exact same format as shown below -

            <b>X-Gateway-Authorization:</b></br>
            Signature keyId="{subscriber_id}|{unique_key_id}|{algorithm}" algorithm="xed25519" created="1606970629" expires="1607030629" headers="(created) (expires) digest" signature="Base64(BLAKE-512(signing string))"

            The EUAs and HSPAs subscriber is expected to send an Authorization header (as defined in RFC 7235, Section 4.1) where the “auth-scheme” is “Signature” and the “auth-param” parameters
            Below is the format of a EUA/HSPA Authorization header in the typical HTTP Signature format -

            <b>Authorization:</b></br>
            Signature keyId ="{subscriber_id}|{unique_key_id}|{algorithm}" algorithm="xed25519" created="1606970629" expires="1607030629" headers="(created) (expires) digest" signature="Base64(BLAKE-512(signing string))"

            <b>Hashing Algorithm</b></br>
            For computing the digest of the request body, the hashing function will use the BLAKE-512 hashing algorithm. BLAKE is a cryptographic hash function based on Dan Bernstein’s ChaCha stream cipher. For more documentation on the BLAKE-512 algorithm, please go to RFC7693.

            <b>Signing Algorithm</b></br>
            To digitally sign the singing string, the subscribers should use the “XEdDSA” signature scheme (or “XEd25519”). For the first version of beckn networks, we’ll be using the XEd25519 Signature Scheme.""";
    public static final String OTP_DURATION = "10";
}
