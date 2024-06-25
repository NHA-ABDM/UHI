
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
import in.gov.abdm.uhi.discovery.service.ResponderService;
import in.gov.abdm.uhi.discovery.utility.GatewayConstants;
import in.gov.abdm.uhi.discovery.utility.GlobalConstants;
import io.swagger.annotations.Api;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
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
@Api(value = "On_Search Responder")
@Validated
public class ResponderController {

    private static final Logger LOGGER = LogManager.getLogger(ResponderController.class);

    final
    ResponderService responderService;

    public ResponderController(ResponderService responderService) {
        this.responderService = responderService;
    }

    @PostMapping(value = GlobalConstants.ON_SEARCH_ENDPOINT, consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<String> onSearch(@Valid @RequestBody String request, @RequestHeader Map<String, String> headers) throws JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        try {
            Mono<String> response = null;
            String requestId = UUID.randomUUID().toString();
            StackTraceElement trace = Thread.currentThread().getStackTrace()[1];
            String origin = trace.getClassName() + "." + trace.getMethodName() + ":" + trace.getLineNumber();
            LOGGER.info("55 ON_SEARCH onSearch() {} | Request ID: {} | Request received on: {}", origin + ":" + Thread.currentThread().getStackTrace()[1].getLineNumber(), requestId, GlobalConstants.ON_SEARCH_ENDPOINT);
            response = responderService.processor(request, headers, requestId);
            return response;
        }catch (Exception e){
            e.printStackTrace();
            System.out.println("onSearch :: "+e.getStackTrace());

        }
        return null;
    }
}
