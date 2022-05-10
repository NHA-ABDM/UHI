package in.gov.abdm.uhi.discovery.service.beans;

public class OnTBody {
    private ContextRoot context;
    private OnMessage message;

    public ContextRoot getContext() {
        return context;
    }

    public void setContext(ContextRoot context) {
        this.context = context;
    }

    public OnMessage getMessage() {
        return message;
    }

    public void setMessage(OnMessage message) {
        this.message = message;
    }
}
