package com.uhi.headergenerator.model;

public class Verification {
private String signature;
private String created_date;
private String expires;
private String keyId;
private String publicKey;
private String payload;
public Verification(String signature, String created_date, String expires, String keyId, String publicKey,
		String payload) {
	super();
	this.signature = signature;
	this.created_date = created_date;
	this.expires = expires;
	this.keyId = keyId;
	this.publicKey = publicKey;
	this.payload = payload;
}
public String getSignature() {
	return signature;
}
public void setSignature(String signature) {
	this.signature = signature;
}
public String getCreated_date() {
	return created_date;
}
public void setCreated_date(String created_date) {
	this.created_date = created_date;
}
public String getExpires() {
	return expires;
}
public void setExpires(String expires) {
	this.expires = expires;
}
public String getKeyId() {
	return keyId;
}
public void setKeyId(String keyId) {
	this.keyId = keyId;
}
public String getPublicKey() {
	return publicKey;
}
public void setPublicKey(String publicKey) {
	this.publicKey = publicKey;
}
public String getPayload() {
	return payload;
}
public void setPayload(String payload) {
	this.payload = payload;
}

}
