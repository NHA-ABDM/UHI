
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

import in.gov.abdm.uhi.discovery.service.RequesterService;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

import javax.validation.Valid;

@Validated
@RestController
@RequestMapping("/api/v1")
public class RequesterController {

    private static final Logger LOGGER = LogManager.getLogger(RequesterController.class);

    @Autowired
    RequesterService requesterService;

    @PostMapping(value = "/search", consumes = "application/json", produces = "application/json")
    public Flux<String> search(@Valid @RequestBody String request) {
        LOGGER.info("Requester::called");

        Flux<String> response = Flux.just("Response Empty");

        try {
            response = requesterService.processor(request);
        } catch (Exception ex) {
            LOGGER.info("Requester::error::" + request);
            LOGGER.error("Requester::error::" + ex);
        }

        return response;
    }
}
