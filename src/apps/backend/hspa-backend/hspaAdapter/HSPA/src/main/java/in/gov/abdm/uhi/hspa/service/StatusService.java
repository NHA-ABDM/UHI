package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.models.OrdersModel;
import in.gov.abdm.uhi.hspa.repo.OrderRepository;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Service
public class StatusService implements IService {


    private static final Logger LOGGER = LogManager.getLogger(StatusService.class);
    @Value("${spring.openmrs_baselink}")
    String OPENMRS_BASE_LINK;
    @Value("${spring.openmrs_api}")
    String OPENMRS_API;
    @Value("${spring.openmrs_username}")
    String OPENMRS_USERNAME;
    @Value("${spring.openmrs_password}")
    String OPENMRS_PASSWORD;
    @Value("${spring.gateway_uri}")
    String GATEWAY_URI;
    @Value("${spring.provider_uri}")
    String PROVIDER_URI;
    final
    WebClient webClient;
    final
    ObjectMapper mapper;
    final OrderRepository orderRepository;

    public StatusService(WebClient webClient, ObjectMapper mapper, OrderRepository orderRepository) {
        this.webClient = webClient;
        this.mapper = mapper;
        this.orderRepository = orderRepository;
    }

    @Override
    public Mono<Response> processor(String request) {

        Request objRequest;
        Response ack;

        LOGGER.info("Processing::Confirm::Request:: {}", request);
        try {
            objRequest = new ObjectMapper().readValue(request, Request.class);
            logMessageId(objRequest);

            run(objRequest, request);

               return Mono.just(generateAck());


        } catch (Exception ex) {
            LOGGER.error("Confirm Service process::error::onErrorResume:: {}", ex, ex);
            ack = generateNack(ex);

        }

        return Mono.just(ack);
    }

    @Override
    public Mono<String> run(Request request, String s) {
        Mono<String> response = Mono.empty();
        Objects.requireNonNull(getAppointmentStatus(request))
                .filter(Objects::nonNull)
               .flatMap(appointmentStatus -> transformObject(appointmentStatus, request))
               .flatMap(this::callOnStatus)
               .subscribe();


        return response;
    }

    private Mono<Request> transformObject(OrdersModel appointmentStatus, Request request) {

        request.setContext(request.getContext());
        Provider provider = new Provider();
        Descriptor descriptor = new Descriptor();
        Fulfillment fulfillment = new Fulfillment();
        Person person = new Person();
        Time time = new Time();
        Range range = new Range();
        Customer customer = new Customer();
        Person patient = new Person();
        Quote quote = new Quote();
        Price price = new Price();
        List<Breakup> breakupList = new ArrayList<>();
        Payment payment = new Payment();

        Order orderFromRequest = request.getMessage().getOrder();

        provider.setId(appointmentStatus.getHealthcareProviderId());
        descriptor.setName(appointmentStatus.getHealthcareProviderName());


        setPersonDetails(appointmentStatus, person);
        setRangeDetails(appointmentStatus, range);

        time.setRange(range);

        setPatientDetails(appointmentStatus, patient);

        setCustomerDetails(appointmentStatus, customer, patient);

        setQuoteDetails(appointmentStatus, quote, price, breakupList);

        payment.setStatus(appointmentStatus.getPayment().getTransactionState());

        setFulfillmentsDetails(appointmentStatus, fulfillment, person, time, customer, quote);
        setOrderDetails(appointmentStatus, fulfillment, payment, orderFromRequest);

        request.getMessage().setOrder(orderFromRequest);
        return Mono.just(request);



    }

    private void setCustomerDetails(OrdersModel appointmentStatus, Customer customer, Person patient) {
        customer.setCred(appointmentStatus.getAbhaId());
        customer.setPerson(patient);
    }

    private void setOrderDetails(OrdersModel appointmentStatus, Fulfillment fulfillment, Payment payment, Order orderFromRequest) {
        orderFromRequest.setFulfillment(fulfillment);
        orderFromRequest.setPayment(payment);
        orderFromRequest.setState(appointmentStatus.getIsServiceFulfilled());
    }

    private void setFulfillmentsDetails(OrdersModel appointmentStatus, Fulfillment fulfillment, Person person, Time time, Customer customer, Quote quote) {
        fulfillment.setPerson(person);
        fulfillment.setTime(time);
        fulfillment.setCustomer(customer);
        fulfillment.setQuote(quote);
        fulfillment.setId(appointmentStatus.getSlotId());
        fulfillment.setType(appointmentStatus.getServiceFulfillmentType());
    }

    private void logMessageId(Request objRequest) {
        String messageId = objRequest.getContext().getMessageId();
        LOGGER.info(ConstantsUtils.REQUESTER_MESSAGE_ID_IS, messageId);
    }

