package in.gov.abdm.uhi.discovery.service;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.discovery.configuration.AppConfig;
import in.gov.abdm.uhi.discovery.dto.ErrorCode;
import in.gov.abdm.uhi.discovery.dto.ListofSubscribers;
import in.gov.abdm.uhi.discovery.exception.GatewayException;
import in.gov.abdm.uhi.discovery.security.SignatureUtility;
import in.gov.abdm.uhi.discovery.utility.GatewayUtility;
import in.gov.abdm.uhi.discovery.utility.GlobalConstants;
import reactor.core.publisher.Mono;

@Service
public class HSPAService {
	
	@Autowired
	AppConfig appConfig;

	@Autowired
	GatewayUtility gatewayUtil;

	@Autowired
	WebClient getWebClient;

	@Autowired
	SignatureUtility signatureUtility;
	
	@Value("${spring.application.isHeaderEnabled}")
	Boolean isHeaderEnabled;

	private static final Logger LOGGER = LoggerFactory.getLogger(HSPAService.class);

	Mono<String> checklookupforHSPAs(String res, Request req, String req2) {
		if (res.contains("Failed")) {
			Mono<String> resp = gatewayUtil.generateNack(GlobalConstants.LOOKUP_FAILED,
					"/" + RequesterService.class.getSimpleName(), ErrorCode.LOOKUP_FAILED.getValue(), "");
			LOGGER.error("{} | {}", req.getContext().getMessageId(), resp.log());
			return resp;
		} else {
			Mono<String> data = Mono.just(res);
			return data.flatMapIterable(p -> extractURIListNew(p, req))
					.flatMap(uris -> sendSingletoHSPANew(uris, req, req2)).then(Mono.just(gatewayUtil.generateAck()))
					.log();
		}
	}

	private List<String> extractURIListNew(String request, Request req) {

		List<String> listValue = new ArrayList<String>();
		try {
			ListofSubscribers listOfSubscribers = null;
			listOfSubscribers = appConfig.objectMapper().readValue(request, ListofSubscribers.class);

			listOfSubscribers.message.forEach(data -> {
				if (GlobalConstants.HSPA.equalsIgnoreCase(data.getType())) {
					listValue.add(data.getSubscriber_url() + "|" + data.getSubscriber_id());
					LOGGER.info("{} | {}", req.getContext().getMessageId(), data);
				}
			});
		} catch (Exception ex) {
			LOGGER.error(ex.getMessage());
		}
		return listValue;
	}

	private Mono<String> sendSingletoHSPANew(String uri_subsid, Request req, String req2) {

		Map<String, String> headers = getHspaHeaders(req, req2);
		String headersString = String.valueOf(headers);
		headersString = headersString.replaceAll("\\{", "").replaceAll("\\}", "");

		String[] uri_subsid_arr = uri_subsid.split("\\|");
		String uri = uri_subsid_arr[0];

		LOGGER.info("{} | RequesterService::info::sending Request to HSPA::{}", req.getContext().getMessageId(), uri);

		Mono<String> response = null;
		try {
			response = getWebClient.post().uri(uri + "/search")
					.header("X-Gateway-Authorization", isHeaderEnabled ? headersString : "")					//.header("X-Gateway-Authorization", headersString)
					.contentType(MediaType.APPLICATION_JSON)
					.body(BodyInserters.fromValue(req)).retrieve()
					.onStatus(HttpStatus::is4xxClientError,
							resp -> resp.bodyToMono(String.class)
									.flatMap(error -> Mono.error(new GatewayException(error))))
					.onStatus(HttpStatus::is5xxServerError,
							resp -> resp
									.bodyToMono(String.class).flatMap(error -> Mono.error(new GatewayException(error))))
					.bodyToMono(String.class)
					.doOnNext(p -> LOGGER.info(
							"created_on:{}, transaction_id:{}, message_id:{}, consumer_id:{}, provider_id:{}, domain:{}, city:{}, action:{}, Response:{}",
							new Timestamp(System.currentTimeMillis()), req.getContext().getTransactionId(),
							req.getContext().getMessageId(), req.getContext().getConsumerId(), uri_subsid_arr[1],
							req.getContext().getDomain(), req.getContext().getCity(), req.getContext().getAction(), p))
					.onErrorResume(error -> {
						LOGGER.error(
								"RequesterService::error::onErrorResume::created_on:{}, transaction_id:{}, message_id:{}, consumer_id:{}, provider_id:{}, domain:{}, city:{}, action:{}, Error:{}",
								new Timestamp(System.currentTimeMillis()), req.getContext().getTransactionId(),
								req.getContext().getMessageId(), req.getContext().getConsumerId(), uri_subsid_arr[1],
								req.getContext().getDomain(), req.getContext().getCity(), req.getContext().getAction(),
								error);
						return gatewayUtil.generateNack("HSPA exception", "/" + RequesterService.class.getSimpleName(),
								ErrorCode.HSPA_FAILED.getValue(), "");
					}).log();
		} catch (Exception ex) {
			response = Mono.empty();
			LOGGER.error("{} | RequesterService::error::catchBlock::{}", req.getContext().getMessageId(),
					ex.getMessage());
		}
		return response;
	}

	public Map<String, String> getHspaHeaders(Request req, String reqString) {
		return signatureUtility.generateAuthParams(req, reqString);

	}
}
