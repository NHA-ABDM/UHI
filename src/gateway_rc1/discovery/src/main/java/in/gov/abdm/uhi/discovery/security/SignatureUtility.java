package in.gov.abdm.uhi.discovery.security;

import java.security.PrivateKey;
import java.security.PublicKey;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.stream.Collectors;

import org.bouncycastle.jcajce.spec.EdDSAParameterSpec;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.discovery.entity.RequestRoot;
import in.gov.abdm.uhi.discovery.service.RequesterService;


@Component
public class SignatureUtility {

	@Autowired
	ObjectMapper mapper;
	
	public Boolean verifySign(String req, Map<String, String> headers) {
		System.out.println(headers);
		String payload = "{\"context\":{\"domain\":\"nic2004:85110\",\"country\":\"IND\",\"city\":\"std:080\",\"action\":\"search\",\"core_version\":\"0.7.1\",\"message_id\":\"85a422c4-2867-4d72-b5f5-d31588e2f7c5\",\"timestamp\":\"2021-03-23T10:00:40.065Z\",\"consumer_id\":\"practo\"},\"message\":{\"intent\":{\"item\":{\"descriptor\":{\"name\":\"MRI Scan\"}}}}}";

		Map<String, String> params = Crypt.extractAuthorizationParams("authorization", headers);

		String signature = params.get("signature");
		String created = params.get("created");
		String expires = params.get("expires");
		String keyId = params.get("keyId");
		System.out.println(signature + "||" + created + "||" + expires);

		// String signature = headers.get("signature");
		// String
		// signature1="uN3zJU+mVvgLcvUFPuqfD0+u/9YvkZnIAsr36KHKA7V1sjN8Ys5rBKxDPuHndPWStp9T9rC+vrUkHi+gbS3tBQ==";
		StringTokenizer keyTokenizer = new StringTokenizer(keyId, "|");
		String subscriberId = keyTokenizer.nextToken();
		String uniqueKeyId = keyTokenizer.nextToken();

		String publicKey = "MCowBQYDK2VwAyEAfNUETjZYdT82PACnWkIUQtertCjoRDU8/JhvKlQMNuY=";
		// KeyPair key = new Crypt("BC").generateKeyPair("RSA", 2048);
		// PrivateKey priv = key.getPrivate();
		// PublicKey pub = key.getPublic();

		// System.out.println(getBase64Encoded(priv));
		// System.out.println(pub);
		PublicKey pubkey = Crypt.getPublicKey(EdDSAParameterSpec.Ed25519, publicKey);

		System.out.println(req.toString());

		/*
		 * System.out.println("Verfication result|" + Crypt.verifySignature(req,
		 * signature, EdDSAParameterSpec.Ed25519, pubkey)); return
		 * Crypt.verifySignature(req, signature, EdDSAParameterSpec.Ed25519, pubkey);
		 */

		String hashedSigningString = Crypt
				.generateBlakeHash(Crypt.getSigningString(Long.valueOf(created), Long.valueOf(expires), req.toString()));

		System.out.println("Verfication result|" + Crypt.verifySignature1(signature, hashedSigningString, publicKey));
		return Crypt.verifySignature1(signature, hashedSigningString, publicKey);

	}
	
	public String getGatewayHeaders(RequestRoot req) {
		String payload;
		Map<String,String> headers = null;
		try {
			payload = mapper.writeValueAsString(req);
			System.out.println(RequesterService.gateway_subs.toString());
			PrivateKey priv = Crypt.getPrivateKey(EdDSAParameterSpec.Ed25519, RequesterService.gateway_subs.getEncr_public_key());
			 headers = Crypt.generateAuthorizationParams(RequesterService.gateway_subs.getSubscriber_id(),RequesterService.gateway_subs.getSigning_public_key(), payload, priv);
		} catch (JsonProcessingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return convertWithStream(headers);
	}

	public String convertWithStream(Map<String,String> map) {
	    String mapAsString = map.keySet().stream()
	      .map(key -> key + "=" + map.get(key))
	      .collect(Collectors.joining(", ", "", ""));
	    return mapAsString;
	}
}
