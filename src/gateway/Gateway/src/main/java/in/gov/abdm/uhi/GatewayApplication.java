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

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpMethod;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;

@Slf4j
@RestController
@SpringBootApplication
public class GatewayApplication {

    @Value("${abdm.uhi.gateway.url}")
    private String gatewayHost;

    @Value("${abdm.uhi.requester.url}")
    private String requesterUri;

    @Value("${abdm.uhi.responder.url}")
    private String responderUri;

    @Value("${abdm.uhi.target_prefix}")
    private String targetPrefix;

    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {

        log.info("Gateway URL: " + gatewayHost);
        log.info("Requester URL : " + requesterUri);
        log.info("Responder URL : " + responderUri);
        log.info("Target Prefix : " + targetPrefix);

        return builder.routes()
                .route("path_route_on_search", r -> r.method(HttpMethod.POST).and().path(targetPrefix + "/on_search")
                        .uri(requesterUri))

                .route("path_route_search", r -> r.method(HttpMethod.POST).and().path(targetPrefix + "/search")
                        .uri(responderUri))
                .build();

    }

    /*

    TODO
    - Rate Limiting
    - Security checks
    */

    public static void main(String[] args) {

        SpringApplication.run(GatewayApplication.class, args);

    }
}