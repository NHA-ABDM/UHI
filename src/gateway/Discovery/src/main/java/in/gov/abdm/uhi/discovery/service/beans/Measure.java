package in.gov.abdm.uhi.discovery.service.beans;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class Measure {
    private String type;
    private long value;
    private long estimated_value;
    private long computed_value;
    private Range range;
    private String unit;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public long getValue() {
        return value;
    }

    public void setValue(long value) {
        this.value = value;
    }

    public long getEstimated_value() {
        return estimated_value;
    }

    public void setEstimated_value(long estimated_value) {
        this.estimated_value = estimated_value;
    }

    public long getComputed_value() {
        return computed_value;
    }

    public void setComputed_value(long computed_value) {
        this.computed_value = computed_value;
    }

    public Range getRange() {
        return range;
    }

    public void setRange(Range range) {
        this.range = range;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    @Override
    public String toString() {
        return "Measure{" +
                "type='" + type + '\'' +
                ", value=" + value +
                ", estimated_value='" + estimated_value + '\'' +
                ", computed_value='" + computed_value + '\'' +
                ", range=" + range +
                ", unit='" + unit + '\'' +
                '}';
    }
}
