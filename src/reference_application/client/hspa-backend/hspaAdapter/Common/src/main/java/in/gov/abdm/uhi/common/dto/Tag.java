package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.util.ArrayList;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
public class Tag {

    public ArrayList<String> spoken_langs;
    public ArrayList<String> education;
    public String speciality;
    public String expr;

}
