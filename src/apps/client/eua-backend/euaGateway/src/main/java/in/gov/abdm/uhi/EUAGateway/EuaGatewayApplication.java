package in.gov.abdm.uhi.EUAGateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

@SpringBootApplication
@EnableEurekaClient
public class EuaGatewayApplication {

	public static void main(String[] args) {
		SpringApplication.run(EuaGatewayApplication.class, args);
	}

}
