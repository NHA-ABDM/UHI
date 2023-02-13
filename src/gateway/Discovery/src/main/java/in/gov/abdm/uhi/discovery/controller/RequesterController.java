
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
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import in.gov.abdm.uhi.common.dto.Response;
import in.gov.abdm.uhi.discovery.exception.JsonValidator;
import in.gov.abdm.uhi.discovery.security.SignatureUtility;
import in.gov.abdm.uhi.discovery.service.RequesterService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/v1")
@Api(value = "Search Requestor", description = "Search requestor to broadcast the message over HSPAs")
@Validated
public class RequesterController {

	private static final Logger LOGGER = LogManager.getLogger(RequesterController.class);

	@Autowired
	RequesterService requesterService;

	@Autowired
	SignatureUtility signatureUtility;

	@ApiOperation(value = "To broadcast the search result on HSPAs", response = Response.class)
	@PostMapping(value = "/search", consumes = "application/json", produces = "application/json")
	public ResponseEntity<Mono<String>> search(@Valid @RequestBody String request,
			@RequestHeader Map<String, String> headers) {

		Mono<String> response = null;
		String validator_resp = null;
		try {
			validator_resp = JsonValidator.validateJson(request, "search-schema.json");
			if (validator_resp.contains("NACK")) {
				return ResponseEntity.badRequest().body(Mono.just(validator_resp));
			}

			LOGGER.info("Requester::called :: {}", request);
			response = requesterService.processor(request, headers);

			// LOGGER.info("{} | {}", reqroot.getContext().getMessageId(), response.log());

		} catch (Exception ex) {
			LOGGER.info("Requester::error:: {}", request);
			LOGGER.error("Requester::error:: {}", ex);

		}
		return ResponseEntity.ok(response);
		// return response;
	}
}
