package in.gov.abdm.uhi.hspa.models;

public class SubscriberModel {

    private Integer participant_id;
    private String subscriber_id;
    private String country;
    private String city;
    private String domain;
    private String unique_key_id;
    private String pub_key_id;
    private String signing_public_key;
    private String encr_public_key;
    private String valid_from;
    private String valid_to;
    private String status;
    private String created;
    private String updated;
    private String radius;
    private String type;
    private String sub_type;
    private String url;


    public SubscriberModel() {
        super();
    }

    //{country=IND, city=std:080, domain=nic2004:85110, type=HSPA, status=SUBSCRIBED}
    public SubscriberModel(String country, String city, String domain, String status, String sub_type) {
        super();
        this.country = country;
        this.city = city;
        this.domain = domain;
        this.status = status;
        this.type = sub_type;

    }

    public SubscriberModel(String subscriber_id, String country, String city, String domain, String status, String sub_type) {
        super();
        this.subscriber_id = subscriber_id;
        this.country = country;
        this.city = city;
        this.domain = domain;
        this.status = status;
        this.type = sub_type;

    }

    public SubscriberModel(String subscriber_id, String country, String city, String domain, String unique_key_id,
                           String pub_key_id, String signing_public_key, String encr_public_key, String valid_from, String valid_to,
                           String status, String created, String updated, String radius, String sub_type, String url) {
        super();

        this.subscriber_id = subscriber_id;
        this.country = country;
        this.city = city;
        this.domain = domain;
        this.unique_key_id = unique_key_id;
        this.pub_key_id = pub_key_id;
        this.signing_public_key = signing_public_key;
        this.encr_public_key = encr_public_key;
        this.valid_from = valid_from;
        this.valid_to = valid_to;
        this.status = status;
        this.created = created;
        this.updated = updated;
        this.radius = radius;
        this.type = sub_type;
        this.setSub_type(sub_type);
        this.url = url;
    }


    public String getSubscriber_id() {
        return subscriber_id;
    }


    public void setSubscriber_id(String subscriber_id) {
        this.subscriber_id = subscriber_id;
    }


    public String getCountry() {
        return country;
    }


    public void setCountry(String country) {
        this.country = country;
    }


    public String getCity() {
        return city;
    }


    public void setCity(String city) {
        this.city = city;
    }


    public String getDomain() {
        return domain;
    }


    public void setDomain(String domain) {
        this.domain = domain;
    }


    public String getUnique_key_id() {
        return unique_key_id;
    }


    public void setUnique_key_id(String unique_key_id) {
        this.unique_key_id = unique_key_id;
    }


    public String getPub_key_id() {
        return pub_key_id;
    }


    public void setPub_key_id(String pub_key_id) {
        this.pub_key_id = pub_key_id;
    }


    public String getSigning_public_key() {
        return signing_public_key;
    }


    public void setSigning_public_key(String signing_public_key) {
        this.signing_public_key = signing_public_key;
    }


    public String getEncr_public_key() {
        return encr_public_key;
    }


    public void setEncr_public_key(String encr_public_key) {
        this.encr_public_key = encr_public_key;
    }


    public String getValid_from() {
        return valid_from;
    }


    public void setValid_from(String valid_from) {
        this.valid_from = valid_from;
    }


    public String getValid_to() {
        return valid_to;
    }


    public void setValid_to(String valid_to) {
        this.valid_to = valid_to;
    }


    public String getStatus() {
        return status;
    }


    public void setStatus(String status) {
        this.status = status;
    }


    public String getCreated() {
        return created;
    }


    public void setCreated(String created) {
        this.created = created;
    }


    public String getUpdated() {
        return updated;
    }


    public void setUpdated(String updated) {
        this.updated = updated;
    }


    public String getRadius() {
        return radius;
    }


    public void setRadius(String radius) {
        this.radius = radius;
    }


    public String getType() {
        return type;
    }


    public void setType(String sub_type) {
        this.type = sub_type;
    }


    public String getUrl() {
        return url;
    }


    public void setUrl(String url) {
        this.url = url;
    }


    public String getSub_type() {
        return sub_type;
    }

    public void setSub_type(String sub_type) {
        this.sub_type = sub_type;
    }
}