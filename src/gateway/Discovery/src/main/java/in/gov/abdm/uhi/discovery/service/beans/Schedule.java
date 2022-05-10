package in.gov.abdm.uhi.discovery.service.beans;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.JsonNode;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class Schedule {
    private String frequency;
    private JsonNode holidays;
    private JsonNode times;

    public String getFrequency() {
        return frequency;
    }

    public void setFrequency(String frequency) {
        this.frequency = frequency;
    }

    public JsonNode getHolidays() {
        return holidays;
    }

    public void setHolidays(JsonNode holidays) {
        this.holidays = holidays;
    }

    public JsonNode getTimes() {
        return times;
    }

    public void setTimes(JsonNode times) {
        this.times = times;
    }

    @Override
    public String toString() {
        return "Schedule{" +
                "frequency='" + frequency + '\'' +
                ", holidays=" + holidays +
                ", times=" + times +
                '}';
    }
}
