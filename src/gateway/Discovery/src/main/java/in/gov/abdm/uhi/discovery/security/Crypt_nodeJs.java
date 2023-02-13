package in.gov.abdm.uhi.discovery.security;

import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
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
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import org.bouncycastle.asn1.edec.EdECObjectIdentifiers;
import org.bouncycastle.asn1.x509.AlgorithmIdentifier;
import org.bouncycastle.asn1.x509.SubjectPublicKeyInfo;
import org.bouncycastle.jcajce.spec.EdDSAParameterSpec;
import org.bouncycastle.jcajce.spec.XDHParameterSpec;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.springframework.stereotype.Component;
import com.fasterxml.jackson.core.JsonProcessingException;

/**
 * @author Deepak Kumar
 *
 */
@Component
public class Crypt_nodeJs {

	public static final String KEY_ALGO = XDHParameterSpec.X25519;
	public static final String SIGNATURE_ALGO = EdDSAParameterSpec.Ed25519;

	static {
		if (Security.getProvider(BouncyCastleProvider.PROVIDER_NAME) == null) {
			Security.addProvider(new BouncyCastleProvider());
		}
	}

	public String provider = "BC";

	// Crypt.provider = "";
	public Crypt_nodeJs(String provider) {
		super();
		this.provider = provider;
	}

	public Crypt_nodeJs() {
		super();
	}

	public static String getBase64Encoded(Key key) {
		byte[] encoded = key.getEncoded();
		String b64Key = Base64.getEncoder().encodeToString(encoded);
		return b64Key;
	}

	public SecretKey getSecretKey(String algo, String base64Key) {
		return new SecretKeySpec(Base64.getDecoder().decode(base64Key), algo);
	}

