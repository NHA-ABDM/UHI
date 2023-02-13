
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

import java.util.Map;
import javax.validation.Valid;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import in.gov.abdm.uhi.discovery.service.ResponderService;
import io.swagger.annotations.Api;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/v1")
@Api(value = "On_Search Responder", description = "Accepter for all the on_search response from the HSPAs")
@Validated
public class ResponderController {

	private static final Logger LOGGER = LogManager.getLogger(ResponderController.class);

	@Autowired
	ResponderService responderService;

	@PostMapping(value = "/on_search", consumes = "application/json", produces = "application/json")
	public Mono<String> onSearch(@Valid @RequestBody String request, @RequestHeader Map<String, String> headers) {
		Mono<String> response = null;
		try {
			
			LOGGER.info("Responder::called::{}", request.trim());

			response = responderService.processor(request,headers);

		} catch (Exception ex) {
			LOGGER.info("Responder::error::{}", request);
			LOGGER.error("Responder::error::{}", ex);
		}

		return response;
	}

}
