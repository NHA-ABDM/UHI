package in.gov.abdm.uhi.EUABookingService;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;


@SpringBootApplication
@EnableEurekaClient
//@EnableSwagger2
public class EuaBookingServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(EuaBookingServiceApplication.class, args);
	}

}
