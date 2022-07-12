package in.gov.abdm.uhi.registry.controller;

import java.util.Random;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import in.gov.abdm.uhi.registry.dto.OnSubscribeDto;
import in.gov.abdm.uhi.registry.dto.OnSubscribeResponseDto;
import io.swagger.annotations.Api;

@RestController
@RequestMapping("/api")
@Api(tags = "Subscriber", value = "Subscriber")
public class SubscriberController {
	
	@PostMapping(value = "/on_subscribe", consumes = "Application/Json", produces = "Application/Json")
	public ResponseEntity<OnSubscribeResponseDto> onSubscriber(@RequestBody OnSubscribeDto onSubscribeDto) {
		
		
		//subscriberServie.addSubscriber(subscriberData);
		System.out.println(onSubscribeDto);
		return new ResponseEntity<OnSubscribeResponseDto>(new OnSubscribeResponseDto ("decrypted_challange_string"), HttpStatus.OK);
	}
	
	
}
