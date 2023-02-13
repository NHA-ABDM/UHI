package in.gov.abdm.uhi.discovery.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import com.fasterxml.jackson.databind.ObjectMapper;

@Configuration
public class AppConfig {
	@Bean
	public ObjectMapper objectMapper() {
		return new ObjectMapper();
	}
}
