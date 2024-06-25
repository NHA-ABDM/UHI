package in.gov.abdm.eua.service.configuration;

import in.gov.abdm.eua.service.constants.ConstantsUtils;
import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.amqp.rabbit.annotation.EnableRabbit;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableRabbit
public class RabbitMQConf {

    @Bean
    public Queue queueEuaToGateway() {
        return new Queue(ConstantsUtils.QUEUE_EUA_TO_GATEWAY);
    }

    @Bean
    public Queue queueGatewayToEua() {
        return new Queue(ConstantsUtils.QUEUE_GATEWAY_TO_EUA);
    }

    @Bean
    public TopicExchange exchange() {
        return new TopicExchange(ConstantsUtils.EXCHANGE);
    }

    @Bean
    public Binding bindingQueueEuaToGateway(TopicExchange exchange) {
        return BindingBuilder.bind(queueEuaToGateway()).to(exchange).with(ConstantsUtils.ROUTING_KEY_EUA_TO_GATEWAY);
    }

    @Bean
    public Binding bindingQueueGatewayToEua(TopicExchange exchange) {
        return BindingBuilder.bind(queueGatewayToEua()).to(exchange).with(ConstantsUtils.ROUTING_KEY_GATEWAY_TO_EUA);
    }

    @Bean
    public MessageConverter converter() {
        return new Jackson2JsonMessageConverter();
    }

    @Bean
    public RabbitTemplate template(ConnectionFactory connectionFactory) {
        final RabbitTemplate rabbitTemplate = new RabbitTemplate(connectionFactory);
        rabbitTemplate.setMessageConverter(converter());
//        rabbitTemplate.containerAckMode(AcknowledgeMode.MANUAL);
        return rabbitTemplate;
    }
}
