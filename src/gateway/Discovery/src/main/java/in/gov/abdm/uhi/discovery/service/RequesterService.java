package in.gov.abdm.uhi.discovery.service;

import java.util.ArrayList;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.client.circuitbreaker.ReactiveCircuitBreakerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.Response;
import in.gov.abdm.uhi.discovery.configuration.DiscoveryConfig;
import in.gov.abdm.uhi.discovery.entity.ErrorCode;
import in.gov.abdm.uhi.discovery.entity.ListofSubscribers;
import in.gov.abdm.uhi.discovery.entity.RequestRoot;
import in.gov.abdm.uhi.discovery.security.Crypt;
import in.gov.abdm.uhi.discovery.security.SignatureUtility;
import in.gov.abdm.uhi.discovery.utility.GatewayUtility;
import in.gov.abdm.uhi.discovery.utility.GlobalConstants;
import reactor.core.publisher.Mono;

@Service
public class RequesterService {

	private static final Logger LOGGER = LoggerFactory.getLogger(RequesterService.class);

	@Autowired
	private ReactiveCircuitBreakerFactory circuitBreakerFactory;

	@Autowired
	NetworkRegistryService registryService;

	@Autowired
	ObjectMapper mapper;

	@Autowired
	GatewayUtility gatewayUtil;

	@Autowired
	Crypt crypt;

	@Autowired
	SignatureUtility signatureUtility;

	@Autowired
	DiscoveryConfig discoveryConfig;

	@Value("${spring.application.isHeaderEnabled}")
	Boolean isHeaderEnabled;

	@Value("${spring.application.gateway_pubKey}")
	String gateway_pubKey;

	@Value("${spring.application.gateway_privKey}")
	String gateway_privKey;

	@Autowired
	HSPAService HSPAService;

	/*
	 * HttpClient httpClient = HttpClient .create()
	 * .wiretap("reactor.netty.http.client.HttpClient", LogLevel.DEBUG,
	 * AdvancedByteBufFormat.TEXTUAL);
	 */

	// public static Subscriber gateway_subs = new Subscriber();

	public Mono<String> processor(@RequestBody RequestRoot request, @RequestHeader Map<String, String> headers,
			String req) throws JsonProcessingException {

		LOGGER.info("{} | Authorization |{}", request.getContext().getMessageId(), headers.get("Authorization"));

		if (isHeaderEnabled) {
			// gateway_subs.setPub_key_id(gateway_pubKey);
			// gateway_subs.setEncr_public_key(gateway_privKey);

			if (!headers.containsKey("Authorization")) {
				return gatewayUtil.generateNack(GlobalConstants.AUTH_HEADER_NOT_FOUND,
						"/" + RequesterService.class.getSimpleName(), ErrorCode.AUTH_HEADER_NOT_FOUND.getValue(), "")
						.log();
			}
			// lookup by subscribers_id to 1. validate EUA 2. get the public key
			Map<String, String> params = crypt.extractAuthorizationParams("Authorization", headers);

			Mono<String> subs = registryService.getParticipantsDetails(request.getContext(), params);

			return subs.flatMap(sub -> registryService.validateParticipant(request, params, headers, req, sub));
		}
		Mono<String> getData = registryService.circuitBreakerWrapper(request);
		return getData.flatMap(result -> HSPAService.checklookupforHSPAs(result, request, req));
	}

	private Mono<Response> CircuitBreakerError(Error err) {
		ListofSubscribers res = new ListofSubscribers();
		res.message = new ArrayList<>();
		return gatewayUtil.getErrorMsz(err);
	}

}
