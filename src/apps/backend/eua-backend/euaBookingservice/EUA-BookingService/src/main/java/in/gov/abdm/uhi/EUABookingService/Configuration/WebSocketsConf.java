package in.gov.abdm.uhi.EUABookingService.configuration;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

import in.gov.abdm.uhi.EUABookingService.constants.ConstantsUtils;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketsConf implements WebSocketMessageBrokerConfigurer {


    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        registry.enableSimpleBroker("/topic", "/queue");
        registry.setApplicationDestinationPrefixes(ConstantsUtils.APPLICATION_DESTINATION_PREFIX);
        registry.setUserDestinationPrefix(ConstantsUtils.USER_DESTINATION_PREFIX);
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint(ConstantsUtils.WEBSOCKET_CONNECT_ENDPOINT).setAllowedOrigins("*");
        registry.addEndpoint(ConstantsUtils.WEBSOCKET_CONNECT_TEST_ENDPOINT).withSockJS();
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
      registration.interceptors(new UserInterceptor());
    }
}
