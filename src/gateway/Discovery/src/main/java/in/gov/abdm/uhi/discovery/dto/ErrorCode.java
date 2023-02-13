package in.gov.abdm.uhi.discovery.dto;
 

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import java.util.Arrays;

public enum ErrorCode {
	AUTH_HEADER_NOT_FOUND(1401),
	LOOKUP_FAILED(1402),
	HSPA_FAILED(1403),
	INVALID_REQUEST(1404),
	INVALID_SIGNATURE(1405),
	EUA_NOT_REGISTERED(1406),
	INTERNAL_SERVER_ERROR(1407),
	HEADER_VERFICATION_FAILED(1408),
	EUA_EXCEPTION(1409),
	UNKNOWN_ERROR_OCCURRED(1500);

    private final int value;

    ErrorCode(int val) {
        value = val;
    }

    // Adding @JsonValue annotation that tells the 'value' to be of integer type while de-serializing.
    @JsonValue
    public int getValue() {
        return value;
    }

    @JsonCreator
    public static ErrorCode getNameByValue(int value) {
        return Arrays.stream(ErrorCode.values())
                .filter(errorCode -> errorCode.value == value)
                .findAny()
                .orElse(ErrorCode.UNKNOWN_ERROR_OCCURRED);
    }
}
