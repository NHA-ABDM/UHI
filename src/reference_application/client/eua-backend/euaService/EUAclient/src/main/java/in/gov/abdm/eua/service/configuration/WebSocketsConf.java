package in.gov.abdm.eua.service.configuration;

import in.gov.abdm.eua.service.constants.ConstantsUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketsConf implements WebSocketMessageBrokerConfigurer {
    private static final Logger LOGGER = LoggerFactory.getLogger(WebSocketsConf.class);

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        registry.enableSimpleBroker("/topic", "/queue");
        registry.setApplicationDestinationPrefixes(ConstantsUtils.APPLICATION_DESTINATION_PREFIX);
        registry.setUserDestinationPrefix(ConstantsUtils.USER_DESTINATION_PREFIX);
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {

        registry.addEndpoint(ConstantsUtils.WEBSOCKET_CONNECT_ENDPOINT)
                .setAllowedOrigins("*");
        registry.addEndpoint("/test").withSockJS();
        LOGGER.info("Set Websocket connect endpoint "+ConstantsUtils.WEBSOCKET_CONNECT_ENDPOINT);
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
      registration.interceptors(new UserInterceptor());
    }
}