	public PublicKey getPublicKey(String algo, String base64PublicKey) {
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

	public PrivateKey getPrivateKey(String algo, String base64PrivateKey) {
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

	public String generateSignature(String payload, String signatureAlgorithm, PrivateKey privateKey) {
		try {
			Signature signature = Signature.getInstance(signatureAlgorithm, provider); //
			signature.initSign(privateKey);
			signature.update(payload.getBytes());
			return Base64.getEncoder().encodeToString(signature.sign());
		} catch (Exception ex) {
			throw new RuntimeException(ex);
		}
	}

	public boolean verifySignature(String payload, String signature, String signatureAlgorithm, PublicKey pKey)
			throws NoSuchAlgorithmException, NoSuchProviderException, InvalidKeyException, SignatureException {
		byte[] data = payload.getBytes();
		byte[] signatureBytes = Base64.getDecoder().decode(signature);
		// try {
		Signature s = Signature.getInstance(signatureAlgorithm, provider);
		s.initVerify(pKey);
		s.update(data);
		return s.verify(signatureBytes);

	}

	public boolean verifySignature1(String sign, String requestData, String b64PublicKey)
			throws InvalidKeyException, NoSuchAlgorithmException, NoSuchProviderException, SignatureException {
		PublicKey key = getSigningPublicKey(b64PublicKey);
		return verifySignature(requestData, sign, SIGNATURE_ALGO, key);
	}

	public PublicKey getSigningPublicKey(String keyFromRegistry) {
		try {
			return getPublicKey(EdDSAParameterSpec.Ed25519, keyFromRegistry);
		} catch (Exception ex) {
			try {
				byte[] bcBytes = Base64.getDecoder().decode(keyFromRegistry);
				byte[] jceBytes = new SubjectPublicKeyInfo(new AlgorithmIdentifier(EdECObjectIdentifiers.id_Ed25519),
						bcBytes).getEncoded();
				String pemKey = Base64.getEncoder().encodeToString(jceBytes);
				return getPublicKey(EdDSAParameterSpec.Ed25519, pemKey);
			} catch (Exception jceEx) {
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

	public Map<String, String> extractAuthorizationParams(String header, Map<String, String> httpRequestHeaders) {
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

	public String generateSignature(String req, PrivateKey privateKey) {
		// PrivateKey key = new Crypt("BC").getPrivateKey(SIGNATURE_ALGO,privateKey);
		return generateSignature(req, SIGNATURE_ALGO, privateKey);
	}

	public Map<String, String> generateAuthorizationParams(String subscriberId, String pub_key_id, String payload,
			PrivateKey privateKey) {
		Map<String, String> map = new HashMap<String, String>();
		StringBuilder keyBuilder = new StringBuilder();
		keyBuilder.append(subscriberId).append('|').append(pub_key_id).append('|').append("ed25519");

		map.put("keyId", keyBuilder.toString());
		map.put("algorithm", "ed25519");
		
		long created_at = System.currentTimeMillis();
		long expires_at = created_at + 10000L;
		
		map.put("created", Long.toString(created_at));
		map.put("expires", Long.toString(expires_at));
		map.put("headers", "(created) (expires) digest");
		map.put("signature",
				generateSignature(generateBlakeHash(getSigningString(created_at, expires_at, payload)), privateKey));
		// map.put("signature", generateSignature(payload, "ed25519", privateKey));
		return map;
	}

	public String getSigningString(long created_at, long expires_at, String payload) {
		StringBuilder builder = new StringBuilder();
		builder.append("(created): ").append(created_at);
		builder.append("\n(expires): ").append(expires_at);
		builder.append("\n").append("digest: BLAKE-512=").append(hash(payload));
		return builder.toString();
	}

	public String generateBlakeHash(String req) {
		return toBase64(digest("BLAKE2B-512", req));
	}

	public String hash(String payload) {
		return generateBlakeHash(payload);
	}

	public static void main(String args[]) throws JsonProcessingException, InvalidKeyException,
			NoSuchAlgorithmException, NoSuchProviderException, SignatureException {
		
		String payload = "Deepak";
		try {
			
		
		byte[] input = payload.toString().getBytes("utf-8");
		
		MessageDigest md = MessageDigest.getInstance("MD5");
		byte[] thedigest = md.digest();
		SecretKeySpec skc = new SecretKeySpec(thedigest, "AES");
		Cipher cipher = Cipher.getInstance("AES");
		cipher.init(Cipher.ENCRYPT_MODE, skc);
		
		byte[] cipherText = new byte[cipher.getOutputSize(input.length)];
		int ctLength = cipher.update(input, 0, input.length, cipherText, 0);
		ctLength += cipher.doFinal(cipherText, ctLength);
	    	
		String query = Base64.getEncoder().encodeToString(cipherText);
		System.out.println("query|"+query);
		}catch (Exception e) {
			System.out.println("exception "+e);
		}
	}

	public void testNirmal(PrivateKey pkey, String pubkey, Map<String, String> header, String payload)
			throws InvalidKeyException, NoSuchAlgorithmException, NoSuchProviderException, SignatureException {

		System.out.println("Request.hash :\n" + generateBlakeHash(payload));

		header.put("Authorization", header.toString());
		Map<String, String> params = extractAuthorizationParams("Authorization", header);
		String signature = params.get("signature");
		String created = params.get("created");
		String expires = params.get("expires");

		String hashedSigningString = generateBlakeHash(
				getSigningString(Long.valueOf(created), Long.valueOf(expires), payload));
		// signature="LaPWrjHo1k5C0/0EsXKEqWNxQZjCXDGVch9Uk49DwaE0LKfCABUcbi55NfjuihOWY7BWyI3TpmTtBZcCzEYsAw==";
		// hashedSigningString="t18yt9SNzp/Jqq1OOKle5CQIPo7qWtIq6FVmVF+wjB53V1fM1YjoQCzsjZSwBkzOhZpHawdGXJ7YvPn/+IyhJQ==";
		// pubkey="MCowBQYDK2VwAyEAQCWv0rw/WPtm3xLcXChk0/Px8yNK9l2AcyoQWXbHsD8=";
		System.out.println("Nirmal Test|" + verifySignature1(signature, hashedSigningString, pubkey));
	}
}
