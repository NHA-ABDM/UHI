package in.gov.abdm.eua.service.utils;
import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import java.security.*;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
public class RsaUtils {

        private static final String publicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCgFGVfrY4jQSoZQWWygZ83roKXWD4YeT2x2p41dGkPixe73rT2IW04glagN2vgoZoHuOPqa5and6kAmK2ujmCHu6D1auJhE2tXP+yLkpSiYMQucDKmCsWMnW9XlC5K7OSL77TXXcfvTvyZcjObEz6LIBRzs6+FqpFbUO9SJEfh6wIDAQAB";
        private static final String privateKey = "MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAKAUZV+tjiNBKhlBZbKBnzeugpdYPhh5PbHanjV0aQ+LF7vetPYhbTiCVqA3a+Chmge44+prlqd3qQCYra6OYIe7oPVq4mETa1c/7IuSlKJgxC5wMqYKxYydb1eULkrs5IvvtNddx+9O/JlyM5sTPosgFHOzr4WqkVtQ71IkR+HrAgMBAAECgYAkQLo8kteP0GAyXAcmCAkA2Tql/8wASuTX9ITD4lsws/VqDKO64hMUKyBnJGX/91kkypCDNF5oCsdxZSJgV8owViYWZPnbvEcNqLtqgs7nj1UHuX9S5yYIPGN/mHL6OJJ7sosOd6rqdpg6JRRkAKUV+tmN/7Gh0+GFXM+ug6mgwQJBAO9/+CWpCAVoGxCA+YsTMb82fTOmGYMkZOAfQsvIV2v6DC8eJrSa+c0yCOTa3tirlCkhBfB08f8U2iEPS+Gu3bECQQCrG7O0gYmFL2RX1O+37ovyyHTbst4s4xbLW4jLzbSoimL235lCdIC+fllEEP96wPAiqo6dzmdH8KsGmVozsVRbAkB0ME8AZjp/9Pt8TDXD5LHzo8mlruUdnCBcIo5TMoRG2+3hRe1dHPonNCjgbdZCoyqjsWOiPfnQ2Brigvs7J4xhAkBGRiZUKC92x7QKbqXVgN9xYuq7oIanIM0nz/wq190uq0dh5Qtow7hshC/dSK3kmIEHe8z++tpoLWvQVgM538apAkBoSNfaTkDZhFavuiVl6L8cWCoDcJBItip8wKQhXwHp0O3HLg10OEd14M58ooNfpgt+8D8/8/2OOFaR0HzA+2Dm";

        public static PublicKey getPublicKey(String base64PublicKey){
            PublicKey publicKey = null;
            try{
                X509EncodedKeySpec keySpec = new X509EncodedKeySpec(Base64.getDecoder().decode(base64PublicKey.getBytes()));
                KeyFactory keyFactory = KeyFactory.getInstance("RSA");
                publicKey = keyFactory.generatePublic(keySpec);
                return publicKey;
            } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
                e.printStackTrace();
            }
            return publicKey;
        }

        public static PrivateKey getPrivateKey(String base64PrivateKey){
            PrivateKey privateKey = null;
            PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(Base64.getDecoder().decode(base64PrivateKey.getBytes()));
            KeyFactory keyFactory = null;
            try {
                keyFactory = KeyFactory.getInstance("RSA");
            } catch (NoSuchAlgorithmException e) {
                e.printStackTrace();
            }
            try {
                privateKey = keyFactory != null ? keyFactory.generatePrivate(keySpec) : null;
            } catch (InvalidKeySpecException e) {
                e.printStackTrace();
            }
            return privateKey;
        }

        public static byte[] encrypt(String data, String publicKey) throws BadPaddingException, IllegalBlockSizeException, InvalidKeyException, NoSuchPaddingException, NoSuchAlgorithmException {
            Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
            cipher.init(Cipher.ENCRYPT_MODE, getPublicKey(publicKey));
            return cipher.doFinal(data.getBytes());
        }

        public static String decrypt(byte[] data, PrivateKey privateKey) throws NoSuchPaddingException, NoSuchAlgorithmException, InvalidKeyException, BadPaddingException, IllegalBlockSizeException {
            Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
            cipher.init(Cipher.DECRYPT_MODE, privateKey);
            return new String(cipher.doFinal(data));
        }

        public static String decrypt(String data, String base64PrivateKey) throws IllegalBlockSizeException, InvalidKeyException, BadPaddingException, NoSuchAlgorithmException, NoSuchPaddingException {
            return decrypt(Base64.getDecoder().decode(data.getBytes()), getPrivateKey(base64PrivateKey));
        }

        public static void main(String[] args) throws IllegalBlockSizeException, InvalidKeyException, NoSuchPaddingException, BadPaddingException {
            try {
                String encryptedString = Base64.getEncoder().encodeToString(encrypt("Dhiraj is the author", publicKey));
//                System.out.println(encryptedString);
//                String decryptedString = RsaUtils.decrypt(encryptedString, privateKey);
//                System.out.println(decryptedString);
            } catch (NoSuchAlgorithmException e) {
                System.err.println(e.getMessage());
            }

        }
}
