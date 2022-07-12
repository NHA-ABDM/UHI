package in.gov.abdm.uhi.discovery.security;

import org.bouncycastle.asn1.edec.EdECObjectIdentifiers;
import org.bouncycastle.asn1.x509.AlgorithmIdentifier;
import org.bouncycastle.asn1.x509.SubjectPublicKeyInfo;
import org.bouncycastle.jcajce.spec.EdDSAParameterSpec;
import org.bouncycastle.jcajce.spec.XDHParameterSpec;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.common.dto.Context;
import in.gov.abdm.uhi.common.dto.Descriptor;
import in.gov.abdm.uhi.common.dto.Intent;
import in.gov.abdm.uhi.common.dto.Item;
import in.gov.abdm.uhi.common.dto.Message;
import in.gov.abdm.uhi.common.dto.MessageRoot;
import in.gov.abdm.uhi.discovery.entity.RequestRoot;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Security;
import java.security.Signature;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author Deepak Kumar
 *
 */
public class Crypt {

	public static final String KEY_ALGO = XDHParameterSpec.X25519;
	public static final String SIGNATURE_ALGO = EdDSAParameterSpec.Ed25519;

	static {
		if (Security.getProvider(BouncyCastleProvider.PROVIDER_NAME) == null) {
			Security.addProvider(new BouncyCastleProvider());
		}
	}

	static public String provider = "BC";

	public Crypt(String provider) {
		this.provider = provider;
	}
	

	public static String getBase64Encoded(Key key) {
		byte[] encoded = key.getEncoded();
		String b64Key = Base64.getEncoder().encodeToString(encoded);
		return b64Key;
	}

	public SecretKey getSecretKey(String algo, String base64Key) {
		return new SecretKeySpec(Base64.getDecoder().decode(base64Key), algo);
	}

	static public PublicKey getPublicKey(String algo, String base64PublicKey) {
		byte[] binCpk = Base64.getDecoder().decode(base64PublicKey);
		X509EncodedKeySpec pkSpec = new X509EncodedKeySpec(binCpk);

		try {
			KeyFactory keyFactory = KeyFactory.getInstance(algo, provider);
			PublicKey pKey = keyFactory.generatePublic(pkSpec);
			return pKey;
		} catch (NoSuchAlgorithmException | NoSuchProviderException | InvalidKeySpecException ex) {
			throw new RuntimeException(ex);
		}
	}

	public static PrivateKey getPrivateKey(String algo, String base64PrivateKey) {
		byte[] binCpk = Base64.getDecoder().decode(base64PrivateKey);
		PKCS8EncodedKeySpec pkSpec = new PKCS8EncodedKeySpec(binCpk);

		try {
			KeyFactory keyFactory = KeyFactory.getInstance(algo, provider);
			PrivateKey pKey = keyFactory.generatePrivate(pkSpec);
			return pKey;
		} catch (NoSuchAlgorithmException | NoSuchProviderException | InvalidKeySpecException ex) {
			throw new RuntimeException(ex);
		}
	}

	public KeyPair generateKeyPair(String algo, int strength) {
		try {
			KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance(algo, provider);
			keyPairGenerator.initialize(strength);
			return keyPairGenerator.generateKeyPair();
		} catch (NoSuchAlgorithmException | NoSuchProviderException ex) {
			throw new RuntimeException(ex);
		}
	}

	public static String generateSignature(String payload, String signatureAlgorithm, PrivateKey privateKey) {
		try {
			Signature signature = Signature.getInstance(signatureAlgorithm, provider); //
			signature.initSign(privateKey);
			signature.update(payload.getBytes());
			return Base64.getEncoder().encodeToString(signature.sign());
		} catch (Exception ex) {
			throw new RuntimeException(ex);
		}
	}

	public static boolean verifySignature(String payload, String signature, String signatureAlgorithm, PublicKey pKey) {
		byte[] data = payload.getBytes();
		byte[] signatureBytes = Base64.getDecoder().decode(signature);
		try {
			Signature s = Signature.getInstance(signatureAlgorithm, provider);
			s.initVerify(pKey);
			s.update(data);
			return s.verify(signatureBytes);
		} catch (Exception ex) {
			throw new RuntimeException(ex);
		}
	}
	
	 public static boolean verifySignature1(String sign, String requestData, String b64PublicKey) {
	        PublicKey key = getSigningPublicKey(b64PublicKey);
	        return new Crypt("BC").verifySignature(requestData,sign,SIGNATURE_ALGO,key);
	    }
	 
