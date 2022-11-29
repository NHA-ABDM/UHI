package in.gov.abdm.uhi.controller;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GatewayController {
	
	@PostMapping("/defaultFallback")
	public String defaultMessage() {
		//return "There were some error in connecting. Please try again later.";
		String resp = "{\r\n"
				+ "    \"error\": {},\r\n"
				+ "    \"message\": {\r\n"
				+ "        \"ack\": {\r\n"
				+ "            \"status\": \"ACK\"\r\n"
				+ "        }\r\n"
				+ "    }\r\n"
				+ "}";
		return resp;
	}
}