    private void setQuoteDetails(OrdersModel appointmentStatus, Quote quote, Price price, List<Breakup> breakupList) {
        price.setCurrency(appointmentStatus.getPayment().getCurrency());
        String consultationCharge = appointmentStatus.getPayment().getConsultationCharge();
        String cgst = appointmentStatus.getPayment().getCgst();
        String sgst = appointmentStatus.getPayment().getSgst();
        String phrHandlingFees = appointmentStatus.getPayment().getPhrHandlingFees();

        String estimatedValueConvertedFromDouble = String.valueOf(Double.parseDouble(consultationCharge) + Double.parseDouble(cgst) + Double.parseDouble(sgst) + Double.parseDouble(phrHandlingFees));
        price.setEstimatedValue(estimatedValueConvertedFromDouble);

        Breakup cgstBreakup = new Breakup();
        Breakup sgstBreakup = new Breakup();
        Breakup consultationBreakup = new Breakup();
        Breakup phrHandlingBreakup = new Breakup();

        Price pricecgst = new Price();
        Price pricesgst = new Price();
        Price phrHAndling = new Price();
        Price consultation = new Price();
        pricecgst.setValue(appointmentStatus.getPayment().getCgst());
        pricesgst.setValue(appointmentStatus.getPayment().getSgst());
        phrHAndling.setValue(appointmentStatus.getPayment().getPhrHandlingFees());
        consultation.setValue(appointmentStatus.getPayment().getConsultationCharge());

        cgstBreakup.setTitle("cgst");
        cgstBreakup.setPrice(pricecgst);
        sgstBreakup.setTitle("sgst");
        sgstBreakup.setPrice(pricesgst);
        phrHandlingBreakup.setTitle("phr_handling_fees");
        phrHandlingBreakup.setPrice(phrHAndling);
        consultationBreakup.setTitle("consultation");
        consultationBreakup.setPrice(consultation);

        breakupList.add(cgstBreakup);
        breakupList.add(sgstBreakup);
        breakupList.add(consultationBreakup);
        breakupList.add(phrHandlingBreakup);

        price.setBreakup(breakupList);
        quote.setPrice(price);
    }

    private void setPatientDetails(OrdersModel appointmentStatus, Person patient) {
        patient.setCred(appointmentStatus.getAbhaId());
        patient.setName(appointmentStatus.getPatientName());
    }

    private void setRangeDetails(OrdersModel appointmentStatus, Range range) {
        range.setStart(appointmentStatus.getServiceFulfillmentStartTime());
        range.setEnd(appointmentStatus.getServiceFulfillmentEndTime());
    }

    private void setPersonDetails(OrdersModel appointmentStatus, Person person) {
        person.setId(appointmentStatus.getHealthcareProviderId());
        person.setName(appointmentStatus.getHealthcareProfessionalName());
        person.setGender(appointmentStatus.getHealthcareProfessionalGender());
        person.setImage(appointmentStatus.getHealthcareProfessionalImage());
        person.setCred(appointmentStatus.getHealthcareProviderId());
    }

    private Mono<OrdersModel> getAppointmentStatus(Request request) {
        String orderIdFromRequest = request.getMessage().getOrder().getId();
        List<OrdersModel> orderRecord = orderRepository.findByOrderId(orderIdFromRequest);
        if(orderRecord != null && !orderRecord.isEmpty()) {
            return Mono.just(orderRecord.get(0));
        }
        else{
            return null;
        }
    }


    private Mono<String> callOnStatus(Request request) {

        WebClient on_webclient = WebClient.create();

        return on_webclient.post()
                .uri(request.getContext().getConsumerUri() + "/on_status")
                .body(BodyInserters.fromValue(request))
                .retrieve()
                .bodyToMono(String.class)
                .onErrorResume(error -> {
                    LOGGER.error("Error in status API::error::onErrorResume:: {}", error,null);
                    return Mono.empty();
                });
    }

    @Override
    public Mono<String> logResponse(String result) {


        LOGGER.info("OnConfirm::Log::Response:: {}", result);
        return Mono.just(result);
    }
    private static Response generateAck() {

        String jsonString;
        MessageAck msz = new MessageAck();
        Response res = new Response();
        Ack ack = new Ack();
        ack.setStatus("ACK");
        msz.setAck(ack);
        in.gov.abdm.uhi.common.dto.Error err = new in.gov.abdm.uhi.common.dto.Error();
        res.setError(err);
        res.setMessage(msz);
        return res;
    }

    private static Response generateNack(Exception js) {

        MessageAck msz = new MessageAck();
        Response res = new Response();
        Ack ack = new Ack();
        ack.setStatus("NACK");
        msz.setAck(ack);
        in.gov.abdm.uhi.common.dto.Error err = new Error();
        err.setMessage(js.getMessage());
        err.setType("Search");
        res.setError(err);
        res.setMessage(msz);
        return res;
    }
}
