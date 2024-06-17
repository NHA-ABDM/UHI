package in.gov.abdm.uhi.hspa.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class JoinMeetingResponseDTO {
    private String meetLink;
    private boolean is_scheduled_link;
    private String meetingName;
    private String meeting_date;
    private String start_time;
    private String end_time;
}
