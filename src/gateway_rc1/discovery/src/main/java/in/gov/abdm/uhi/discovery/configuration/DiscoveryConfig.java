package in.gov.abdm.uhi.discovery.configuration;


import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@ConfigurationProperties("spring.application")
public class DiscoveryConfig {

		private String registry_url;
		private String isHeaderEnabled;
		private String gateway_pubKey;
		private String gateway_privKey;

		public String getRegistry_url() {
			return registry_url;
		}

		public void setRegistry_url(String registry_url) {
			this.registry_url = registry_url;
		}

		public String getIsHeaderEnabled() {
			return isHeaderEnabled;
		}

		public void setIsHeaderEnabled(String isHeaderEnabled) {
			this.isHeaderEnabled = isHeaderEnabled;
		}

		public String getGateway_pubKey() {
			return gateway_pubKey;
		}

		public void setGateway_pubKey(String gateway_pubKey) {
			this.gateway_pubKey = gateway_pubKey;
		}

		public String getGateway_privKey() {
			return gateway_privKey;
		}

		public void setGateway_privKey(String gateway_privKey) {
			this.gateway_privKey = gateway_privKey;
		}

		@Profile("beta")
		@Bean
		public String devDatabaseConnection() {
			System.out.println("Gateway properties for Beta");
			System.out.println(""+registry_url);
			return "Gateway properties for DEV";
		}

		@Profile("sandbox")
		@Bean
		public String testDatabaseConnection() {
			System.out.println("Gateway properties for sandbox");
			return "Gateway properties for sandbox";
		}

		@Profile("prod")
		@Bean
		public String prodDatabaseConnection() {
			System.out.println("Gateway properties for prod");
			return "Gateway properties for prod";
		} 
	
}

