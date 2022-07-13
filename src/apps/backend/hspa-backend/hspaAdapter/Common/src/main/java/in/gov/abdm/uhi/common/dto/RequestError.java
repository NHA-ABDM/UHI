package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import in.gov.abdm.uhi.common.dto.Context;
import in.gov.abdm.uhi.common.dto.RequestSuper;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.MessageAck;

@JsonIgnoreProperties(ignoreUnknown = true)
@AllArgsConstructor
@NoArgsConstructor
@Data
public class RequestError extends RequestSuper {

    private Error error;
    private MessageAck message;

}
