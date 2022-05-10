package in.gov.abdm.uhi.discovery.service.beans;

public class Error {
	
	public Error(String type, String code, String path, String message) {
		super();
		this.type = type;
		this.code = code;
		this.path = path;
		this.message = message;
	}

	private String type;
	private String code;
	private String path;
	private String message;

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
}
