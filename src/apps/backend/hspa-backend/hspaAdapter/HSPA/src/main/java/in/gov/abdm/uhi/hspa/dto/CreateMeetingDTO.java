package in.gov.abdm.uhi.hspa.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CreateMeetingDTO {
    private String moderator_name;
    private String moderator_mobile;
    private String meeting_name;
    private String meeting_date;
    private String start_time;
    private String end_time;
    private boolean is_scheduled_link;
}