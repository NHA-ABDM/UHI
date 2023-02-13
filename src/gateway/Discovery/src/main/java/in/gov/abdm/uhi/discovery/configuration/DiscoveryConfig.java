package in.gov.abdm.uhi.discovery.configuration;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.ExchangeFilterFunction;
import in.gov.abdm.uhi.discovery.security.SignatureUtility;
import reactor.core.publisher.Mono;

@Configuration
public class DiscoveryConfig {

	private static final Logger LOGGER = LogManager.getLogger(SignatureUtility.class);

	   public static ExchangeFilterFunction logRequest() {
	        return ExchangeFilterFunction.ofRequestProcessor(clientRequest -> {
	            LOGGER.info("Discovery Configuration Request: {} {} {}", clientRequest.method(), clientRequest.url(), clientRequest.body());
	            clientRequest.headers().forEach((name, values) -> values.forEach(value -> LOGGER.info("{}={}", name, value)));
	            return Mono.just(clientRequest);
	        });
	    }

	   public static ExchangeFilterFunction logRequest1() {
		    return ExchangeFilterFunction.ofRequestProcessor(clientRequest -> {
		        if (LOGGER.isInfoEnabled()) {
		            StringBuilder sb = new StringBuilder("Request: \n");
		            //append clientRequest method and url
		            clientRequest.headers().forEach((name, values) -> values.forEach(value -> LOGGER.info("{}={}", name, value)));
		            LOGGER.info(sb.toString());
		        }
		        return Mono.just(clientRequest);
		    });
		}

}
