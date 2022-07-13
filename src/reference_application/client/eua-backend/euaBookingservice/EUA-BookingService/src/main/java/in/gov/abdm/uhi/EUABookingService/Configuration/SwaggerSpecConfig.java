package in.gov.abdm.uhi.EUABookingService.configuration;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import springfox.documentation.swagger.web.SwaggerResource;
import springfox.documentation.swagger.web.SwaggerResourcesProvider;

@Configuration
public class SwaggerSpecConfig {

    @Primary
    @Bean
    public SwaggerResourcesProvider swaggerResourcesProvider() {
        return () -> {
            List<SwaggerResource> resources = new ArrayList<>();
            Arrays.asList("v1.0.0")
                .forEach(resourceName -> resources.add(loadResource(resourceName)));
            return resources;
        };
    }

    private SwaggerResource loadResource(String resource) {
        SwaggerResource wsResource = new SwaggerResource();
        wsResource.setName(resource);
        wsResource.setSwaggerVersion("2.0");
        wsResource.setLocation("/swagger-docs/" + resource + "/BookingService.yaml");
       //System.out.println("+++"+yaml_path);
       //wsResource.setLocation("/Gateway.yaml");
        return wsResource;
    }
}
