package in.gov.abdm.uhi.discovery.service.beans;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.JsonNode;

@JsonInclude(JsonInclude.Include.NON_EMPTY)
public class Descriptor {
    private String name;
    private String code;
    private String symbol;
    private String short_desc;
    private String long_desc;
    private JsonNode images;
    private String audio;

    @JsonProperty("3d_render")
    private String render3d;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getSymbol() {
        return symbol;
    }

    public void setSymbol(String symbol) {
        this.symbol = symbol;
    }

    public String getShort_desc() {
        return short_desc;
    }

    public void setShort_desc(String short_desc) {
        this.short_desc = short_desc;
    }

    public String getLong_desc() {
        return long_desc;
    }

    public void setLong_desc(String long_desc) {
        this.long_desc = long_desc;
    }

    public JsonNode getImages() {
        return images;
    }

    public void setImages(JsonNode images) {
        this.images = images;
    }

    public String getAudio() {
        return audio;
    }

    public void setAudio(String audio) {
        this.audio = audio;
    }

    public String getRender3d() {
        return render3d;
    }

    public void setRender3d(String render3d) {
        this.render3d = render3d;
    }

    @Override
    public String toString() {
        return "Descriptor{" +
                "name='" + name + '\'' +
                ", code='" + code + '\'' +
                ", symbol='" + symbol + '\'' +
                ", short_desc='" + short_desc + '\'' +
                ", long_desc='" + long_desc + '\'' +
                ", images=" + images +
                ", audio='" + audio + '\'' +
                ", render3d='" + render3d + '\'' +
                '}';
    }
}
