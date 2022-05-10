package in.gov.abdm.uhi.discovery.service.beans;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class Items {
    private String id;
    private Quantity quantity;
    private Descriptor descriptor;
    private String category_id;
    private String fulfillment_id;
    private String provider_id;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Descriptor getDescriptor() {
        return descriptor;
    }

    public void setDescriptor(Descriptor descriptor) {
        this.descriptor = descriptor;
    }

    public String getCategory_id() {
        return category_id;
    }

    public void setCategory_id(String category_id) {
        this.category_id = category_id;
    }

    public String getFulfillment_id() {
        return fulfillment_id;
    }

    public void setFulfillment_id(String fulfillment_id) {
        this.fulfillment_id = fulfillment_id;
    }

    public Quantity getQuantity() {
        return quantity;
    }

    public void setQuantity(Quantity quantity) {
        this.quantity = quantity;
    }

    public String getProvider_id() {
        return provider_id;
    }

    public void setProvider_id(String provider_id) {
        this.provider_id = provider_id;
    }

    @Override
    public String toString() {
        return "Items{" +
                "id='" + id + '\'' +
                ", quantity=" + quantity +
                ", descriptor=" + descriptor +
                ", category_id='" + category_id + '\'' +
                ", fulfillment_id='" + fulfillment_id + '\'' +
                ", provider_id='" + provider_id + '\'' +
                '}';
    }
}
