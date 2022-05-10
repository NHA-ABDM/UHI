package in.gov.abdm.uhi.discovery.service.beans;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class OnMessage {
    private OnOrder order;

    public OnOrder getOrder() {
        return order;
    }

    public void setOrder(OnOrder order) {
        this.order = order;
    }

    @Override
    public String toString() {
        return "OnMessage{" +
                "order=" + order +
                '}';
    }
}
