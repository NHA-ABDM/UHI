package com.uhi.headergenerator.model;
import java.util.Objects;

public class Subscriber {
    private String subscriberId;
    private String publicKeyId;
    private String privateKey;
    private String payload;
    private String header=null;
    private String error=null;

    public Subscriber(String subscriberId, String publicKeyId, String privateKey, String payload, String header, String error) {
        this.subscriberId = subscriberId;
        this.publicKeyId = publicKeyId;
        this.privateKey = privateKey;
        this.payload = payload;
        this.header = header;
        this.error = error;
    }

    public String getError() {
        return this.error;
    }

    public void setError(String error) {
        this.error = error;
    }

    public Subscriber error(String error) {
        setError(error);
        return this;
    }


    public Subscriber(String subscriberId, String publicKeyId, String privateKey, String payload, String header) {
        this.subscriberId = subscriberId;
        this.publicKeyId = publicKeyId;
        this.privateKey = privateKey;
        this.payload = payload;
        this.header = header;
    }

    public String getHeader() {
        return this.header;
    }

    public void setHeader(String header) {
        this.header = header;
    }

    public Subscriber header(String header) {
        setHeader(header);
        return this;
    }

    public Subscriber() {
    }

    public Subscriber(String subscriberId, String publicKeyId, String privateKey, String payload) {
        this.subscriberId = subscriberId;
        this.publicKeyId = publicKeyId;
        this.privateKey = privateKey;
        this.payload = payload;
    }

    public String getSubscriberId() {
        return this.subscriberId;
    }

    public void setSubscriberId(String subscriberId) {
        this.subscriberId = subscriberId;
    }

    public String getPublicKeyId() {
        return this.publicKeyId;
    }

    public void setPublicKeyId(String publicKeyId) {
        this.publicKeyId = publicKeyId;
    }

    public String getPrivateKey() {
        return this.privateKey;
    }

    public void setPrivateKey(String privateKey) {
        this.privateKey = privateKey;
    }

    public String getPayload() {
        return this.payload;
    }

    public void setPayload(String payload) {
        this.payload = payload;
    }

    public Subscriber subscriberId(String subscriberId) {
        setSubscriberId(subscriberId);
        return this;
    }

    public Subscriber publicKeyId(String publicKeyId) {
        setPublicKeyId(publicKeyId);
        return this;
    }

    public Subscriber privateKey(String privateKey) {
        setPrivateKey(privateKey);
        return this;
    }

    public Subscriber payload(String payload) {
        setPayload(payload);
        return this;
    }

    @Override
    public boolean equals(Object o) {
        if (o == this)
            return true;
        if (!(o instanceof Subscriber)) {
            return false;
        }
        Subscriber subscriber = (Subscriber) o;
        return Objects.equals(subscriberId, subscriber.subscriberId) && Objects.equals(publicKeyId, subscriber.publicKeyId) && Objects.equals(privateKey, subscriber.privateKey) && Objects.equals(payload, subscriber.payload);
    }

    @Override
    public int hashCode() {
        return Objects.hash(subscriberId, publicKeyId, privateKey, payload);
    }

    @Override
    public String toString() {
        return "{" +
            " subscriberId='" + getSubscriberId() + "'" +
            ", publicKeyId='" + getPublicKeyId() + "'" +
            ", privateKey='" + getPrivateKey() + "'" +
            ", payload='" + getPayload() + "'" +
            "}";
    }
    

}