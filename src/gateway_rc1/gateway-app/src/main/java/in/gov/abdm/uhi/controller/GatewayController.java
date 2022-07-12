package in.gov.abdm.uhi.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GatewayController {
	
	@PostMapping("/defaultFallback")
	public String defaultMessage() {
		return "There were some error in connecting. Please try again later.";
	}
}
