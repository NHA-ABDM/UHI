package in.abdm.gov.openMrsWrapper.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MrsWrapperConfig {

    @Bean
    public ObjectMapper getObjectMapper() {
       return new ObjectMapper();
    }

}
