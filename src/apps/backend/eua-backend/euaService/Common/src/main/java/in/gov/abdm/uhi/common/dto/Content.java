package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
public class Content {

    private String content_id;
    private String content_value;
    private String content_type;
    private String content_url;
    @JsonProperty("content_filename")
    @JsonAlias("content_filename")
    private String content_filename;
    @JsonProperty("content_mimetype")
    @JsonAlias("content_mimetype")
    private String content_mimetype;
}

