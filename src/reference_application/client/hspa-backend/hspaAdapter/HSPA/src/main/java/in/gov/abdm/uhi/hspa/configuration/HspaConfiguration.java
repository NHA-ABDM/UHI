package in.gov.abdm.uhi.hspa.configuration;

import org.modelmapper.ModelMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class HspaConfiguration {

    @Bean
    public ModelMapper getModelMapper() {
        return new ModelMapper();
    }
}
