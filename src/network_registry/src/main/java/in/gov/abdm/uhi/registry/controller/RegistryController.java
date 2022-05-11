package in.gov.abdm.uhi.registry.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import in.gov.abdm.uhi.registry.dto.LookupDto;
import in.gov.abdm.uhi.registry.dto.SubscribeResponseDto;
import in.gov.abdm.uhi.registry.entity.Subscriber;
import in.gov.abdm.uhi.registry.exception.ResourceNotFoundException;
import in.gov.abdm.uhi.registry.service.SubscriberService;
import in.gov.abdm.uhi.registry.serviceImpl.SubscriberServiceImpl;

@RestController
@RequestMapping("/api")
public class RegistryController {

	@Autowired
	SubscriberServiceImpl subscriberServie;

	@PostMapping(value = "/subscribe", consumes = "Application/Json", produces = "Application/Json")
	public ResponseEntity<SubscribeResponseDto> createSubscriber(@RequestBody Subscriber subscriberData) {
		subscriberServie.addSubscriber(subscriberData);
		return new ResponseEntity<SubscribeResponseDto>(new SubscribeResponseDto("INITIATED"), HttpStatus.OK);
	}

	@PostMapping(value = "/lookup")
	public List<Subscriber> lookup(@RequestBody LookupDto requestData) {
		return subscriberServie.lookup(requestData);
	}

	@PutMapping(value = "/update", consumes = "Application/Json", produces = "Application/Json")
	public ResponseEntity<Subscriber> updateSubscriber(@RequestBody Subscriber subscriberData) {
		return new ResponseEntity<Subscriber>(subscriberServie.updateSubscriber(subscriberData), HttpStatus.OK);
	}

	@GetMapping("/subscribe")
	public List<Subscriber> findAllSubscribers() {
		return subscriberServie.findAll();
	}

	@DeleteMapping("/delete/{subscriberId}")
	public Integer deleteSubscriber(@PathVariable String subscriberId) {
		return subscriberServie.deleteSubscriber(subscriberId);
		
	}
	
	@GetMapping("/subscriber/{subscriberId}")
	public Subscriber findBySubscriberId(@PathVariable String subscriberId) {
		Subscriber findSubscriber = subscriberServie.findSubscriber(subscriberId);
		if(findSubscriber==null) {
			throw new ResourceNotFoundException();
		}
		System.out.println(findSubscriber);
		return findSubscriber;
		
	}
	
}