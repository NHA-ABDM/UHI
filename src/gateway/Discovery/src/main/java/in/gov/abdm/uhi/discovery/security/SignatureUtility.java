package in.gov.abdm.uhi.discovery.security;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;
import java.util.Map;
import java.util.stream.Collectors;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.bouncycastle.jcajce.spec.EdDSAParameterSpec;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.discovery.entity.RequestRoot;
import in.gov.abdm.uhi.discovery.entity.Subscriber;


@Component
public class SignatureUtility {
	
	private static final Logger LOGGER = LogManager.getLogger(SignatureUtility.class);

	@Autowired
	ObjectMapper mapper;
	
	@Autowired
	Crypt crypt;
	
	@Value("${spring.application.gateway_pubKeyId}")
	String gateway_pubKeyId;
	
	@Value("${spring.application.gateway_subsId}")
	String gateway_subsId;
	
	@Value("${spring.application.gateway_privKey}")
	String gateway_privKey;
	
	
	public Boolean verifySign(RequestRoot req, Map<String, String> headers, String req1, Subscriber subs) throws NumberFormatException, JsonProcessingException, InvalidKeyException, NoSuchAlgorithmException, NoSuchProviderException, SignatureException {

		Map<String, String> params = crypt.extractAuthorizationParams("Authorization", headers);

		String signature = params.get("signature");
		String created = params.get("created");
		String expires = params.get("expires");
		String keyId = params.get("keyId");
		String publicKey = subs.getEncr_public_key();
		String hashedSigningString = crypt
				.generateBlakeHash(crypt.getSigningString(Long.valueOf(created), Long.valueOf(expires), req1.trim()));

		LOGGER.info("Verfication result|" + crypt.verifySignature1(signature, hashedSigningString, publicKey));
		return crypt.verifySignature1(signature, hashedSigningString, publicKey);
	}
	
	public Map<String,String> generateAuthParams(RequestRoot req, String reqString){
		return crypt.generateAuthorizationParams(gateway_subsId, gateway_pubKeyId, reqString, crypt.getPrivateKey(EdDSAParameterSpec.Ed25519,gateway_privKey));
	}
	
	/*
	 * public String getGatewayHeaders(RequestRoot req) { String payload;
	 * Map<String,String> headers = null; try { payload =
	 * mapper.writeValueAsString(req);
	 * LOGGER.info(RequesterService.gateway_subs.toString()); PrivateKey priv =
	 * crypt.getPrivateKey(EdDSAParameterSpec.Ed25519,
	 * RequesterService.gateway_subs.getEncr_public_key()); headers =
	 * crypt.generateAuthorizationParams(RequesterService.gateway_subs.
	 * getSubscriber_id(),RequesterService.gateway_subs.getSigning_public_key(),
	 * payload, priv); } catch (JsonProcessingException e) { e.printStackTrace(); }
	 * return convertWithStream(headers); }
	 */

	public String convertWithStream(Map<String,String> map) {
	    String mapAsString = map.keySet().stream()
	      .map(key -> key + "=" + map.get(key))
	      .collect(Collectors.joining(", ", "", ""));
	    return mapAsString;
	}
}
