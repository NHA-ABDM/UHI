package in.abdm.gov.openMrsWrapper;

import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import io.netty.handler.ssl.util.InsecureTrustManagerFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.web.reactive.function.client.ExchangeFilterFunction;
import org.springframework.web.reactive.function.client.ExchangeStrategies;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import reactor.netty.http.client.HttpClient;

import javax.net.ssl.SSLException;

import static org.springframework.web.reactive.function.client.ExchangeFilterFunctions.basicAuthentication;


@SpringBootApplication
public class OpenMrsWrapperApplication {

	private static final Logger LOGGER = LoggerFactory.getLogger(OpenMrsWrapperApplication.class);


	@Value("${spring.openmrs_username}")
	String OPENMRS_USERNAME;
	@Value("${spring.openmrs_password}")
	String OPENMRS_PASSWORD;

	@Value("${spring.openmrs_baselink}")
	String OPENMRS_BASE_LINK;

	public static void main(String[] args) {
		SpringApplication.run(OpenMrsWrapperApplication.class, args);
	}

	@Bean
	public WebClient getWebClient() throws SSLException {
		SslContext sslContext = SslContextBuilder
				.forClient()
				.trustManager(InsecureTrustManagerFactory.INSTANCE)
				.build();

		HttpClient httpClient = HttpClient.create().secure(t -> t.sslContext(sslContext));

		return WebClient.builder()
				.baseUrl(OPENMRS_BASE_LINK)
				.filter(basicAuthentication(OPENMRS_USERNAME, OPENMRS_PASSWORD))
				.filter(logRequest())
				.clientConnector(new ReactorClientHttpConnector(httpClient))
				.exchangeStrategies(ExchangeStrategies.builder()
						.codecs(configure -> configure
								.defaultCodecs()
								.maxInMemorySize(16 * 1024 * 1024))
						.build())
				.build();
	}

	private static ExchangeFilterFunction logRequest() {
		return ExchangeFilterFunction.ofRequestProcessor(clientRequest -> {
			LOGGER.info("Request: {} {}", clientRequest.method(), clientRequest.url());
			clientRequest.headers().forEach((name, values) -> values.forEach(value -> LOGGER.info("{}={}", name, value)));
			return Mono.just(clientRequest);
		});
	}


}
