package in.gov.abdm.eua.userManagement.constants;

public class ConstantsUtils {





    public static final String PHR_ADDRESS_PATTERN = "^(?!\\s+$)([a-z0-9])+@sbx$";


    public static final String EUA_CLIENT_DESCRIPTION = """
            UHI(Unified Health Interface) is envisioned as an open protocol for various digital health services. UHI Network will be an open network of End User Applications (EUAs) and participating Health Service Provider (HSP) applications. UHI will enable a wide variety of digital health services between patients and health service providers (HSPs) including appointment booking, teleconsultation, service discovery and others. This is a reference application for EUA client. This set Apis focuses on user login and registration. 
            
            <b>API Security</b></br>
            JWE (JSON WEB ENCRYPTION). Requests shall be encrypted using JWE.

            <b>Gateway Signing</b></br>
            The BG will send its signature in the Proxy-Authorization header in the exact same format as shown below -

            <b>X-Gateway-Authorization:</b></br>
            Signature keyId="{subscriber_id}|{unique_key_id}|{algorithm}" algorithm="xed25519" created="1606970629" expires="1607030629" headers="(created) (expires) digest" signature="Base64(BLAKE-512(signing string))"

            The EUAs and HSPAs subscriber is expected to send an Authorization header (as defined in RFC 7235, Section 4.1) where the “auth-scheme” is “Signature” and the “auth-param” parameters
            Below is the format of a EUA/HSPA Authorization header in the typical HTTP Signature format -

            <b>Authorization:</b></br>
            Signature keyId ="{subscriber_id}|{unique_key_id}|{algorithm}" algorithm="xed25519" created="1606970629" expires="1607030629" headers="(created) (expires) digest" signature="Base64(BLAKE-512(signing string))"

            <b>Hashing Algorithm</b></br>
            For computing the digest of the request body, the hashing function will use the BLAKE-512 hashing algorithm. BLAKE is a cryptographic hash function based on Dan Bernstein’s ChaCha stream cipher. For more documentation on the BLAKE-512 algorithm, please go to RFC7693.

            <b>Signing Algorithm</b></br>
            To digitally sign the singing string, the subscribers should use the “XEdDSA” signature scheme (or “XEd25519”). For the first version of beckn networks, we’ll be using the XEd25519 Signature Scheme.""";
    public static final String OTP_DURATION = "10";
}
