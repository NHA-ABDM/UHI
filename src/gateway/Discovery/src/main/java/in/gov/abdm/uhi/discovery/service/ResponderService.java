
/*
 * Copyright 2022  NHA
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package in.gov.abdm.uhi.discovery.service;

import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.util.Map;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.discovery.configuration.AppConfig;
import in.gov.abdm.uhi.discovery.controller.ResponderController;
import in.gov.abdm.uhi.discovery.dto.ErrorCode;
import in.gov.abdm.uhi.discovery.exception.GatewayException;
import in.gov.abdm.uhi.discovery.security.SignatureUtility;
import in.gov.abdm.uhi.discovery.utility.GatewayUtility;
import reactor.core.publisher.Mono;

@Service
public class ResponderService {

	@Autowired
	SignatureUtility signatureUtility;
	
	@Autowired
	AppConfig appConfig;

	@Autowired
	WebClient getWebClient;

	@Autowired
	GatewayUtility gatewayUtil;

	@Autowired
	HSPAService hspaService;

	@Value("${spring.application.isHeaderEnabled}")
	Boolean isHeaderEnabled;

	private static final Logger LOGGER = LogManager.getLogger(ResponderController.class);
	Request reqroot;

	public Mono<String> processor(String strrequest, @RequestHeader Map<String, String> headers)
			throws URISyntaxException {

		Mono<String> onSearchForward = null;
		String targetURI = "";
		reqroot = new Request();

		try {
			reqroot = appConfig.objectMapper().readValue(strrequest, Request.class);
			if (isHeaderEnabled) {
				/*
				 * if (!headers.containsKey("Authorization")) { return
				 * gatewayUtil.generateNack(GlobalConstants.AUTH_HEADER_NOT_FOUND, "/" +
				 * ResponderService.class.getSimpleName(),
				 * ErrorCode.AUTH_HEADER_NOT_FOUND.getValue(), "").log(); }
				 */
			}
			Map<String, String> auth_headers = hspaService.getHspaHeaders(reqroot, strrequest);
			String headersString = String.valueOf(auth_headers);
			headersString = headersString.replaceAll("\\{", "").replaceAll("\\}", "");
			LOGGER.info("Responder headersString|{}",headersString);

			targetURI = reqroot.getContext().getConsumerUri();
			LOGGER.info("{} | Consumer ID |{}", reqroot.getContext().getMessageId(), targetURI);

			onSearchForward = getWebClient.post().uri(targetURI + "/on_search").contentType(MediaType.APPLICATION_JSON)
					// .accept(MediaType.APPLICATION_JSON)
					.body(BodyInserters.fromValue(strrequest))
					.header("X-Gateway-Authorization", isHeaderEnabled ? headersString : "")
					// .header("X-Gateway-Authorization", "X-Gateway-Authorization")
					.retrieve()
					.onStatus(HttpStatus::is4xxClientError,
							resp -> resp.bodyToMono(String.class)
									.flatMap(error -> Mono.error(new GatewayException(error))))
					.onStatus(HttpStatus::is5xxServerError,
							resp -> resp
									.bodyToMono(String.class).flatMap(error -> Mono.error(new GatewayException(error))))
					.bodyToMono(String.class)
					.doOnSuccess(p -> LOGGER.info(
							"created_on:{}, transaction_id:{}, message_id:{}, consumer_id:{}, provider_id:{}, domain:{}, city:{}, action:{}, Response:{}",
							new Timestamp(System.currentTimeMillis()), reqroot.getContext().getTransactionId(),
							reqroot.getContext().getMessageId(), reqroot.getContext().getConsumerId(),
							reqroot.getContext().getProviderId(), reqroot.getContext().getDomain(),
							reqroot.getContext().getCity(), reqroot.getContext().getAction(), p))
					.onErrorResume(error -> {
						LOGGER.error(
								"RequesterService::error::onErrorResume::created_on:{}, transaction_id:{}, message_id:{}, consumer_id:{}, provider_id:{}, domain:{}, city:{}, action:{}, Error:{}",
								new Timestamp(System.currentTimeMillis()), reqroot.getContext().getTransactionId(),
								reqroot.getContext().getMessageId(), reqroot.getContext().getConsumerId(),
								reqroot.getContext().getProviderId(), reqroot.getContext().getDomain(),
								reqroot.getContext().getCity(), reqroot.getContext().getAction(), error);
						// return gatewayUtil.generateNack(error);
						return gatewayUtil.generateNack("EUA exception", "/" + ResponderService.class.getSimpleName(),
								ErrorCode.EUA_EXCEPTION.getValue(), "");
					}).log().thenReturn(gatewayUtil.generateAck());

		} catch (Exception ex) {
			onSearchForward = Mono.empty();
			LOGGER.error("{} | RequesterService::error::catchBlock::{}", reqroot.getContext().getMessageId(),
					ex.getMessage());
		}
		return onSearchForward;
	}

}
