package in.gov.abdm.uhi.registry.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum GatewayError {
    AUTH_HEADER_NOT_FOUND("UHI-1401", "Authorization header not found"),
    LOOKUP_FAILED("UHI-1402", "Lookup failed"),
    HSPA_FAILED("UHI-1403", "HSPA failure response"),
    INVALID_REQUEST("UHI-1404", "Bad Request, invalid request Body"),
    INVALID_SIGNATURE("UHI-1405", "Invalid signature"),
    EUA_NOT_REGISTERED("UHI-1406", "EUA not regsitered in Network Registry"),
    HSPA_NOT_REGISTERED("UHI-1406", "HSPA not regsitered in Network Registry"),
    INTERNAL_SERVER_ERROR("UHI-1407", "Internal server error"),

    HEADER_VERFICATION_FAILED("UHI-1408", "Header verification failed"),
    EUA_EXCEPTION("UHI-1409", "EUA failure response"),
    INVALID_KEY("UHI_1410", "Invalid key specification"),
    INVALID_JSON_ERROR("UHI-1411", "Invalid Json passed in either request or header. Kindly check"),
    UNKNOWN_ERROR_OCCURRED("UHI-1500", "Unknown error"),
    PARTICIPANT_VALIDATION_FAILURE("UHI-1412", "Participant failure response. Either partner not registered or Invalid partner"),
    NO_RECORDS_FOUND("UHI-1413", "No Records found");
    private final String code;
    private final String message;
}
