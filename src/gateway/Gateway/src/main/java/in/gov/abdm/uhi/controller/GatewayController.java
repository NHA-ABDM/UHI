package in.gov.abdm.uhi.controller;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GatewayController {
	
	@PostMapping(value="/defaultFallback",produces= MediaType.APPLICATION_JSON_VALUE)
	public String defaultMessage() {
		return """
				{\r
				    "error": {},\r
				    "message": {\r
				        "ack": {\r
				            "status": "ACK"\r
				        }\r
				    }\r
				}""";
	}
}
