package in.gov.abdm.uhi.discovery.service.beans;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Tags {
    @JsonProperty("./dhp-0_7_1.symptoms")
    private String symptoms;
    @JsonProperty("./dhp-0_7_1.temperature\"")
    private String temperature;

    public String getSymptoms() {
        return symptoms;
    }

    public void setSymptoms(String symptoms) {
        this.symptoms = symptoms;
    }

    public String getTemperature() {
        return temperature;
    }

    public void setTemperature(String temperature) {
        this.temperature = temperature;
    }

    @Override
    public String toString() {
        return "Tags{" +
                "symptoms='" + symptoms + '\'' +
                ", temperature='" + temperature + '\'' +
                '}';
    }
}
