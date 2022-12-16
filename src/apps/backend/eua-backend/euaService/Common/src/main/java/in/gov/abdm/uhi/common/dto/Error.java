package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class Error {
    private String type;
    private String code;
    private String path;
    private String message;
    public Error() {
        super();
    }


    public Error(String type, String code, String path, String message) {
        super();
        this.type = type;
        this.code = code;
        this.path = path;
        this.message = message;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    @Override
    public String toString() {
        return "Error [type=" + type + ", code=" + code + ", path=" + path + ", message=" + message + "]";
    }


}
