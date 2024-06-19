package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
public class Content {

    private String content_id;
    private String content_value;
    private String content_type;
    @JsonProperty("content_filename")
    @JsonAlias("content_filename")
    private String content_filename;
    @JsonProperty("content_mimetype")
    @JsonAlias("content_mimetype")
    private String content_mimetype;
    private String content_url;
}
