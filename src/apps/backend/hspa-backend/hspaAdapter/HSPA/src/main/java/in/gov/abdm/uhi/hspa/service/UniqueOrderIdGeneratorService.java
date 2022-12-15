package in.gov.abdm.uhi.hspa.service;

import com.privacylogistics.FF3Cipher;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.BadPaddingException;
import javax.crypto.IllegalBlockSizeException;
import java.time.LocalTime;

@Service
public class UniqueOrderIdGeneratorService {
    static String publicKey, tweak;


    UniqueOrderIdGeneratorService(@Value("${rsa.public.key: nha_rsa_public_key.pem}") String rsaPublicKey, @Value("${fpe.tweak}") String tweakFromProps) {
        publicKey = rsaPublicKey;
        tweak = tweakFromProps;
    }

    static String generate(String date) throws IllegalBlockSizeException, BadPaddingException {
        String now = date == null
                ? LocalTime.now().toString()
                : date;

        // pad with additional random digits
        if (now.length() < 14) {
            int i = 14 - now.length();
            now += randomNumber(i);
        }

        now = now.replaceAll("[:.]", "\0");
        FF3Cipher c = new FF3Cipher(publicKey, tweak);
        String ciphertext = c.encrypt(now);

        StringBuilder orderId = formatOrderId(ciphertext);

        return orderId.toString();
    }

    private static StringBuilder formatOrderId(String ciphertext) {
        StringBuilder orderId = new StringBuilder();
        orderId.append(ciphertext, 0, 4);
        orderId.append("-");
        orderId.append(ciphertext, 4, 10);
        orderId.append("-");
        orderId.append(ciphertext, 10, 14);
        return orderId;
    }


    static double randomNumber(long length) {
        return Math.floor(
                Math.pow(10, length - 1) +
                        Math.random() * (Math.pow(10, length) - Math.pow(10, length - 1) - 1)
        );
    }
}


