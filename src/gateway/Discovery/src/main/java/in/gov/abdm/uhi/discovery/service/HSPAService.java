package in.gov.abdm.uhi.discovery.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.discovery.entity.ErrorCode;
import in.gov.abdm.uhi.discovery.entity.ListofSubscribers;
import in.gov.abdm.uhi.discovery.entity.RequestRoot;
import in.gov.abdm.uhi.discovery.exception.GatewayException;
import in.gov.abdm.uhi.discovery.security.SignatureUtility;
import in.gov.abdm.uhi.discovery.utility.GatewayUtility;
import in.gov.abdm.uhi.discovery.utility.GlobalConstants;
import reactor.core.publisher.Mono;

@Service
public class HSPAService {

	@Autowired
	GatewayUtility gatewayUtil;

	@Autowired
	WebClient getWebClient;
	
	@Autowired
	SignatureUtility signatureUtility;

	private static final Logger LOGGER = LoggerFactory.getLogger(HSPAService.class);

	Mono<String> checklookupforHSPAs(String res, RequestRoot req, String req2) {
		if (res.contains("Failed")) {
			Mono<String> resp = gatewayUtil.generateNack(GlobalConstants.LOOKUP_FAILED,
					"/" + RequesterService.class.getSimpleName(), ErrorCode.LOOKUP_FAILED.getValue(), "");
			LOGGER.error("{} | {}", req.getContext().getMessageId(), resp.log());
			return resp;
		} else {
			Mono<String> data = Mono.just(res);
			return data.flatMapIterable(p -> extractURIListNew(p, req)).flatMap(uris -> sendSingletoHSPANew(uris, req, req2))
					.then(Mono.just(gatewayUtil.generateAck())).log();
		}
	}

	private List<String> extractURIListNew(String request, RequestRoot req) {

		List<String> listValue = new ArrayList<String>();
		ObjectMapper obj = new ObjectMapper();
		try {
			ListofSubscribers listOfSubscribers = null;
			listOfSubscribers = obj.readValue(request, ListofSubscribers.class);

			listOfSubscribers.message.forEach(data -> {
				if (GlobalConstants.HSPA.equalsIgnoreCase(data.getType())) {
					listValue.add(data.getUrl());
					LOGGER.info("{} | {}", req.getContext().getMessageId(), data);
				}
			});
		} catch (Exception ex) {
			LOGGER.error(ex.getMessage());
		}
		return listValue;
	}

	private Mono<String> sendSingletoHSPANew(String uri, RequestRoot req, String req2) {

		LOGGER.info("{} | RequesterService::info::sending Request to HSPA::{}", req.getContext().getMessageId(), uri);

		Map<String, String> headers = getHspaHeaders(req,req2);
		 String headersString = String.valueOf(headers);
	        headersString = headersString.replaceAll("\\}","");

		
		Mono<String> response = null;
		try {
			response = getWebClient.post().uri(uri + "/search")
					// .header("X-Gateway-Authorization",
					// isHeaderEnabled?signatureUtility.getGatewayHeaders(req):"")
					.header("X-Gateway-Authorization", headersString)
					.contentType(MediaType.APPLICATION_JSON)
					.body(BodyInserters.fromValue(req)).retrieve()
					.onStatus(HttpStatus::is4xxClientError,
							resp -> resp.bodyToMono(String.class)
									.flatMap(error -> Mono.error(new GatewayException(error))))
					.onStatus(HttpStatus::is5xxServerError,
							resp -> resp.bodyToMono(String.class)
									.flatMap(error -> Mono.error(new GatewayException(error))))
					.bodyToMono(String.class).doOnNext(p -> LOGGER.info("Response|{}", p)).onErrorResume(error -> {
						LOGGER.error("{} RequesterService::error::onErrorResume::{}", req.getContext().getMessageId(),
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

	private Map<String, String> getHspaHeaders(RequestRoot req, String reqString) {
		return signatureUtility.generateAuthParams(req,reqString);
		
	}
}
