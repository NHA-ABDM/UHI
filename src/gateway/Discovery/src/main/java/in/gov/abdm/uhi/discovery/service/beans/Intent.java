package in.gov.abdm.uhi.discovery.service.beans;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.JsonNode;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class Intent {
    private Provider provider;

    private Item item;

    private Fulfillment fulfillment;

    private Category category;

    private JsonNode tags;

    public Item getItem() {
        return item;
    }

    public void setItem(Item item) {
        this.item = item;
    }

    public Provider getProvider() {
        return provider;
    }

    public void setProvider(Provider provider) {
        this.provider = provider;
    }

    public Category getCategory() {
        return category;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

    public Fulfillment getFulfillment() {
        return fulfillment;
    }

    public void setFulfillment(Fulfillment fulfillment) {
        this.fulfillment = fulfillment;
    }

    public JsonNode getTags() {
        return tags;
    }

    public void setTags(JsonNode tags) {
        this.tags = tags;
    }

    @Override
    public String toString() {
        return "Intent{" +
                "provider=" + provider +
                ", item=" + item +
                ", category=" + category +
                ", fulfillment=" + fulfillment +
                ", tags=" + tags +
                '}';
    }
}
