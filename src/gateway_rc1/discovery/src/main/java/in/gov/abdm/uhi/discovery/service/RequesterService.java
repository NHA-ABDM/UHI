package in.gov.abdm.uhi.discovery.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.client.circuitbreaker.ReactiveCircuitBreakerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.server.ServerResponse;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Context;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.Response;
import in.gov.abdm.uhi.discovery.entity.ErrorCode;
import in.gov.abdm.uhi.discovery.entity.ListofSubscribers;
import in.gov.abdm.uhi.discovery.entity.RequestRoot;
import in.gov.abdm.uhi.discovery.entity.Subscriber;
import in.gov.abdm.uhi.discovery.exception.GatewayException;
import in.gov.abdm.uhi.discovery.security.SignatureUtility;
import in.gov.abdm.uhi.discovery.utility.GatewayError;
import in.gov.abdm.uhi.discovery.utility.GatewayUtility;
import in.gov.abdm.uhi.discovery.utility.GlobalConstants;
import in.gov.abdm.uhi.discovery.utility.JsonWriter;
import io.vavr.collection.Stream;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
public class RequesterService {

	private static final Logger LOGGER = LoggerFactory.getLogger(RequesterService.class);

	public static final String searchAPI = "/search";
	public static final String lookupAPI = "/lookup";

	@Value("${spring.application.registryurl}")
	String registry_url;

	@Autowired
	private ReactiveCircuitBreakerFactory circuitBreakerFactory;

	@Autowired
	ObjectMapper mapper;

	@Autowired
	GatewayUtility gatewayUtil;

	@Autowired
	SignatureUtility signatureUtility;

	@Value("${spring.application.isHeaderEnabled}")
	Boolean isHeaderEnabled;

	@Value("${spring.application.gateway_pubKey}")
	String gateway_pubKey;

	@Value("${spring.application.gateway_privKey}")
	String gateway_privKey;

	WebClient webClient = WebClient.create();

	public static Subscriber gateway_subs = new Subscriber();

	public Mono<String> processor(@RequestBody RequestRoot request, @RequestHeader Map<String, String> headers,
			String req) throws JsonProcessingException {

		LOGGER.info("{} | authorization |{}", request.getContext().getMessageId(), headers.get("authorization"));

		if (isHeaderEnabled) {
			gateway_subs.setPub_key_id(gateway_pubKey);
			gateway_subs.setEncr_public_key(gateway_privKey);

			if (!headers.containsKey("authorization")) {
				return gatewayUtil.generateNack(GlobalConstants.AUTH_HEADER_NOT_FOUND,
						"/" + RequesterService.class.getSimpleName(), ErrorCode.AUTH_HEADER_NOT_FOUND.getValue(), "")
						.log();
			}
			Boolean verifySign = signatureUtility.verifySign(req, headers);

			if (!verifySign) {
				return gatewayUtil.generateNack(GlobalConstants.SIGN_HEADER_VALIDATION_FAILED,
						"/" + RequesterService.class.getSimpleName(), ErrorCode.INVALID_SIGNATURE.getValue(), "").log();
			}
		}
		Mono<String> getData = circuitBreakerWrapper(request);
		return getData.flatMap(result -> checklookup(result, request));
	}

