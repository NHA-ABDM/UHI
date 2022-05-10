package in.gov.abdm.uhi.discovery.service.beans;

public class Response {
	private MessageAck message;
	private Error error;

	public MessageAck getMessage() {
		return message;
	}

	public void setMessage(MessageAck message) {
		this.message = message;
	}

	public Error getError() {
		return error;
	}

	public void setError(Error error) {
		this.error = error;
	}
}
