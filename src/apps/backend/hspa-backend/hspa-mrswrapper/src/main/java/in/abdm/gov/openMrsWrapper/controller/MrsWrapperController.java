package in.abdm.gov.openMrsWrapper.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import in.abdm.gov.openMrsWrapper.service.impl.MrsWrapperServiceImpl;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

@RestController
public class MrsWrapperController {
    private static final Logger LOGGER = LogManager.getLogger(MrsWrapperController.class);


    final ObjectMapper objectMapper;
    final MrsWrapperServiceImpl mrsWrapperServiceImpl;

    public MrsWrapperController(ObjectMapper objectMapper, MrsWrapperServiceImpl mrsWrapperServiceImpl) {
        this.objectMapper = objectMapper;
        this.mrsWrapperServiceImpl = mrsWrapperServiceImpl;
    }

    @PostMapping(value ="/providers", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ResponseEntity<String>> addProvider(@RequestBody String addProviderDTO) {
        LOGGER.info("MrsWrapperController::/providers::Request received:: {}",addProviderDTO);
        return mrsWrapperServiceImpl.callMrsPost(addProviderDTO, "/provider", null);
    }

    @PostMapping(value = "/providers/{doctorId}/attribute", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ResponseEntity<String>> addProviderAttributeForGivenDoctor(@RequestBody String addProviderDTO, @PathVariable(name = "doctorId") String doctorId) {
        LOGGER.info("MrsWrapperController::/providers/{doctorId}/attribute::Request received:: {}",addProviderDTO);
        return mrsWrapperServiceImpl.callMrsPost(addProviderDTO, "/provider/"+doctorId+"/attribute", null);
    }

    @PutMapping(value = "/providers/{providerUUID}/attribute/{attributeUUID}", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ResponseEntity<String>> updateAttribute(@RequestBody String addProviderDTO, @PathVariable(name = "providerUUID") String providerUUID, @PathVariable(name = "attributeUUID") String attributeUUID) {
        LOGGER.info("MrsWrapperController::/providers/{providerUUID}/attribute/{attributeUUID}:: {}",addProviderDTO);
        return mrsWrapperServiceImpl.callMrsPost(addProviderDTO, "/provider/"+providerUUID+"/attribute/"+attributeUUID, null);
    }

    @DeleteMapping(value = "/providers/{providerUUID}/attribute/{attributeUUID}", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ResponseEntity<String>> deleteAttribute(@RequestBody String addProviderDTO, @PathVariable(name = "providerUUID") String providerUUID, @PathVariable(name = "attributeUUID") String attributeUUID) {
        LOGGER.info("MrsWrapperController::/providers/{providerUUID}/attribute/{attributeUUID}::and Path vars are ->> {} {} {}  ",providerUUID,addProviderDTO ,attributeUUID);
        return mrsWrapperServiceImpl.callMrsDelete(addProviderDTO, "/provider/"+providerUUID+"/attribute/"+attributeUUID, null);
    }

    @GetMapping(value = "/providers", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ResponseEntity<String>> viewAndListProvider(@RequestParam MultiValueMap<String,String> allParams) {
        LOGGER.info("MrsWrapperController::GET:/providers {}",allParams.toString());
        return mrsWrapperServiceImpl.callMrsGet( "/provider", allParams);
    }

    @GetMapping(value = "/providers/attributes", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ResponseEntity<String>> listProviderAttribute(@RequestParam MultiValueMap<String,String> allParams) {
        LOGGER.info("MrsWrapperController::GET:/providers/attributes {}", allParams);
        return mrsWrapperServiceImpl.callMrsGet( "/providerattributetype", allParams);
    }

    @GetMapping(value = "/appointments/statushistory", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ResponseEntity<String>> listProviderVisitTypes(@RequestParam MultiValueMap<String,String> allParams) {
        LOGGER.info("MrsWrapperController::GET:/appointments/statushistory {}",allParams);
        return mrsWrapperServiceImpl.callMrsGet( "/appointmentscheduling/appointmentstatushistory", allParams);
    }

    @GetMapping(value = "/appointments", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ResponseEntity<String>> getListOfScheduledAppointment(@RequestParam MultiValueMap<String,String> allParams) {
        LOGGER.info("MrsWrapperController::GET:/appointments {}",allParams);
        return mrsWrapperServiceImpl.callMrsGet( "/appointmentscheduling/appointment", allParams);
    }

    @PutMapping(value = "/appointments/{appointmentNo}", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ResponseEntity<String>> updateAppointmentStatus(@RequestBody String addProviderDTO, @PathVariable(name = "appointmentNo") String appointmentNo) {
        LOGGER.info("MrsWrapperController::GET:/appointments {}", addProviderDTO);
        return mrsWrapperServiceImpl.callMrsPost(addProviderDTO, "/appointmentscheduling/appointment/"+appointmentNo, null);
    }


    @GetMapping(value = "/appointments/timeslot", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ResponseEntity<String>> getListOfAvailableAppointmentTimeSlots(@RequestParam MultiValueMap<String,String> allParams) {
        return mrsWrapperServiceImpl.callMrsGet( "/appointmentscheduling/appointment", allParams);
    }

    @PostMapping(value = "/appointments", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ResponseEntity<String>> getAppointmentStatusTypes(@RequestBody String addProviderDTO, @RequestParam MultiValueMap<String,String> allParams) {
        return mrsWrapperServiceImpl.callMrsPost(addProviderDTO, "appointmentscheduling/appointmentstatustype", allParams);
    }

    @PostMapping(value = "/slot", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ResponseEntity<String>> createAppointment(@RequestBody String addProviderDTO) {
        LOGGER.info("MrsWrapperController::POST:/slot {}", addProviderDTO);

        return mrsWrapperServiceImpl.callMrsPost(addProviderDTO, "appointmentscheduling/appointmentblockwithtimeslot", null);
    }

    @GetMapping(value = "/slots", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ResponseEntity<String>> getListOfAvailableTimeSlots(@RequestParam MultiValueMap<String,String> allParams) {

        return mrsWrapperServiceImpl.callMrsGet( "/appointmentscheduling/timeslot", allParams);
    }

    @PostMapping(value = "/cancel/appointment", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ResponseEntity<String>> cancelAppointment(@RequestParam MultiValueMap<String,String> allParams, @RequestBody String cancelRequest) {
        LOGGER.info("MrsWrapperController::POST:/cancel/appointment {}", cancelRequest);

        return mrsWrapperServiceImpl.callHspaPost( cancelRequest,"/cancel", allParams);
    }

}
