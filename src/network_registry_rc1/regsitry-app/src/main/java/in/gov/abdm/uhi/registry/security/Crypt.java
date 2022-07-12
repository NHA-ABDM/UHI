package in.gov.abdm.uhi.registry.security;

import org.aspectj.weaver.ast.Var;
import org.bouncycastle.asn1.edec.EdECObjectIdentifiers;
import org.bouncycastle.asn1.x509.AlgorithmIdentifier;
import org.bouncycastle.asn1.x509.SubjectPublicKeyInfo;
import org.bouncycastle.crypto.CipherParameters;
import org.bouncycastle.crypto.encodings.PKCS1Encoding;
import org.bouncycastle.crypto.engines.RSAEngine;
import org.bouncycastle.crypto.params.AsymmetricKeyParameter;
import org.bouncycastle.jcajce.spec.EdDSAParameterSpec;
import org.bouncycastle.jcajce.spec.XDHParameterSpec;
import org.bouncycastle.jce.provider.BouncyCastleProvider;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.common.dto.Context;
import in.gov.abdm.uhi.common.dto.Descriptor;
import in.gov.abdm.uhi.common.dto.Intent;
import in.gov.abdm.uhi.common.dto.Item;
import in.gov.abdm.uhi.common.dto.MessageRoot;
import in.gov.abdm.uhi.common.dto.RequestRoot;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import java.io.StringReader;
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
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
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

	public Crypt() {

	}

	static {
		if (Security.getProvider(BouncyCastleProvider.PROVIDER_NAME) == null) {
			Security.addProvider(new BouncyCastleProvider());
		}
	}

	static public String provider;

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
		return new Crypt("BC").verifySignature(requestData, sign, SIGNATURE_ALGO, key);
	}

	public static PublicKey getSigningPublicKey(String keyFromRegistry) {
		try {
			return new Crypt("BC").getPublicKey(EdDSAParameterSpec.Ed25519, keyFromRegistry);
		} catch (Exception ex) {
			try {
				byte[] bcBytes = Base64.getDecoder().decode(keyFromRegistry);
				byte[] jceBytes = new SubjectPublicKeyInfo(new AlgorithmIdentifier(EdECObjectIdentifiers.id_Ed25519),
						bcBytes).getEncoded();
				String pemKey = Base64.getEncoder().encodeToString(jceBytes);
				return new Crypt("BC").getPublicKey(EdDSAParameterSpec.Ed25519, pemKey);
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
		// PrivateKey key = new Crypt("BC").getPrivateKey(SIGNATURE_ALGO,privateKey);
		return generateSignature(req, SIGNATURE_ALGO, privateKey);
	}

	public static Map<String, String> generateAuthorizationParams(String subscriberId, String pub_key_id,
			String payload, PrivateKey privateKey) {
		Map<String, String> map = new HashMap<String, String>();
		StringBuilder keyBuilder = new StringBuilder();
		keyBuilder.append(subscriberId).append('|').append(pub_key_id).append('|').append("ed25519");

		map.put("keyId", keyBuilder.toString());
		map.put("algorithm", "ed25519");
		long created_at = System.currentTimeMillis() / 1000L;
		long expires_at = created_at + 10;
		map.put("created", Long.toString(created_at));
		map.put("expires", Long.toString(expires_at));
		map.put("headers", "(created) (expires) digest");
		map.put("signature",
				generateSignature(generateBlakeHash(getSigningString(created_at, expires_at, payload)), privateKey));
		// map.put("signature", generateSignature(payload, "ed25519", privateKey));
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
		return new Crypt("BC").toBase64(new Crypt("BC").digest("BLAKE2B-512", req));
	}

	public static String hash(String payload) {
		return generateBlakeHash(payload);
	}

	public void testNirmal(PrivateKey pkey, String pubkey, Map<String, String> header, String payload) {

		System.out.println("Request.hash :\n" + generateBlakeHash(payload));
		header.put("Authorization", header.toString());
		Map<String, String> params = extractAuthorizationParams("Authorization", header);
		String signature = params.get("signature");
		String created = params.get("created");
		String expires = params.get("expires");
		String keyId = params.get("keyId");
		StringTokenizer keyTokenizer = new StringTokenizer(keyId, "|");
		String subscriberId = keyTokenizer.nextToken();
		String uniqueKeyId = keyTokenizer.nextToken();

		String hashedSigningString = generateBlakeHash(
				getSigningString(Long.valueOf(created), Long.valueOf(expires), payload));

		System.out.println("Nirmal Test|" + verifySignature1(signature, hashedSigningString, pubkey));

	}

	public Map<String, String> keyGenerator(String provider) throws JsonProcessingException {
		Map<String, String> map = new HashMap<String, String>();
		RequestRoot reqroot = new RequestRoot();
		Context ctx = new Context();
		ctx.setCity("delhi");
		ctx.setCountry("IND");
		MessageRoot mszroot = new MessageRoot();
		Intent intent = new Intent();
		Item itm = new Item();
		Descriptor desc = new Descriptor();
		desc.setName("MRI Scan");
		itm.setDescriptor(desc);
		intent.setItem(itm);
		mszroot.setIntent(intent);
		reqroot.setMessageRoot(mszroot);
		ObjectMapper mapper = new ObjectMapper();
		reqroot.setContext(ctx);
		String payload = mapper.writeValueAsString(reqroot);
		System.out.println("Request payload|" + payload);
		KeyPair key = new Crypt("BC").generateKeyPair(EdDSAParameterSpec.Ed25519, 256);
		PrivateKey priv = key.getPrivate();
		PublicKey pub = key.getPublic();
		System.out.println("private key: " + this.getBase64Encoded(priv));
		System.out.println("public key: " + this.getBase64Encoded(pub));
		String signature = this.generateSignature(payload, EdDSAParameterSpec.Ed25519, priv);
		System.out.println(signature);
		Map<String, String> params = this.generateAuthorizationParams("practo", "practo_key_id", payload, priv);
		System.out.println(params);
		System.out.println(new Crypt("BC").verifySignature(payload, signature, EdDSAParameterSpec.Ed25519, pub));
		new Crypt("BC").testNirmal(priv, this.getBase64Encoded(pub), params, payload);
		map.put("publicKey", this.getBase64Encoded(priv));
		map.put("privateKey", this.getBase64Encoded(pub));

		return map;
	}
	/*
	 * private void encrypt(PrivateKey priv, PublicKey pub, byte[] msg) { Signature
	 * sig; try { sig = Signature.getInstance("Ed25519"); sig.initSign(priv);
	 * sig.update(msg); byte[] s = sig.sign(); String encodedString =
	 * Base64.getEncoder().encodeToString(s); // sig.initVerify(pub);
	 * System.out.println("Encode: "+encodedString);
	 * 
	 * } catch (NoSuchAlgorithmException | InvalidKeyException e) { // TODO
	 * Auto-generated catch block e.printStackTrace(); } catch (SignatureException
	 * e) { // TODO Auto-generated catch block e.printStackTrace(); } }
	 */

}