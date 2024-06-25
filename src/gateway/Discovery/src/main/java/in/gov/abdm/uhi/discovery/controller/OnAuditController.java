package in.gov.abdm.uhi.discovery.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import in.gov.abdm.uhi.discovery.service.AuditService;
import in.gov.abdm.uhi.discovery.service.ResponderService;
import in.gov.abdm.uhi.discovery.utility.GatewayConstants;
import in.gov.abdm.uhi.discovery.utility.GlobalConstants;
import io.swagger.annotations.Api;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import javax.validation.Valid;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.spec.InvalidKeySpecException;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping(GatewayConstants.API_VERSION)
@Api(value = "Audit Responder")
@Validated
public class OnAuditController {
    private static final Logger LOGGER = LogManager.getLogger(RequesterController.class);



    final AuditService auditService;



    public OnAuditController(AuditService auditService) {
        this.auditService=auditService;
    }
    @PostMapping(value = GlobalConstants.SEARCH_AUDIT_ENDPOINT, consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<String> searchAudit(@Valid @RequestBody String request, @RequestHeader Map<String, String> headers) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException{
        Mono<String> response=null;
        String requestId= UUID.randomUUID().toString();
        StackTraceElement trace=Thread.currentThread().getStackTrace()[1];
        String origin=trace.getClassName()+"."+trace.getMethodName()+"."+trace.getLineNumber();
        LOGGER.info("SEARCH_AUDIT_ENDPOINT onStatusAudit() {} | Request ID: {} | Request received on: {} | Request: {}",origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber() , requestId, GlobalConstants.ON_STATUS_AUDIT_ENDPOINT, request);
        response=auditService.auditProcessor(request,headers,requestId);
        return response;
    }

    @PostMapping(value = GlobalConstants.ON_CONFIRM_AUDIT_ENDPOINT, consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<String> onConfirmAudit(@Valid @RequestBody String request, @RequestHeader Map<String, String> headers) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        Mono<String> response = null;
        String requestId= UUID.randomUUID().toString();
        StackTraceElement trace = Thread.currentThread().getStackTrace()[1];
        String origin = trace.getClassName()+"."+trace.getMethodName()+":"+trace.getLineNumber();
        LOGGER.info("ON_CONFIRM_AUDIT_ENDPOINT {} | Request ID: {} | Request received on: {} | Request: {}",origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber() , requestId, GlobalConstants.ON_CONFIRM_AUDIT_ENDPOINT, request);
        response = auditService.auditProcessor(request,headers,requestId);
        return response;

    }
    @PostMapping(value = GlobalConstants.ON_STATUS_AUDIT_ENDPOINT, consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<String> onStatusAudit(@Valid @RequestBody String request, @RequestHeader Map<String, String> headers) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException{
        Mono<String> response=null;
        String requestId= UUID.randomUUID().toString();
        StackTraceElement trace=Thread.currentThread().getStackTrace()[1];
        String origin=trace.getClassName()+"."+trace.getMethodName()+"."+trace.getLineNumber();
        LOGGER.info("ON_STATUS_AUDIT_ENDPOINT onStatusAudit() {} | Request ID: {} | Request received on: {} | Request: {}",origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber() , requestId, GlobalConstants.ON_STATUS_AUDIT_ENDPOINT, request);
        response=auditService.auditProcessor(request,headers,requestId);
        return response;
    }

    @PostMapping(value = GlobalConstants.ON_CANCEL_AUDIT_ENDPOINT, consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<String> onCancelAudit(@Valid @RequestBody String request,@RequestHeader Map<String,String> headers) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException{
        Mono<String> response=null;
        String requestId= UUID.randomUUID().toString();
        StackTraceElement trace=Thread.currentThread().getStackTrace()[1];
        String origin=trace.getClassName()+"."+trace.getMethodName()+"."+trace.getLineNumber();
        LOGGER.info("ON_CANCEL_AUDIT_ENDPOINT {} | Request ID: {} | Request received on: {} | Request: {}",origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber() , requestId, GlobalConstants.ON_CANCEL_AUDIT_ENDPOINT, request);
        response=auditService.auditProcessor(request,headers,requestId);
        return response;
    }


}
