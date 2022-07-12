package in.gov.abdm.uhi.discovery.utility;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.common.dto.Ack;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.MessageAck;
import in.gov.abdm.uhi.common.dto.Response;
import reactor.core.publisher.Mono;

@Component
public class GatewayUtility {
	private static final Logger LOGGER = LoggerFactory.getLogger(GatewayUtility.class);

	public Mono<Response> generateNack(Throwable error) {

		MessageAck msz = new MessageAck();
		Response resp = new Response();
		Ack ack = new Ack();
		ack.setStatus(GlobalConstants.NACK);
		msz.setAck(ack);
		Error err = new Error();
		err.setMessage(error.getMessage());
		err.setPath("/service/RequesterService");
		resp.setError(err);
		resp.setMessage(msz);
		return Mono.just(resp);

	}
	
	public Mono<String> generateNack(String message,String path, int code, String type) {

		MessageAck msz = new MessageAck();
		Response resp = new Response();
		Ack ack = new Ack();
		ack.setStatus(GlobalConstants.NACK);
		msz.setAck(ack);
		Error err = new Error();
		err.setMessage(message);
		err.setPath(path);
		err.setCode(code+"");
		err.setType(type);
		resp.setError(err);
		resp.setMessage(msz);
		return JsonWriter.write(resp);

	}
	
	public String generateAck() {

		MessageAck msz = new MessageAck();
		Response resp = new Response();
		Ack ack = new Ack();
		ack.setStatus(GlobalConstants.ACK);
		msz.setAck(ack);
		Error err = new Error();
		resp.setError(err);
		resp.setMessage(msz);
		String res="";
		try {
			res = new ObjectMapper().writeValueAsString(resp);
		} catch (JsonProcessingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			LOGGER.error("{}: Error in parsing request", e.getClass());
		}
		return res;
	}
	
	public Mono<Response> getErrorMsz(Error err) {
		Mono<Response> ErrorMessage_CircuitBreaker = null;
		try {
			Response req = new Response();
			req.setError(err);
			ErrorMessage_CircuitBreaker = Mono.just(req);
		} catch (Exception e) {
			e.getStackTrace();
		}
		return ErrorMessage_CircuitBreaker;
	}
}