	 public static PublicKey getSigningPublicKey(String keyFromRegistry){
	        try {
	            return new Crypt("BC").getPublicKey(EdDSAParameterSpec.Ed25519, keyFromRegistry);
	        }catch (Exception ex){
	            try {
	                byte[] bcBytes = Base64.getDecoder().decode(keyFromRegistry);
	                byte[] jceBytes = new SubjectPublicKeyInfo(new AlgorithmIdentifier(EdECObjectIdentifiers.id_Ed25519), bcBytes).getEncoded();
	                String pemKey = Base64.getEncoder().encodeToString(jceBytes);
	                return new Crypt("BC").getPublicKey(EdDSAParameterSpec.Ed25519,pemKey);
	            }catch (Exception jceEx){
	                return null;
	            }
	        }
	    }

	public byte[] digest(String algorithm, String payload) {
		try {
			MessageDigest digest = MessageDigest.getInstance(algorithm, provider);
			digest.reset();
			digest.update(payload.getBytes(StandardCharsets.UTF_8));
			return digest.digest();
		} catch (Exception ex) {
			throw new RuntimeException(ex);
		}
	}

	public String toBase64(byte[] bytes) {
		return Base64.getEncoder().encodeToString(bytes);
	}

	public String toHex(byte[] bytes) {
		StringBuilder builder = new StringBuilder();
		for (int i = 0; i < bytes.length; i++) {
			String hex = Integer.toHexString(bytes[i]);
			if (hex.length() == 1) {
				hex = "0" + hex;
			}
			hex = hex.substring(hex.length() - 2);
			builder.append(hex);
		}
		return builder.toString();
	}

	static public Map<String, String> extractAuthorizationParams(String header,
			Map<String, String> httpRequestHeaders) {
		Map<String, String> params = new HashMap<String, String>();
		if (!httpRequestHeaders.containsKey(header)) {
			return params;
		}
		String authorization = httpRequestHeaders.get(header).trim();
		String signatureToken = "Signature ";

		if (authorization.startsWith(signatureToken)) {
			authorization = authorization.substring(signatureToken.length());
		}

		Matcher matcher = Pattern.compile("([A-z]+)(=)[\"]*([^\",]*)[\"]*[, ]*").matcher(authorization);
		matcher.results().forEach(mr -> {
			System.out.println(mr.group());
			params.put(mr.group(1), mr.group(3));
		});

		if (!params.isEmpty()) {
			String keyId = params.get("keyId");
			if (!"".equalsIgnoreCase(keyId)) {
				StringTokenizer keyTokenizer = new StringTokenizer(keyId, "|");
				String subscriberId = keyTokenizer.nextToken();
				String pub_key_id = keyTokenizer.nextToken();
				params.put("subscriber_id", subscriberId);
				params.put("pub_key_id", pub_key_id);
			}
		}

		return params;
	}
	
	
	public static String generateSignature(String req, PrivateKey privateKey) {
      //  PrivateKey key = new Crypt("BC").getPrivateKey(SIGNATURE_ALGO,privateKey);
        return generateSignature(req,SIGNATURE_ALGO,privateKey);
    }
	
	public static Map<String,String> generateAuthorizationParams(String subscriberId,String pub_key_id, String payload, PrivateKey privateKey){
        Map<String,String> map = new HashMap<String,String>();
        StringBuilder keyBuilder = new StringBuilder();
        keyBuilder.append(subscriberId).append('|')
                .append(pub_key_id).append('|').append("ed25519");

        map.put("keyId",keyBuilder.toString());
        map.put("algorithm","ed25519");
        long created_at = System.currentTimeMillis()/1000L;
        long expires_at = created_at + 10;
        map.put("created",Long.toString(created_at));
        map.put("expires",Long.toString(expires_at));
        map.put("headers","(created) (expires) digest");
        map.put("signature",generateSignature(generateBlakeHash(getSigningString(created_at,expires_at,payload)),privateKey));
      //  map.put("signature", generateSignature(payload, "ed25519", privateKey));
        return map;
    }
	
	 public static String getSigningString(long created_at, long expires_at, String payload) {
	        StringBuilder builder = new StringBuilder();
	        builder.append("(created): ").append(created_at);
	        builder.append("\n(expires): ").append(expires_at);
	        builder.append("\n").append("digest: BLAKE-512=").append(hash(payload));
	        return builder.toString();
	    }
	 
	 public static String generateBlakeHash(String req) {
	        return new Crypt("BC").toBase64(new Crypt("BC").digest("BLAKE2B-512",req));
	    }
	 
	 
	 public static String hash(String payload){
	        return generateBlakeHash(payload);
	    }


