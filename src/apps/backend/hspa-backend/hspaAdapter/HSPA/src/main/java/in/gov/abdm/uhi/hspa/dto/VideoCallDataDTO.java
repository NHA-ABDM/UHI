package in.gov.abdm.uhi.hspa.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@lombok.Data
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class VideoCallDataDTO {
    private String meeting_code;
    private String meetingName;
    private String moderator_name;
    private String moderator_mobile;
    private String createDate;
    private boolean is_scheduled_link;
    private String meeting_date;
    private String start_time;
    private String end_time;
}
