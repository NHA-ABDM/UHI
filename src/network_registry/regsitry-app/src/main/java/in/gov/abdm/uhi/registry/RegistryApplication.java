package in.gov.abdm.uhi.registry;



import java.util.TimeZone;

import javax.annotation.PostConstruct;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;


@SpringBootApplication
public class RegistryApplication {
	
	/* @PostConstruct
     void started() {
       TimeZone.setDefault(TimeZone.getTimeZone("IST"));
     }*/
	
	public static void main(String[] args) throws Exception {
		SpringApplication.run(RegistryApplication.class, args);		
	}
}
