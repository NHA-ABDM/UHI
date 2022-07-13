package in.gov.abdm.uhi.EUABookingService.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public class MessagesDTO extends ServiceResponseDTO {
    private String contentId;
    private String sender;
    private String receiver;
    private String contentValue;
    private String time;
}