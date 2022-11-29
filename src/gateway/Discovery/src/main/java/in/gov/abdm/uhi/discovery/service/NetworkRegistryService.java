package in.gov.abdm.uhi.discovery.service;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.client.circuitbreaker.ReactiveCircuitBreakerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Context;
import in.gov.abdm.uhi.discovery.entity.ErrorCode;
import in.gov.abdm.uhi.discovery.entity.RequestRoot;
import in.gov.abdm.uhi.discovery.entity.Subscriber;
import in.gov.abdm.uhi.discovery.security.SignatureUtility;
import in.gov.abdm.uhi.discovery.utility.GatewayUtility;
import in.gov.abdm.uhi.discovery.utility.GlobalConstants;
import reactor.core.publisher.Mono;

@Service
public class NetworkRegistryService {

	private static final Logger LOGGER = LoggerFactory.getLogger(NetworkRegistryService.class);

	public static final String searchAPI = "/search";
	public static final String lookupAPI = "/lookup";

	@Autowired
	GatewayUtility gatewayUtil;

	@Autowired
	SignatureUtility signatureUtility;

	@Autowired
	private ReactiveCircuitBreakerFactory circuitBreakerFactory;

	@Autowired
	WebClient getWebClient;

	@Value("${spring.application.registryurl}")
	String registry_url;

	@Autowired
	HSPAService HSPAService;

	Mono<String> validateParticipant(RequestRoot request, Map<String, String> params, Map<String, String> headers,
			String req, String subs2) {
		ObjectMapper mapper = new ObjectMapper();
		Mono<String> result = null;
		try {
			Subscriber subs = mapper.readValue(subs2, Subscriber.class);
			if (!request.getContext().getConsumerId().equalsIgnoreCase(subs.getSubscriber_id())) {
				LOGGER.info("EUA validation failed.");
				result = gatewayUtil.generateNack("EUA NOT REGISTERED. PLS GET YOUR EUA REGISTERED.",
						"/" + RequesterService.class.getSimpleName(), ErrorCode.EUA_NOT_REGISTERED.getValue(), "");
			} else {
				LOGGER.info("{} | EUA validation success", request.getContext().getMessageId());
				try {
					if (signatureUtility.verifySign(request, headers, req.trim(), subs)) {
						Mono<String> getData = circuitBreakerWrapper(request);
						return getData.flatMap(result1 -> HSPAService.checklookupforHSPAs(result1, request, subs2));
					} else {
						LOGGER.info("{} | Header verification failed", request.getContext().getMessageId());
						result = gatewayUtil.generateNack("HEADER VARIFICATION FAILED",
								"/" + RequesterService.class.getSimpleName(),
								ErrorCode.HEADER_VERFICATION_FAILED.getValue(), "");
					}
				} catch (NumberFormatException | InvalidKeyException | NoSuchAlgorithmException
						| NoSuchProviderException | SignatureException e) {
					LOGGER.error("{} | InvalidKeyException in Header verification",
							request.getContext().getMessageId());
					result = gatewayUtil.generateNack("INTERNAL SERVER ERROR",
							"/" + RequesterService.class.getSimpleName(), ErrorCode.INTERNAL_SERVER_ERROR.getValue(),
							"");
				}

			}
		} catch (JsonProcessingException e) {
			LOGGER.error("{} | JsonProcessingException in Header verification", request.getContext().getMessageId());
			e.printStackTrace();
			result = gatewayUtil.generateNack("INTERNAL SERVER ERROR", "/" + RequesterService.class.getSimpleName(),
					ErrorCode.INTERNAL_SERVER_ERROR.getValue(), "");
		}
		return result;
	}

	Mono<String> getParticipantsDetails(Context context, Map<String, String> params) {
		Subscriber subscriber = new Subscriber();
		subscriber.setSubscriber_id(params.get("subscriber_id"));
		subscriber.setPub_key_id(params.get("pub_key_id"));
		subscriber.setType(GlobalConstants.EUA);
		subscriber.setStatus(GlobalConstants.SUBSCRIBED);
		return getWebClient.post().uri(registry_url + searchAPI).body(BodyInserters.fromValue(subscriber)).retrieve()
				.bodyToMono(String.class)
				.doOnSubscribe(
						subscription -> LOGGER.info("{} | About to call Network Registry to find EUA details URL:{}",
								context.getMessageId(), registry_url + searchAPI))
				.doOnNext(p -> LOGGER.info("Response|{}", p)).onErrorResume(error -> {
					LOGGER.error("RequesterService::error::getParticipantsDetails::{}", error);
					return gatewayUtil.generateNack("Failed Lookup", "/" + RequesterService.class.getSimpleName(),
							ErrorCode.LOOKUP_FAILED.getValue(), "");
				});
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

		return getWebClient.post().uri(registry_url + lookupAPI).body(BodyInserters.fromValue(subscriber)).retrieve()
				.bodyToMono(String.class)
				.doOnSubscribe(
						subscription -> LOGGER.info("{} | About to call Network Registry to find list of HSPAs URL:{}",
								body.getContext().getMessageId(), registry_url + lookupAPI))
				//.doOnNext(p -> LOGGER.info("Response|{}", p))
				.onErrorResume(error -> {
					LOGGER.error("RequesterService::error::sendSingletoLookup::" + error);
					return gatewayUtil.generateNack("Failed Lookup", "/" + RequesterService.class.getSimpleName(),
							ErrorCode.LOOKUP_FAILED.getValue(), "");
				});
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
}
