package in.gov.abdm.uhi.registry.security;

import java.nio.charset.StandardCharsets;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

import javax.crypto.Cipher;
import in.gov.abdm.uhi.registry.security.*;
public class RSA {
	private static PublicKey PUBLICK_KEY = null;
	private static PrivateKey PRIVATE_KEY = null;

	public void generateKeyPaire() {
		try {

			KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("RSA");
			SecureRandom secureRandom = new SecureRandom();

			keyPairGenerator.initialize(2048, secureRandom);

			KeyPair pair = keyPairGenerator.generateKeyPair();
			

			PUBLICK_KEY = pair.getPublic();

			String publicKeyString = Base64.getEncoder().encodeToString(PUBLICK_KEY.getEncoded());

			System.out.println("public key = " + publicKeyString);

			PRIVATE_KEY = pair.getPrivate();

			String privateKeyString = Base64.getEncoder().encodeToString(PRIVATE_KEY.getEncoded());

			System.out.println("private key = " + privateKeyString);

		} catch (Exception e) {

		}
	}
	private byte[] decode(String data) {
		return Base64.getDecoder().decode(data);
	}
	
	/*
	public static PublicKey getPublicKey(String base64PublicKey){
        PublicKey publicKey = null;
        try{
            X509EncodedKeySpec keySpec = new X509EncodedKeySpec(Base64.getDecoder().decode(base64PublicKey.getBytes()));
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            publicKey = keyFactory.generatePublic(keySpec);
            return publicKey;
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (InvalidKeySpecException e) {
            e.printStackTrace();
        }
        return publicKey;
    }*/
	
	public void test(String message, String publicKeyString, String privateKeyString) {
		try {
			X509EncodedKeySpec keySpekPublic = new X509EncodedKeySpec(decode(publicKeyString));
			PKCS8EncodedKeySpec keySpekPrivate = new PKCS8EncodedKeySpec(decode(privateKeyString));
			KeyFactory keyFactory = KeyFactory.getInstance("RSA");
			PublicKey publicKey = keyFactory.generatePublic(keySpekPublic);
			PrivateKey privateKey = keyFactory.generatePrivate(keySpekPrivate);
			

			System.out.println("-----"+ publicKey);
			// Encrypt Hello world message
			Cipher encryptionCipher = Cipher.getInstance("RSA");
			encryptionCipher.init(Cipher.ENCRYPT_MODE, publicKey);// privateKey
			// String message = "Hello world";
			byte[] encryptedMessage = encryptionCipher.doFinal(message.getBytes());
			String encryption = Base64.getEncoder().encodeToString(encryptedMessage);
			System.out.println("encrypted message = " + encryption);

			// Decrypt Hello world message
			Cipher decryptionCipher = Cipher.getInstance("RSA");
			decryptionCipher.init(Cipher.DECRYPT_MODE, privateKey);// publicKey
			byte[] decryptedMessage = decryptionCipher.doFinal(encryptedMessage);
			String decryption = new String(decryptedMessage);
			System.out.println("decrypted message = " + decryption);
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
}
