package in.gov.abdm.uhi.hspa.controller;

import in.gov.abdm.uhi.common.dto.Response;
import in.gov.abdm.uhi.hspa.service.BloodBankSearchService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import javax.validation.Valid;
import java.util.Map;

import static in.gov.abdm.uhi.hspa.utils.ConstantsUtils.*;

@Slf4j
@Validated
@RestController
@RequestMapping("/api/v1/bloodbank")
public class BloodBankController {

    @Autowired
    BloodBankSearchService bloodBankSearchService;

    @PostMapping(value = SEARCH_ENDPOINT, consumes = APPLICATION_JSON, produces = APPLICATION_JSON)
    public ResponseEntity<Mono<Response>> search(@Valid @RequestBody String request, @RequestHeader Map<String, String> headers) throws Exception {
        log.info(REQUESTER_CALLED + SEARCH_ENDPOINT);
        ResponseEntity<Mono<Response>> res = null;
        log.info("Gateway Headers {}", headers);
        return ResponseEntity.status(HttpStatus.OK).body(bloodBankSearchService.processor(request, headers));
    }

}
