package in.gov.abdm.uhi.discovery.service.beans;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.ArrayList;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class OnOrder {
    private String id;
    private String state;
    private Provider provider;
    private ArrayList<Items> items;
    private Billing billing;
    private Fulfillment fulfillment;
    private Quote quote;
    private Payment payment;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public Provider getProvider() {
        return provider;
    }

    public void setProvider(Provider provider) {
        this.provider = provider;
    }

    public ArrayList<Items> getItems() {
        return items;
    }

    public void setItems(ArrayList<Items> items) {
        this.items = items;
    }

    public Billing getBilling() {
        return billing;
    }

    public void setBilling(Billing billing) {
        this.billing = billing;
    }

    public Fulfillment getFulfillment() {
        return fulfillment;
    }

    public void setFulfillment(Fulfillment fulfillment) {
        this.fulfillment = fulfillment;
    }

    public Quote getQuote() {
        return quote;
    }

    public void setQuote(Quote quote) {
        this.quote = quote;
    }

    public Payment getPayment() {
        return payment;
    }

    public void setPayment(Payment payment) {
        this.payment = payment;
    }

    @Override
    public String toString() {
        return "OnOrder{" +
                "id='" + id + '\'' +
                ", state='" + state + '\'' +
                ", provider=" + provider +
                ", items=" + items +
                ", billing=" + billing +
                ", fulfillment=" + fulfillment +
                ", quote=" + quote +
                ", payment=" + payment +
                '}';
    }
}