	public static void main(String args[]) throws JsonProcessingException {
		// public String KEY_ALGO = "RSA";
		// public String SIGNATURE_ALGO = "SHA256withRSA";
		//String payload = "{\"context\":{\"domain\":\"nic2004:85110\",\"country\":\"IND\",\"city\":\"std:080\",\"action\":\"search\",\"core_version\":\"0.7.1\",\"message_id\":\"85a422c4-2867-4d72-b5f5-d31588e2f7c5\",\"timestamp\":\"2021-03-23T10:00:40.065Z\",\"consumer_id\":\"practo\"},\"message\":{\"intent\":{\"item\":{\"descriptor\":{\"name\":\"MRI Scan\"}}}}}";
		RequestRoot reqroot = new RequestRoot();
		Context ctx = new Context();
		ctx.setCity("delhi");ctx.setCountry("IND");
		Message mszroot = new Message();
		Intent intent = new Intent();
		Item itm = new Item();
		Descriptor desc = new Descriptor();
		desc.setName("MRI Scan");
		itm.setDescriptor(desc);intent.setItem(itm);
		mszroot.setIntent(intent);
		reqroot.setMessage(mszroot);
		ObjectMapper mapper = new ObjectMapper();
		reqroot.setContext(ctx);
		String payload = mapper.writeValueAsString(reqroot);
		System.out.println("Request payload|"+payload);
		KeyPair key = new Crypt("BC").generateKeyPair(EdDSAParameterSpec.Ed25519, 256);
		PrivateKey priv = key.getPrivate();
		PublicKey pub = key.getPublic();

		System.out.println(getBase64Encoded(priv));
		System.out.println(getBase64Encoded(pub));

		String signature = generateSignature(payload,EdDSAParameterSpec.Ed25519, priv);
		System.out.println(signature);
		
		Map<String, String> params = generateAuthorizationParams("practo","practo_key_id",payload,priv);

		System.out.println(params);

		System.out.println(new Crypt("BC").verifySignature(payload, signature,EdDSAParameterSpec.Ed25519, pub));
		
		new Crypt("BC").testNirmal(priv, getBase64Encoded(pub), params,payload);

	}
	
public void testNirmal(PrivateKey pkey, String pubkey, Map<String,String> header, String payload) {

    System.out.println("Request.hash :\n" + generateBlakeHash(payload));


    //Map<String,String> header = new HashMap<>();
    //header.put("Authorization","Signature keyId=\"MOCK_SUB_ID|key1|xed25519\" algorithm=\"xed25519\" created=\"1624423460\" expires=\"1624427060\" headers=\"(created) (expires) digest\" signature=\"VM5BwNtKk3wZy4a37lGMJDta-gEyIeOqbNCNR2rqqpy52ejsPuRAVcwZsTU7BdUQCyl8nQ-TXbr81YO8_NaOAA\"");

    //Request request = new Request(payload);
    //KeyPair pair = Crypt.getInstance().generateKeyPair(EdDSAParameterSpec.Ed25519,256);

    //String privateKey = "MFECAQEwBQYDK2VwBCIEIHvkevAws5WgG7JQ/C92R/vnIyY7no66orNDNHATNp4xgSEAQTQgyHhsZC9xR9TDdjtkwFVGE6+J3LqeeRdUABWIXAU=";//Crypt.getInstance().getBase64Encoded(pair.getPrivate());
   // String publicKey  = "MCowBQYDK2VwAyEAQTQgyHhsZC9xR9TDdjtkwFVGE6+J3LqeeRdUABWIXAU=";//Crypt.getInstance().getBase64Encoded(pair.getPublic());

   // System.out.println("PrivateKey:" + privateKey);
   // System.out.println("PublicKey:" + publicKey);


	/*
	 * Map<String,String> map = new HashMap(); StringBuilder keyBuilder = new
	 * StringBuilder(); keyBuilder.append("MOCK_SUB_ID").append('|')
	 * .append("key1").append('|').append("xed25519");
	 * 
	 * map.put("keyId",keyBuilder.toString()); map.put("algorithm","xed25519"); long
	 * created_at = 1624423460; long expires_at = 1624423460;
	 * map.put("created",Long.toString(created_at));
	 * map.put("expires",Long.toString(expires_at));
	 * map.put("headers","(created) (expires) digest");
	 * map.put("signature",generateSignature(
	 * generateBlakeHash(getSigningString(created_at,expires_at)),pkey));
	 * 
	 * StringBuilder auth = new StringBuilder("Signature"); map.forEach((k,v)->
	 * auth.append(" ").append(k).append("=\"").append(v).append("\""));
	 * System.out.println(auth); header.put("Authorization",auth.toString());
	 */
    header.put("Authorization",header.toString());
    Map<String,String> params = extractAuthorizationParams("Authorization",header);
    String signature = params.get("signature");
    String created = params.get("created");
    String expires = params.get("expires");
    String keyId = params.get("keyId");
    StringTokenizer keyTokenizer = new StringTokenizer(keyId,"|");
    String subscriberId = keyTokenizer.nextToken();
    String uniqueKeyId = keyTokenizer.nextToken();

    String hashedSigningString = generateBlakeHash(getSigningString(Long.valueOf(created),Long.valueOf(expires), payload));



    System.out.println("Nirmal Test|"+verifySignature1(signature,hashedSigningString,pubkey));



}
}

