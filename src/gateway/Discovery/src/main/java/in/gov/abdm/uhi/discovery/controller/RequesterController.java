
/*
 * Copyright 2022  NHA
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package in.gov.abdm.uhi.discovery.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import in.gov.abdm.uhi.common.dto.Response;
import in.gov.abdm.uhi.discovery.exception.JsonValidator;
import in.gov.abdm.uhi.discovery.service.RequesterService;
import in.gov.abdm.uhi.discovery.utility.GatewayConstants;
import in.gov.abdm.uhi.discovery.utility.GlobalConstants;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
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
@Api(value = "Search Requestor")
@Validated
public class RequesterController {

    private static final Logger LOGGER = LogManager.getLogger(RequesterController.class);

    final
    RequesterService requesterService;

    public RequesterController(RequesterService requesterService) {
        this.requesterService = requesterService;
    }

    @ApiOperation(value = "To broadcast the search result on HSPAs", response = Response.class)
    @PostMapping(value = GlobalConstants.SEARCH_ENDPOINT, consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Mono<String>> search(@Valid @RequestBody String request,
                                               @RequestHeader Map<String, String> headers) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        String requestId= UUID.randomUUID().toString();
        StackTraceElement trace = Thread.currentThread().getStackTrace()[1];
        String origin = trace.getClassName()+"."+trace.getMethodName();
        LOGGER.info("59 SEARCH ENDPOINT search() {} | Request ID: {} | Request received on: {} | request {} ", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, GlobalConstants.SEARCH_ENDPOINT);
        Mono<String> response = null;
        String validatorResp;
            validatorResp = JsonValidator.validateJson(request, "search-schema.json");
            if (validatorResp.contains("NACK")) {
                LOGGER.debug("SEARCH ENDPOINT search() {} | Request ID: {} | Failed: Schema Validation: {}", origin+":"+Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, validatorResp);
                return ResponseEntity.badRequest().body(Mono.just(validatorResp));
            }
            response = requesterService.processor(request, headers, requestId);
        return ResponseEntity.ok(response);
    }
}
