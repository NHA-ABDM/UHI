package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.hspa.models.IntermediatePatientAppointmentModel;
import in.gov.abdm.uhi.hspa.service.ServiceInterface.IService;
import in.gov.abdm.uhi.hspa.utils.IntermediateBuilderUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import reactor.util.function.Tuple2;

import java.util.ArrayList;
import java.util.List;

@Service
public class StatusService implements IService {

    private static final String API_RESOURCE_APPOINTMENT = "appointmentscheduling/appointment";
    private static final String API_RESOURCE_PATIENT = "patient";

    private static final Logger LOGGER = LogManager.getLogger(ConfirmService.class);
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
    @Autowired
    WebClient webClient;
    @Autowired
    ObjectMapper mapper;

    @Override
    public Mono<Response> processor(String request) {

        Request objRequest = new Request();
        Response ack = generateAck();

        LOGGER.info("Processing::Confirm::Request::" + request);
        System.out.println("Processing::Confirm::Request::" + request);

        try {
            objRequest = new ObjectMapper().readValue(request, Request.class);
            Request finalObjRequest = objRequest;

            run(finalObjRequest);

        } catch (Exception ex) {
            LOGGER.error("Confirm Service process::error::onErrorResume::" + ex);
            ack = generateNack(mapper, ex);

        }

        Mono<Response> responseMono = Mono.just(ack);

        return responseMono;
    }

    @Override
    public Mono<String> run(Request request) {
        Mono<String> response = Mono.empty();
        getAppointmentStatus(request).zipWith(getPatient(request))
                .flatMap(result -> validateAppointment(result,request))
                .flatMap(result -> callOnStatus(result, request))
                .subscribe();
        return response;
    }

    private Mono<String> getAppointmentStatus(Request request) {

        String appointmentRefId = request.getMessage().getOrder().getRef_id();
        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_APPOINTMENT;
        String view = "?v=custom:uuid,status,timeSlot:(uuid,startDate,endDate),appointmentType:(display),patient:(identifiers:(display),person:(display,gender))";
        return webClient.get()
                .uri(searchEndPoint + "/" +appointmentRefId + view)
                .exchangeToMono(clientResponse -> {
                    return clientResponse.bodyToMono(String.class);
                });
    }
    private Mono<String> getPatient(Request request) {

        String abha = request.getMessage().getOrder().getCustomer().getCred();
        String searchEndPoint = OPENMRS_BASE_LINK + OPENMRS_API + API_RESOURCE_PATIENT;
        String query = "?q="+abha+"&v=default&limit=10&index=0";
        return webClient.get()
                .uri(searchEndPoint + query)
                .exchangeToMono(clientResponse -> {
                    return clientResponse.bodyToMono(String.class);
                });
    }

    private Mono<List<IntermediatePatientAppointmentModel>> validateAppointment(Tuple2 result, Request request) {
        List<IntermediatePatientAppointmentModel> patientModel = new ArrayList<IntermediatePatientAppointmentModel>();

        try {

            patientModel = IntermediateBuilderUtils.BuildIntermediatePatientAppoitmentObj(result.getT1().toString(), result.getT2().toString(), request.getMessage().getOrder());



        } catch (Exception ex) {
            LOGGER.error("Select service Get Provider Id::error::onErrorResume::" + ex);
        }

        return Mono.just(patientModel);
    }


    private Mono<String> callOnStatus(List<IntermediatePatientAppointmentModel> validAppointment, Request request) {

        Request onStatusRequest = request;

        Boolean validStatus = false;

        if(!validAppointment.isEmpty())
        {
            validStatus =  validAppointment.get(0).getAppointmentId().equals(request.getMessage().getOrder().getRef_id());
            validStatus =  validAppointment.get(0).getName().equals(request.getMessage().getOrder().getCustomer().getPerson().getName());
        }

        if(validStatus)
        {
            onStatusRequest.getMessage().getOrder().setState(validAppointment.get(0).getStatus());
        }
        else {

            onStatusRequest.getMessage().getOrder().setState("FAILED");
        }

        System.out.println(onStatusRequest);

        WebClient on_webclient = WebClient.create();

        return on_webclient.post()
                .uri(onStatusRequest.getContext().getConsumerUri() + "/on_status")
                .body(BodyInserters.fromValue(onStatusRequest))
                .retrieve()
                .bodyToMono(String.class)
                .retry(3)
                .onErrorResume(error -> {
                    LOGGER.error("Select Service Call on_search::error::onErrorResume::" + error);
                    return Mono.empty();
                });
    }

    @Override
    public Mono<String> logResponse(String result) {


        LOGGER.info("OnConfirm::Log::Response::" + result);
        System.out.println("OnConfirm::Log::Response::" + result);

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

    private static Response generateNack(ObjectMapper mapper, Exception js) {

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
