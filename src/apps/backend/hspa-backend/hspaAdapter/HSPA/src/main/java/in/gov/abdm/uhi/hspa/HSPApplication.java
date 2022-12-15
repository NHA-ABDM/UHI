package in.gov.abdm.uhi.hspa;

import in.gov.abdm.uhi.hspa.configuration.EhCacheConfiguration;
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import io.netty.handler.ssl.util.InsecureTrustManagerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.web.reactive.function.client.ExchangeStrategies;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.netty.http.client.HttpClient;

import javax.net.ssl.SSLException;

import static org.springframework.web.reactive.function.client.ExchangeFilterFunctions.basicAuthentication;


@SpringBootApplication
@EnableCaching
public class HSPApplication {

    @Value("${spring.openmrs_username}")
    String OPENMRS_USERNAME;
    @Value("${spring.openmrs_password}")
    String OPENMRS_PASSWORD;

    public static void main(String[] args) {

        SpringApplication.run(HSPApplication.class, args);
        ApplicationContext context = new AnnotationConfigApplicationContext(EhCacheConfiguration.class);
        ((ConfigurableApplicationContext) context).close();
    }


    @Bean
    public WebClient webClient() throws SSLException {
        SslContext sslContext = SslContextBuilder
                .forClient()
                .trustManager(InsecureTrustManagerFactory.INSTANCE)
                .build();

        HttpClient httpClient = HttpClient.create().secure(t -> t.sslContext(sslContext));

        return WebClient.builder()
                .baseUrl("https://uhihspabeta.abdm.gov.in/openmrs-standalone")
                .filter(basicAuthentication(OPENMRS_USERNAME, OPENMRS_PASSWORD))
                .clientConnector(new ReactorClientHttpConnector(httpClient))
                .exchangeStrategies(ExchangeStrategies.builder()
                        .codecs(configure -> configure
                                .defaultCodecs()
                                .maxInMemorySize(16 * 1024 * 1024))
                        .build())
                .build();
    }

    @Bean
    public WebClient euaWebClient() throws SSLException {
        SslContext
                sslContext = SslContextBuilder.forClient()
                .trustManager(InsecureTrustManagerFactory.INSTANCE).build();
        HttpClient httpClient = HttpClient.create().secure(t ->
                t.sslContext(sslContext));
        return WebClient.builder().clientConnector(new
                        ReactorClientHttpConnector(httpClient))
                .exchangeStrategies(ExchangeStrategies.builder().codecs(configure ->
                        configure.defaultCodecs().maxInMemorySize(16 * 1024 * 1024)).build())
                .build();
    }
}