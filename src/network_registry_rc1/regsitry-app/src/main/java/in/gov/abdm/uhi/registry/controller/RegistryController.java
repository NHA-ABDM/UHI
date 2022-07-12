package in.gov.abdm.uhi.registry.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

import in.gov.abdm.uhi.registry.dto.ErrorDetails;
import in.gov.abdm.uhi.registry.dto.KeyDto;
import in.gov.abdm.uhi.registry.dto.LookupDto;
import in.gov.abdm.uhi.registry.dto.SubscribeResponseDto;
import in.gov.abdm.uhi.registry.dto.SubscriberDto;
import in.gov.abdm.uhi.registry.entity.ListofSubscribers;
import in.gov.abdm.uhi.registry.entity.Subscriber;
import in.gov.abdm.uhi.registry.exception.ResourceNotFoundException;
import in.gov.abdm.uhi.registry.service.SubscriberService;
import in.gov.abdm.uhi.registry.serviceImpl.SubscriberServiceImpl;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
@Api(tags = "Registry", value = "Registry")
public class RegistryController {

	@Autowired
	SubscriberServiceImpl subscriberServie;
	private static final Logger logger = LogManager.getLogger(RegistryController.class);

	
	@PostMapping(value = "/subscribe", consumes = "Application/Json", produces = "Application/Json")
	@ApiOperation(value = "Create  new subscriber")

	       
		public ResponseEntity<SubscribeResponseDto> createSubscriber(@RequestBody SubscriberDto subscriberData) {
		System.out.println("ssss:" + subscriberData);
		subscriberServie.addSubscriber(subscriberData);

		logger.info("createSubscriber() method:" + subscriberData);
		return new ResponseEntity<SubscribeResponseDto>(new SubscribeResponseDto("INITIATED"), HttpStatus.OK);
	}

	@ApiOperation(value = "Lookup service")
	@ApiResponses(value = { @ApiResponse(code = 404, message = "Subscriber does not exist", response = ErrorDetails.class),
			@ApiResponse(code = 200, message = "Ok", response = Subscriber.class)})
	@PostMapping(value = "/lookup", consumes = "Application/Json", produces = "Application/Json")
	public ResponseEntity<String> lookup(@RequestBody LookupDto requestData) {
		logger.info("lookup() method:" + requestData);
		return new ResponseEntity<String>(subscriberServie.lookup(requestData), HttpStatus.OK);
	}

	@ApiOperation(value = "Update existing subscriber")
	@ApiResponses(value = { @ApiResponse(code = 404, message = "Subscriber does not exist", response = ErrorDetails.class),
			@ApiResponse(code = 200, message = "Ok", response = SubscriberDto.class)})
	@PutMapping(value = "/update", consumes = "Application/Json", produces = "Application/Json")
	public ResponseEntity<SubscriberDto> updateSubscriber(@RequestBody SubscriberDto subscriberData) {
		logger.info("updateSubscriber() method:" + subscriberData);
		return new ResponseEntity<SubscriberDto>(subscriberServie.updateSubscriber(subscriberData), HttpStatus.OK);
	}

		@ApiOperation(value = "Find all existing subscriber")
		@ApiResponses(value = {@ApiResponse(code = 200, message = "Ok", response = SubscriberDto.class)})
	@GetMapping("/subscribe")
	public List<SubscriberDto> findAllSubscribers() {
		List<SubscriberDto> subscriberList = subscriberServie.findAll();
		logger.info("findAllSubscribers() method:" + subscriberList);
		return subscriberList;
	}

	@DeleteMapping("/delete/{id}")
	@ApiOperation(value = "Delete existing  subscriber by id")
	@ApiResponses(value = { @ApiResponse(code = 404, message = "Subscriber does not exist", response = ErrorDetails.class),
			@ApiResponse(code = 200, message = "Ok")})
	public void deleteSubscriber(@PathVariable Integer id) {
		logger.info("deleteSubscriber() method:" + id);
		subscriberServie.deleteSubscriber(id);
		//return new ResponseEntity<String>("Deleted id:" + id, HttpStatus.OK);
	}

	@GetMapping("/subscriber/{id}")
	@ApiOperation(value = "Find all subscriber  by id")
	@ApiResponses(value = { @ApiResponse(code = 404, message = "Subscriber does not exist", response = ErrorDetails.class),
			@ApiResponse(code = 200, message = "Ok", response = SubscriberDto.class)})
	public SubscriberDto findBySubscriberId(@PathVariable Integer id) {
		logger.info("findBySubscriberId() method:" + id);
		SubscriberDto findSubscriber = subscriberServie.findSubscriber(id);
		if (findSubscriber == null) {
			throw new ResourceNotFoundException();
		}
		System.out.println(findSubscriber);
		return findSubscriber;

	}
	@ApiOperation(value = "Change subscriber status  by id")
	@ApiResponses(value = { @ApiResponse(code = 404, message = "Subscriber does not exist", response = ErrorDetails.class),
			@ApiResponse(code = 200, message = "Ok", response = SubscribeResponseDto.class)})
	@PutMapping("/subscriber/{id}")
	public ResponseEntity<SubscribeResponseDto> changeSubscriberStatus(@PathVariable Integer id,
			@RequestBody String status) {
		logger.info("changeSubscriberStatus() method:" + id);
		return new ResponseEntity<SubscribeResponseDto>(subscriberServie.changeStatus(id, status), HttpStatus.OK);
	}

	@ApiOperation(value = "Get  subscriber keys   by subscriber-id")
	@ApiResponses(value = { @ApiResponse(code = 404, message = "Subscriber does not exist", response = KeyDto.class),
			@ApiResponse(code = 200, message = "Ok", response = SubscribeResponseDto.class)})
	
	@GetMapping("/keys/{subscriberId}")
	public ResponseEntity<List<KeyDto>> getSubscriberKeys(@PathVariable String subscriberId) {
		return new ResponseEntity<List<KeyDto>>(subscriberServie.getSubscriberKeys(subscriberId), HttpStatus.OK);
	}

}