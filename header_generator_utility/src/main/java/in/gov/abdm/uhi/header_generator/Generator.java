package in.gov.abdm.uhi.header_generator;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;

import java.util.Base64;
import java.util.Map;
import java.util.Scanner;

public class Generator implements ApplicationRunner {

    private static final Logger LOG = LoggerFactory.getLogger(Generator.class);

    public static void main(String[] args) {
        SpringApplication.run(Generator.class, args);
    }



    @Override
    public void run(ApplicationArguments args) throws Exception {

        Crypt crypt = new Crypt("BC");
        try (Scanner in = new Scanner(System.in)) {

            LOG.info("EXECUTING : command line runner");
            System.out.println("Pls select options from below:");
            System.out.println("1. Key pair generation");
            System.out.println("2. Signed header generation");
            System.out.println("3. Signed header verfication");
            int option = in.nextInt();

            if (option == 1) {
                System.out.println("Your generated key pair as per algo Ed25519 are::");
                Map<String, String> keypair = crypt.generateDerKeyPairs();
                System.out.println("Private Key::" + keypair.get("private"));
                System.out.println("Public key::" + keypair.get("public"));
            }

            if (option == 2) {
                System.out.println("Pls enter subscribers id.?");
                String subsId = in.next();
                System.out.println("subscribers id is:" + subsId);

                System.out.println("Pls enter public key id.?");
                String pub_key_id = in.next();
                System.out.println("public key id is:" + pub_key_id);

                System.out.println("Pls enter string private key.?");
                String private_key = in.next();
                System.out.println("private key is:" + private_key);

                System.out.println("Pls enter payload.?");
                in.nextLine();
                String payload = in.nextLine();
                System.out.println("payload is:" + payload);

                System.out.print("Your generated header is::" + crypt.generateAuthorizationParams(subsId, pub_key_id,
                        payload, Crypt.getPrivateKey("Ed25519", Base64.getDecoder().decode(private_key))));
            }
            if (option == 3) {
                System.out.println("Pls provide the signature from header.?");
                String signature = in.next();
                System.out.println("Signature from header is:" + signature);

                System.out.println("Pls provide the created date from header.?");
                String created = in.next();
                System.out.println("Created date from header is:" + created);

                System.out.println("Pls provide the expires from header.?");
                String expires = in.next();
                System.out.println("Expires from header is:" + expires);

                System.out.println("Pls provide the keyId from header.?");
                String keyId = in.next();
                System.out.println("KeyId from header is:" + keyId);

                System.out.println("Pls enter base64 string public key.?");
                String pub_key = in.next();
                System.out.println("Base64 string public key is:" + pub_key);

                System.out.println("Pls enter requested data to verify.?");
                in.nextLine();
                String data = in.nextLine();
                System.out.println("Request Data to verify is:" + data);

                String hashedSigningString = crypt.generateBlakeHash(
                        crypt.getSigningString(Long.parseLong(created), Long.parseLong(expires), data));

                System.out.println("Verfication result is ::" + crypt.verifySignature(hashedSigningString, signature, "Ed25519", Crypt.getPublicKey("Ed25519", Base64.getDecoder().decode(pub_key))));
            }
        } catch (Exception e) {
            System.out.println("Something went wrong.! Please try again..");
        }
    }
}


