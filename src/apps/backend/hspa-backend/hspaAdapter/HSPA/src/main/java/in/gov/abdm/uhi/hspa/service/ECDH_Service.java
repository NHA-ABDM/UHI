package in.gov.abdm.uhi.hspa.service;

import javax.crypto.KeyAgreement;
import java.io.Console;
import java.nio.ByteBuffer;
import java.security.*;
import java.security.spec.X509EncodedKeySpec;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static javax.xml.bind.DatatypeConverter.parseHexBinary;
import static javax.xml.bind.DatatypeConverter.printHexBinary;

public class ECDH_Service {



    public static void main(String[] args) throws Exception {
        // Generate ephemeral ECDH keypair
        KeyPairGenerator kpg = KeyPairGenerator.getInstance("EC");
        kpg.initialize(256);
        KeyPair kp = kpg.generateKeyPair();
        byte[] ourPk = kp.getPublic().getEncoded();
        Console console = System.console();
        // Display our public key
        console.printf("Public Key: %s%n", printHexBinary(ourPk));

//        // Read other's public key:
        byte[] otherPk = parseHexBinary(console.readLine("Other PK: "));

        KeyFactory kf = KeyFactory.getInstance("EC");
        X509EncodedKeySpec pkSpec = new X509EncodedKeySpec(otherPk);
        PublicKey otherPublicKey = kf.generatePublic(pkSpec);

        // Perform key agreement
        KeyAgreement ka = KeyAgreement.getInstance("ECDH");
        ka.init(kp.getPrivate());
        ka.doPhase(otherPublicKey, true);

        // Read shared secret
        byte[] sharedSecret = ka.generateSecret();
        console.printf("Shared secret: %s%n", printHexBinary(sharedSecret));

        // Derive a key from the shared secret and both public keys
        MessageDigest hash = MessageDigest.getInstance("SHA-256");
        hash.update(sharedSecret);
        // Simple deterministic ordering
        List<ByteBuffer> keys = Arrays.asList(ByteBuffer.wrap(ourPk), ByteBuffer.wrap(otherPk));
        Collections.sort(keys);
        hash.update(keys.get(0));
        hash.update(keys.get(1));

        byte[] derivedKey = hash.digest();
        console.printf("Final key: %s%n", printHexBinary(derivedKey));
    }
}
