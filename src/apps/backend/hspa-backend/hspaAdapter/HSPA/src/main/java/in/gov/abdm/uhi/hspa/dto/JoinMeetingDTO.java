package in.gov.abdm.uhi.hspa.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@AllArgsConstructor
@NoArgsConstructor
public class JoinMeetingDTO {
    private String name;
    private String mobile;
    private String meeting_code;
}
