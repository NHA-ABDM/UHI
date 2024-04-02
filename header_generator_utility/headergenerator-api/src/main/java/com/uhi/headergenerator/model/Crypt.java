package com.uhi.headergenerator.model;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.util.JSONPObject;
import org.bouncycastle.jcajce.spec.EdDSAParameterSpec;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.json.simple.JSONObject;
import org.springframework.stereotype.Component;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Crypt {
    public static final String SIGNATURE_ALGO = EdDSAParameterSpec.Ed25519;

    static {
        if (Security.getProvider(BouncyCastleProvider.PROVIDER_NAME) == null) {
            Security.addProvider(new BouncyCastleProvider());
        }
    }

    public String provider = "BC";

    // Crypt.provider = "";
    public Crypt(String provider) {
        super();
        this.provider = provider;
    }

    public Crypt() {
        super();
    }

    public static PublicKey getPublicKey(String algo, byte[] jceBytes) throws Exception {
        X509EncodedKeySpec x509EncodedKeySpec = new X509EncodedKeySpec(jceBytes);
        return KeyFactory.getInstance(algo, BouncyCastleProvider.PROVIDER_NAME)
                .generatePublic(x509EncodedKeySpec);
    }

    public static PrivateKey getPrivateKey(String algo, byte[] jceBytes) throws Exception {
        return KeyFactory.getInstance(algo, BouncyCastleProvider.PROVIDER_NAME)
                .generatePrivate(new PKCS8EncodedKeySpec(jceBytes));
    }

    public Map<String, String> generateDerKeyPairs() throws NoSuchAlgorithmException {

        Map<String, String> keysPair = new HashMap<>();
        // Generate a key pair
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance(SIGNATURE_ALGO);
        KeyPair keyPair = keyGen.generateKeyPair();

        // Get the private and public keys
        PrivateKey privateKey = keyPair.getPrivate();
        PublicKey publicKey = keyPair.getPublic();

        // Convert the private key to DER format with key value pairs
        byte[] privateKeyBytes = privateKey.getEncoded();
        PKCS8EncodedKeySpec pkcs8KeySpec = new PKCS8EncodedKeySpec(privateKeyBytes);
        // Convert to Base64 string
        String base64Private = Base64.getEncoder().encodeToString(pkcs8KeySpec.getEncoded());

        // Convert the public key to DER format with key value pairs
        byte[] publicKeyBytes = publicKey.getEncoded();
        X509EncodedKeySpec x509KeySpec = new X509EncodedKeySpec(publicKeyBytes);
        // Convert to Base64 string
        String base64Public = Base64.getEncoder().encodeToString(x509KeySpec.getEncoded());

        keysPair.put("private", base64Private);
        keysPair.put("public", base64Public);
        return keysPair;
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
        for (byte aByte : bytes) {
            String hex = Integer.toHexString(aByte);
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
        return generateSignature(req, SIGNATURE_ALGO, privateKey);
    }

    public String generateAuthorizationParams(String subscriberId, String pub_key_id, String payload,
                                              PrivateKey privateKey) throws JsonProcessingException {
        ObjectMapper objectMapper = new ObjectMapper();
        //  payload = payload.replaceAll("\\s", "");
        Map<String, String> map = new HashMap<>();

        map.put("keyId", subscriberId + '|' + pub_key_id + '|' + "ed25519");
        map.put("algorithm", "ed25519");

        long created_at = System.currentTimeMillis() / 1000L;
        long expires_at = created_at + 10;

        map.put("created", Long.toString(created_at));
        map.put("expires", Long.toString(expires_at));
        map.put("headers", "(created) (expires) digest");
        map.put("signature",
                generateSignature(generateBlakeHash(getSigningString(created_at, expires_at, payload)), privateKey));
        return objectMapper.writeValueAsString(map);
    }

    public String getSigningString(long created_at, long expires_at, String payload) {
        return "(created): " + created_at +
                " (expires): " + expires_at +
                " digest: BLAKE-512=" + hash(payload);

    }

    public String generateBlakeHash(String req) {
        return toBase64(digest("BLAKE2B-512", req));
    }

    public String hash(String payload) {
        return generateBlakeHash(payload);
    }
}
