package in.gov.abdm.uhi.discovery.service.beans;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class ContextRoot {
    private String domain;
    private String country;
    private String city;
    private String action;
    private String core_version;
    private String consumer_id;
    private String consumer_uri;
    private String provider_id;
    private String provider_uri;
    private String transaction_id;
    private String message_id;
    private String timestamp;
    private String key;
    private String ttl;

    public  ContextRoot()
    {
        super();
    }

    public ContextRoot(String domain, String country, String city, String action, String core_version, String message_id, String timestamp) {
        this.domain = domain;
        this.country = country;
        this.city = city;
        this.action = action;
        this.core_version = core_version;
        this.message_id = message_id;
        this.timestamp = timestamp;
    }

    public String getDomain() {
        return domain;
    }

    public void setDomain(String domain) {
        this.domain = domain;
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

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getCore_version() {
        return core_version;
    }

    public void setCore_version(String core_version) {
        this.core_version = core_version;
    }

    public String getMessage_id() {
        return message_id;
    }

    public void setMessage_id(String message_id) {
        this.message_id = message_id;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public String getConsumer_id() {
        return consumer_id;
    }

    public void setConsumer_id(String consumer_id) {
        this.consumer_id = consumer_id;
    }

    public String getConsumer_uri() {
        return consumer_uri;
    }

    public void setConsumer_uri(String consumer_uri) {
        this.consumer_uri = consumer_uri;
    }

    public String getProvider_id() {
        return provider_id;
    }

    public void setProvider_id(String provider_id) {
        this.provider_id = provider_id;
    }

    public String getProvider_uri() {
        return provider_uri;
    }

    public void setProvider_uri(String provider_uri) {
        this.provider_uri = provider_uri;
    }

    public String getTransaction_id() {
        return transaction_id;
    }

    public void setTransaction_id(String transaction_id) {
        this.transaction_id = transaction_id;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getTtl() {
        return ttl;
    }

    public void setTtl(String ttl) {
        this.ttl = ttl;
    }

    @Override
    public String toString() {
        return "Context{" +
                "domain='" + domain + '\'' +
                ", country='" + country + '\'' +
                ", city='" + city + '\'' +
                ", action='" + action + '\'' +
                ", core_version='" + core_version + '\'' +
                ", consumer_id='" + consumer_id + '\'' +
                ", consumer_uri='" + consumer_uri + '\'' +
                ", provider_id='" + provider_id + '\'' +
                ", provider_uri='" + provider_uri + '\'' +
                ", transaction_id='" + transaction_id + '\'' +
                ", message_id='" + message_id + '\'' +
                ", timestamp='" + timestamp + '\'' +
                ", key='" + key + '\'' +
                ", ttl='" + ttl + '\'' +
                '}';
    }
}