	private Mono<String> checklookup(String res, RequestRoot req) {
		if (res.contains("Failed")) {
			Mono<String> resp= gatewayUtil.generateNack(GlobalConstants.LOOKUP_FAILED, "/" + RequesterService.class.getSimpleName(),
					ErrorCode.LOOKUP_FAILED.getValue(), "");
			LOGGER.error("{} | {}",req.getContext().getMessageId(),resp.log());
			return resp;
		} else {
			Mono<String> data = Mono.just(res);
			return data.flatMapIterable(p->extractURIListNew(p,req))
					.flatMap(uris -> sendSingletoHSPANew(uris, req))
					.then(Mono.just(gatewayUtil.generateAck())).log();
		}
	}
	private List<String> extractURIListNew(String request, RequestRoot req) {

		List<String> listValue = new ArrayList<String>();
		ObjectMapper obj = new ObjectMapper();
		try {
			ListofSubscribers listOfSubscribers = null;
			listOfSubscribers = obj.readValue(request, ListofSubscribers.class);
			
			List<Subscriber> euaList= listOfSubscribers.message.stream().filter(p->p.getSubscriber_id().equalsIgnoreCase(req.getContext().getConsumerId())).toList();
			if(euaList.size()==1) {
				listOfSubscribers.message.forEach(data -> {
					if(GlobalConstants.HSPA.equalsIgnoreCase(data.getType()))
						listValue.add(data.getUrl());
						LOGGER.info("{} | {}",req.getContext().getMessageId(),data);
					});
			}else {
				 gatewayUtil.generateNack(GlobalConstants.EUA_VALIDATION_FAILED,
						"/" + RequesterService.class.getSimpleName(), ErrorCode.EUA_NOT_REGISTERED.getValue(), "").log();
				 LOGGER.info("{} | {}",req.getContext().getMessageId(),GlobalConstants.EUA_VALIDATION_FAILED);
			}	
		} catch (Exception ex) {
			LOGGER.error(ex.getMessage());
		}
		return listValue;
	}

	public Mono<String> circuitBreakerWrapper(RequestRoot body) throws JsonProcessingException {
		return circuitBreakerFactory.create("lookup").run(sendSingletoLookup(body), t -> {
			LOGGER.error("{} | Lookup called failed {}", body.getContext().getMessageId(), t);
			RequestRoot reqroot = new RequestRoot();
			return Mono.just(reqroot.toString());
		});
	}

	private Mono<String> sendSingletoLookup(RequestRoot body) throws JsonProcessingException {

		Subscriber subscriber = transformSubscriber(body);

		return webClient.post().uri(registry_url + lookupAPI).body(BodyInserters.fromValue(subscriber)).retrieve()
				.bodyToMono(String.class)
				.doOnSubscribe(subscription -> LOGGER.info(
						"{} | About to call Network Registry to find list of subsribers URL:{}",
						body.getContext().getMessageId(), registry_url + lookupAPI))
				.onErrorResume(error -> {
					LOGGER.error("RequesterService::error::sendSingletoLookup::" + error);
					return gatewayUtil.generateNack("Failed Lookup", "/" + RequesterService.class.getSimpleName(),
							ErrorCode.LOOKUP_FAILED.getValue(), "").log();
				}).log();
	}

	private Subscriber transformSubscriber(RequestRoot request) {
		Subscriber subscriber = new Subscriber();
		Context context = request.getContext();
		subscriber.setCountry(context.getCountry());
		subscriber.setCity(context.getCity());
		subscriber.setDomain(context.getDomain());
		subscriber.setStatus(GlobalConstants.SUBSCRIBED);
		return subscriber;
	}

	private Mono<Response> CircuitBreakerError(Error err) {
		ListofSubscribers res = new ListofSubscribers();
		res.message = new ArrayList<>();
		return gatewayUtil.getErrorMsz(err);
	}
	private Mono<Response> sendSingletoHSPANew(String uri, RequestRoot req) {

		LOGGER.info("{} | RequesterService::info::sending Request to HSPA::{}", req.getContext().getMessageId(), uri);

		Mono<Response> response = null;
		try {
				response = webClient.post().uri(uri + "/search")
						 .header("X-Gateway-Authorization", isHeaderEnabled?signatureUtility.getGatewayHeaders(req):"")
						.contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
						.body(BodyInserters.fromValue(req))
						.retrieve()
						.onStatus(HttpStatus::is4xxClientError,
						        resp -> resp.bodyToMono(String.class).flatMap(error -> Mono.error(new GatewayException(error))))
						.onStatus(HttpStatus::is5xxServerError,
						        resp -> resp.bodyToMono(String.class).flatMap(error -> Mono.error(new GatewayException(error))))
						.bodyToMono(Response.class)
						.onErrorResume(error -> {
							LOGGER.error("{} RequesterService::error::onErrorResume::{}",
									req.getContext().getMessageId(), error);
							return gatewayUtil.generateNack(error);
						}).log();
		} catch (Exception ex) {
			response = Mono.empty();
			LOGGER.error("{} | RequesterService::error::catchBlock::{}", req.getContext().getMessageId(), ex.getMessage());
		}
		return response;
	}

}
