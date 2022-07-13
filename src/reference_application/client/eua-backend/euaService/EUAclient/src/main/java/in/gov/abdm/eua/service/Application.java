package in.gov.abdm.eua.service;

import in.gov.abdm.eua.service.constants.ConstantsUtils;
import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Info;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

@SpringBootApplication
@EnableEurekaClient
@OpenAPIDefinition(info = @Info(title = "EUA client", version = "1.0", description = ConstantsUtils.EUA_CLIENT_DESCRIPTION))
public class Application {

	public static void main(String[] args) {
		 SpringApplication.run(Application.class, args);
	}
}