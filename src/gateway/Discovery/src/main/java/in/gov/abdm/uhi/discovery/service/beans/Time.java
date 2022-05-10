package in.gov.abdm.uhi.discovery.service.beans;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class Time {
    private String label;
    private String timestamp;
    private String duration;
    private Range range;
    private String days;
    private Schedule schedule;

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getDuration() {
        return duration;
    }

    public void setDuration(String duration) {
        this.duration = duration;
    }

    public Range getRange() {
        return range;
    }

    public void setRange(Range range) {
        this.range = range;
    }

    public String getDays() {
        return days;
    }

    public void setDays(String days) {
        this.days = days;
    }

    public Schedule getSchedule() {
        return schedule;
    }

    public void setSchedule(Schedule schedule) {
        this.schedule = schedule;
    }


    @Override
    public String toString() {
        return "Time{" +
                "label='" + label + '\'' +
                ", timestamp='" + timestamp + '\'' +
                ", duration='" + duration + '\'' +
                ", range=" + range +
                ", days='" + days + '\'' +
                ", schedule=" + schedule +
                '}';
    }
}
