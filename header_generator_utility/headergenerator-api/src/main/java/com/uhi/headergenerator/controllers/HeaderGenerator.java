package com.uhi.headergenerator.controllers;

import com.uhi.headergenerator.model.Crypt;
import com.uhi.headergenerator.model.Subscriber;
import com.uhi.headergenerator.model.Verification;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;


import java.security.PrivateKey;
import java.security.PublicKey;
import java.util.Base64;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;


@RestController
public class HeaderGenerator {
    @GetMapping("/header/requestobject")
    public Subscriber getRequestObj(){
        return new Subscriber();
    }
    @PostMapping("/header/generator")
    public Subscriber headerGenerator(@RequestBody Subscriber oSubscriber){
        Crypt crypt = new Crypt("BC");

        // byte[] binaryPrivateKey = Base64.getDecoder().decode(oSubscriber.getPrivateKey());

        // String enc_private_key = Base64.getEncoder().encodeToString(oSubscriber.getPrivateKey().getBytes());
        // byte[] binaryPrivateKey = Base64.getDecoder().decode(enc_private_key);
        try{
            PrivateKey oPrivateKey = Crypt.getPrivateKey("Ed25519", Base64.getDecoder().decode(oSubscriber.getPrivateKey().getBytes()));
            if(oPrivateKey == null){
                oSubscriber.setError("There are some issues with Private Key");
            }else{
                oSubscriber.setHeader(crypt.generateAuthorizationParams(oSubscriber.getSubscriberId(), oSubscriber.getPublicKeyId(), oSubscriber.getPayload(), oPrivateKey));
            }
        }catch (Exception exce){
            throw new UnsupportedOperationException();
        }
        return oSubscriber;
    }

    @PostMapping("/header/verify")
    public boolean headerVerify(@RequestBody Verification verification){
    	boolean result = false;
        Crypt crypt = new Crypt("BC");
        try{
            PublicKey oPublicKey = Crypt.getPublicKey("Ed25519", Base64.getDecoder().decode(verification.getPublicKey().getBytes()));
            if(oPublicKey == null){
                   
            }else{
            	String hashedSigningString = crypt.generateBlakeHash(
                crypt.getSigningString(Long.parseLong(verification.getCreated_date()), Long.parseLong(verification.getExpires()), verification.getPayload()));
                result=crypt.verifySignature(hashedSigningString, verification.getSignature(), "Ed25519", Crypt.getPublicKey("Ed25519", Base64.getDecoder().decode(verification.getPublicKey())));
            }
        }catch (Exception exce){
            throw new UnsupportedOperationException();
        }
        return result;
    }
}


    

