package in.gov.abdm.uhi.discovery.service.beans;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.ArrayList;
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Provider {
    private String id;
    private Descriptor descriptor;
    private ArrayList<Category> categories;
    private ArrayList<Fulfillment> fulfillments;
    private ArrayList<Items> items;

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

    public ArrayList<Category> getCategories() {
        return categories;
    }

    public void setCategories(ArrayList<Category> categories) {
        this.categories = categories;
    }

    public ArrayList<Fulfillment> getFulfillments() {
        return fulfillments;
    }

    public void setFulfillments(ArrayList<Fulfillment> fulfillments) {
        this.fulfillments = fulfillments;
    }

    public ArrayList<Items> getItems() {
        return items;
    }

    public void setItems(ArrayList<Items> items) {
        this.items = items;
    }

    @Override
    public String toString() {
        return "Providers{" +
                "id='" + id + '\'' +
                ", descriptor=" + descriptor +
                ", categories=" + categories +
                ", fulfillments=" + fulfillments +
                ", items=" + items +
                '}';
    }
}
