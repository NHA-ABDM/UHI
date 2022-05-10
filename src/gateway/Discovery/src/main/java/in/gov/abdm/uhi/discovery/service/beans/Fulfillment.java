package in.gov.abdm.uhi.discovery.service.beans;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.JsonNode;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class Fulfillment {
    private String id;
    private String type;
    private String provider_id;
    private State state;
    private Boolean tracking;
    private JsonNode customer;
    private Agent agent;
    private Person person;
    private Contact contact;
    private Start start;
    private End end;
    private JsonNode tags;
    private Time time;
    private Quote quote;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Person getPerson() {
        return person;
    }

    public void setPerson(Person person) {
        this.person = person;
    }

    public Start getStart() {
        return start;
    }

    public void setStart(Start start) {
        this.start = start;
    }

    public End getEnd() {
        return end;
    }

    public void setEnd(End end) {
        this.end = end;
    }

    public JsonNode getCustomer() {
        return customer;
    }

    public void setCustomer(JsonNode customer) {
        this.customer = customer;
    }

    public String getProvider_id() {
        return provider_id;
    }

    public void setProvider_id(String provider_id) {
        this.provider_id = provider_id;
    }

    public State getState() {
        return state;
    }

    public void setState(State state) {
        this.state = state;
    }

    public Boolean isTracking() {
        return tracking;
    }

    public void setTracking(Boolean tracking) {
        this.tracking = tracking;
    }

    public Agent getAgent() {
        return agent;
    }

    public void setAgent(Agent agent) {
        this.agent = agent;
    }

    public Contact getContact() {
        return contact;
    }

    public void setContact(Contact contact) {
        this.contact = contact;
    }

    public JsonNode getTags() {
        return tags;
    }

    public void setTags(JsonNode tags) {
        this.tags = tags;
    }

    public Boolean getTracking() {
        return tracking;
    }

    public Time getTime() {
        return time;
    }

    public void setTime(Time time) {
        this.time = time;
    }

    public Quote getQuote() {
        return quote;
    }

    public void setQuote(Quote quote) {
        this.quote = quote;
    }

    @Override
    public String toString() {
        return "Fulfillment{" +
                "id='" + id + '\'' +
                ", type='" + type + '\'' +
                ", provider_id='" + provider_id + '\'' +
                ", state=" + state +
                ", tracking=" + tracking +
                ", customer=" + customer +
                ", agent=" + agent +
                ", person=" + person +
                ", contact=" + contact +
                ", start=" + start +
                ", end=" + end +
                ", tags=" + tags +
                '}';
    }
}
