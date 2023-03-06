package in.gov.abdm.uhi.header_generator;

import org.bouncycastle.asn1.DEROctetString;
import org.bouncycastle.asn1.edec.EdECObjectIdentifiers;
import org.bouncycastle.asn1.pkcs.PrivateKeyInfo;
import org.bouncycastle.asn1.x509.AlgorithmIdentifier;
import org.bouncycastle.asn1.x509.SubjectPublicKeyInfo;
import org.bouncycastle.crypto.AsymmetricCipherKeyPair;
import org.bouncycastle.crypto.generators.Ed25519KeyPairGenerator;
import org.bouncycastle.crypto.params.Ed25519KeyGenerationParameters;
import org.bouncycastle.crypto.params.Ed25519PrivateKeyParameters;
import org.bouncycastle.crypto.params.Ed25519PublicKeyParameters;
import org.bouncycastle.jcajce.spec.EdDSAParameterSpec;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
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

/**
 * @author Deepak Kumar
 */
@Component
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

    public Map<String, String> generatePrivateAndPublicKeyToRaw() {
        Ed25519KeyPairGenerator pairGenerator = new Ed25519KeyPairGenerator();
        pairGenerator.init(new Ed25519KeyGenerationParameters(new SecureRandom()));
        AsymmetricCipherKeyPair pair = pairGenerator.generateKeyPair();
        Ed25519PrivateKeyParameters privateKeyParameters = (Ed25519PrivateKeyParameters) pair.getPrivate();
        Ed25519PublicKeyParameters publicKeyParameters = (Ed25519PublicKeyParameters) pair.getPublic();
        Map<String, String> keyPair = new HashMap<>();
        keyPair.put("private", Base64.getEncoder().encodeToString(privateKeyParameters.getEncoded()));
        keyPair.put("public", Base64.getEncoder().encodeToString(publicKeyParameters.getEncoded()));

        return keyPair;

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

    public Map<String, String> generateAuthorizationParams(String subscriberId, String pub_key_id, String payload,
                                                           PrivateKey privateKey) {
        payload = payload.replaceAll("\\s", "");
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
        return map;
    }

    public String getSigningString(long created_at, long expires_at, String payload) {
        payload = payload.replaceAll("\\s", "");
        return "(created): " + created_at +
                "\n(expires): " + expires_at +
                "\n" + "digest: BLAKE-512=" + hash(payload);
    }

    public String generateBlakeHash(String req) {
        return toBase64(digest("BLAKE2B-512", req));
    }

    public String hash(String payload) {
        return generateBlakeHash(payload);
    }

    public String convertPrivateRawKeyToPem(String pv) throws Exception {
        Ed25519PrivateKeyParameters privateKeyParameters = new Ed25519PrivateKeyParameters(Base64.getDecoder().decode(pv), 0);
        return Base64.getEncoder().encodeToString(new PrivateKeyInfo(new AlgorithmIdentifier(EdECObjectIdentifiers.id_Ed25519),
                new DEROctetString(privateKeyParameters.getEncoded())).getEncoded());
    }

    public String convertPublicRawKeyToPem(String pb) throws Exception {
        Ed25519PublicKeyParameters publicKeyParameters = new Ed25519PublicKeyParameters(Base64.getDecoder().decode(pb), 0);
        return Base64.getEncoder().encodeToString(new SubjectPublicKeyInfo(new AlgorithmIdentifier(EdECObjectIdentifiers.id_Ed25519), publicKeyParameters.getEncoded()).getEncoded());
    }

}