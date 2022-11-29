/*
 * Copyright 2022  NHA
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package in.gov.abdm.uhi;

import java.time.Duration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.circuitbreaker.resilience4j.ReactiveResilience4JCircuitBreakerFactory;
import org.springframework.cloud.circuitbreaker.resilience4j.Resilience4JConfigBuilder;
import org.springframework.cloud.client.circuitbreaker.Customizer;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.RestController;
import io.github.resilience4j.circuitbreaker.CircuitBreakerConfig;
import io.github.resilience4j.timelimiter.TimeLimiterConfig;
import io.netty.handler.logging.LogLevel;
import reactor.netty.http.client.HttpClient;
import reactor.netty.transport.logging.AdvancedByteBufFormat;


@RestController
@SpringBootApplication
public class GatewayApplication {
	
	private static final Logger LOGGER = LoggerFactory.getLogger(GatewayApplication.class);

    @Value("${abdm.uhi.gateway_url}")
    private String gatewayHost;

    @Value("${abdm.uhi.requester_url}")
    private String requesterUri;

    @Value("${abdm.uhi.responder_url}")
    private String responderUri;

    @Value("${abdm.uhi.target_prefix}")
    private String targetPrefix;
    
    @Value("${abdm.uhi.swagger_url}")
    private String swaggerUri;
    
    @Bean
    HttpClient httpClient() {
        return HttpClient.create().wiretap("LoggingFilter", LogLevel.INFO, AdvancedByteBufFormat.TEXTUAL);
    }
    
    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {

    	LOGGER.info("Gateway URL: {}" , gatewayHost);
    	LOGGER.info("Requester URL : {}" , requesterUri);
    	LOGGER.info("Responder URL : {}" , responderUri);
    	LOGGER.info("Target Prefix : {}" , targetPrefix);

    	  return builder.routes()
                  .route(p->p
                		   .path(targetPrefix + "/search")
                		   .filters(f->f.circuitBreaker(c->c.setName("searchCB").setFallbackUri("/defaultFallback")))
                          .uri(requesterUri))

                  .route(p->p
               		   .path(targetPrefix + "/on_search")
               		   .filters(f->f.circuitBreaker(c->c.setName("on_searchCB").setFallbackUri("/defaultFallback")))
                         .uri(responderUri))
   
                  .build();
       
    }
   
    @Bean
	public Customizer<ReactiveResilience4JCircuitBreakerFactory> defaultCustomizer() {
		return factory ->
			factory.configureDefault(id -> new Resilience4JConfigBuilder(id)
					.circuitBreakerConfig(CircuitBreakerConfig.ofDefaults())
					.timeLimiterConfig(TimeLimiterConfig.custom()
					.timeoutDuration(Duration.ofSeconds(2)).build())
					.build());
		};
	

    public static void main(String[] args) {
      SpringApplication.run(GatewayApplication.class, args);
    }
    
    
}