package in.gov.abdm.uhi.EUABookingService.configuration;

import javax.net.ssl.SSLException;

import org.modelmapper.ModelMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.web.reactive.function.client.ExchangeStrategies;
import org.springframework.web.reactive.function.client.WebClient;

import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import io.netty.handler.ssl.util.InsecureTrustManagerFactory;
import reactor.netty.http.client.HttpClient;

@Configuration
public class ChatConfiguration {
	@Bean
	public WebClient getWebClient() throws SSLException {
		SslContext sslContext = SslContextBuilder.forClient().trustManager(InsecureTrustManagerFactory.INSTANCE)
				.build();

		HttpClient httpClient = HttpClient.create().secure(t -> t.sslContext(sslContext));

		return WebClient.builder().baseUrl("https://uhihspabeta.abdm.gov.in/openmrs-standalone")
				.clientConnector(new ReactorClientHttpConnector(httpClient))
				.exchangeStrategies(ExchangeStrategies.builder()
						.codecs(configure -> configure.defaultCodecs().maxInMemorySize(16 * 1024 * 1024)).build())
				.build();
	}

	@Bean
	public ModelMapper modelMapper() {
		return new ModelMapper();
	}

}
