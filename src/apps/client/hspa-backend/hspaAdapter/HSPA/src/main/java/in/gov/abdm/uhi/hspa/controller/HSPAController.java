
/*
 * Copyright 2022  NHA
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package in.gov.abdm.uhi.hspa.controller;

import in.gov.abdm.uhi.common.dto.Response;
import in.gov.abdm.uhi.hspa.dto.*;
import in.gov.abdm.uhi.hspa.models.ChatUserModel;
import in.gov.abdm.uhi.hspa.models.MessagesModel;
import in.gov.abdm.uhi.hspa.models.UserTokenModel;
import in.gov.abdm.uhi.hspa.service.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.modelmapper.ModelMapper;
import org.modelmapper.TypeToken;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import javax.validation.Valid;
import javax.validation.constraints.NotEmpty;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Validated
@RestController
@RequestMapping("/api/v1")
public class HSPAController {

    private static final Logger LOGGER = LogManager.getLogger(HSPAController.class);

    final
    SearchService searchService;

    final
    SelectService selectService;

    final
    InitService initService;

    final
    ConfirmService confirmService;

    final
    MessageService messageService;

    final
    StatusService statusService;
    final
    SaveChatService chatIndb;

    final
    ModelMapper modelMapper;

    final
    PushNotificationService pushNotificationService;
    public HSPAController(SearchService searchService, SelectService selectService, InitService initService, ConfirmService confirmService, StatusService statusService, SaveChatService chatIndb, ModelMapper modelMapper, MessageService messageService, PushNotificationService pushNotificationService) {
        this.searchService = searchService;
        this.selectService = selectService;
        this.initService = initService;
        this.confirmService = confirmService;
        this.statusService = statusService;
//        this.messageService = messageService;
        this.chatIndb = chatIndb;
        this.modelMapper = modelMapper;
        this.messageService = messageService;
        this.pushNotificationService = pushNotificationService;
    }

    @PostMapping(value = "/search", consumes = "application/json", produces = "application/json")
    public Mono<Response> search(@Valid @RequestBody String request, @RequestHeader(value = "X-Gateway-Authorization", required = false) String gatewayHeader){
        LOGGER.info("Search::called");

        Mono<Response> res = Mono.just(new Response());
        try
        {
            if(gatewayHeader == null)
            {
                res =  selectService.processor(request);
            }
            else {
                System.out.println(gatewayHeader);
                res = searchService.processor(request);
            }
        } catch (Exception ex) {
            LOGGER.info("Search::error::" + request);
            LOGGER.error("Search::error::" + ex);
        }

        return res;
    }

    @PostMapping(value = "/select", consumes = "application/json", produces = "application/json")
    public Mono<Response> select(@Valid @RequestBody String request) {
        LOGGER.info("Requester::called");
        Mono<Response> res = Mono.just(new Response());
        try {
            res = selectService.processor(request);

        } catch (Exception ex) {
            LOGGER.info("Requester::error::" + request);
            LOGGER.error("Requester::error::" + ex);
        }

        return res;
    }

    @PostMapping(value = "/init", consumes = "application/json", produces = "application/json")
    public Mono<Response> init(@Valid @RequestBody String request)  {
        LOGGER.info("Requester::called");
        Mono<Response> res = Mono.just(new Response());
        try
        {
            res =  initService.processor(request);

        } catch (Exception ex) {
            LOGGER.info("Requester::error::" + request);
            LOGGER.error("Requester::error::" + ex);
        }

        return res;
    }

    @PostMapping(value = "/confirm", consumes = "application/json", produces = "application/json")
    public Mono<Response> confirm(@Valid @RequestBody String request)  {
        LOGGER.info("Requester::called");

        Mono<Response> res = Mono.just(new Response());
        try
        {
           res =  confirmService.processor(request);

        } catch (Exception ex) {
            LOGGER.info("Requester::error::" + request);
            LOGGER.error("Requester::error::" + ex);
        }

        return res;
    }

    @PostMapping(value = "/status", consumes = "application/json", produces = "application/json")
    public Mono<Response> status(@Valid @RequestBody String request) {
        LOGGER.info("Requester::called");

        Mono<Response> res = Mono.just(new Response());
        try
        {
            res = statusService.processor(request);

        } catch (Exception ex) {
            LOGGER.info("Requester::error::" + request);
            LOGGER.error("Requester::error::" + ex);
        }

        return res;
    }

    @PostMapping(value = "/on_message", consumes = "application/json", produces = "application/json")
    public Mono<Response> onMessage(@Valid @RequestBody String request) {
        LOGGER.info("Requester::called on_message");
        Mono<Response> res = Mono.just(new Response());
        try
        {
            res =  messageService.processor(request);

        } catch (Exception ex) {
            LOGGER.info("Requester::error::" + request);
            LOGGER.error("Requester::error::" + ex);
        }

        return res;
    }

    @PostMapping(value = "/message", consumes = "application/json", produces = "application/json")
    public Mono<Response> message(@Valid @RequestBody String request) {
        LOGGER.info("Requester::called message");

        Mono<Response> res = Mono.just(new Response());
        try
        {
            res =  messageService.processor(request);
        } catch (Exception ex) {
            LOGGER.info("Requester::error::" + request);
            LOGGER.error("Requester::error::" + ex);
        }

        return res;
    }

    @GetMapping(path = "/getMessages/{sender}/{receiver}")
    public ResponseEntity<List<? extends ServiceResponseDTO>> getMessagesBetweenTwo(@PathVariable("sender") String sender, @PathVariable("receiver") String receiver,
                                                                                    @RequestParam(value ="pageNumber",defaultValue="0",required=false)Integer pageNumber,
                                                                                    @RequestParam(value ="pageSize",defaultValue="200",required=false)Integer pageSize) {
        LOGGER.info("inside getMessagesBetweenTwo");

        LOGGER.info("Requester::sender ::" + sender);
        LOGGER.info("Requester::receiver ::" + receiver);
        LOGGER.info("Requester::pageNumber ::" + pageNumber);
        LOGGER.info("Requester::pageSize ::" + pageSize);

        try {
            List<MessagesModel> getMessageDetails = chatIndb.getMessagesBetweenTwo(sender, receiver, pageNumber, pageSize);
            List<MessagesDTO> messagesDto = convertToMessageDto(getMessageDetails);
            return new ResponseEntity<>(messagesDto, HttpStatus.OK);
        } catch (Exception e) {
            LOGGER.info("Requester::error::sender ::" + sender);
            LOGGER.info("Requester::error::receiver ::" + receiver);

            LOGGER.error(e.getMessage());
            List<? extends ServiceResponseDTO> messagesDTOS = getErrorMessage(e.getMessage());

            return new ResponseEntity<>(messagesDTOS, HttpStatus.INTERNAL_SERVER_ERROR);

        }

    }

    @GetMapping(path = "/getUser/{userid}")
    public ResponseEntity<List<? extends ServiceResponseDTO>> getUserById(@Valid @NotEmpty(message = "user id is required") @PathVariable("userid") String userId) {
        LOGGER.info("inside Get user by id");
        try {
//            if(userId == null)
            LOGGER.info("user id given is -: ->>>>>>" + userId);
            List<ChatUserModel> getUserDetails = chatIndb.getUserDetails(userId);
            return new ResponseEntity<>(getUserDetails, HttpStatus.OK);
        }catch (Exception e) {
            LOGGER.info("Requester::error ::" + e.getMessage());
            ChatUserModel error = new ChatUserModel();
            List<? extends ServiceResponseDTO> messagesDTOS = getErrorMessage(e.getMessage());

            return new ResponseEntity<>(messagesDTOS, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }



//    @ApiOperation(value = "Send notification to HSPA ", notes="this endpoint will send notification to HSPA based on given token ")
    @PostMapping("/notification/token")
    public ResponseEntity<PushNotificationResponseDTO> sendTokenNotification(@RequestBody PushNotificationRequestDTO request) {
        try {
            pushNotificationService.sendPushNotificationToToken(request);
        } catch (ExecutionException | InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("send notification");
        return new ResponseEntity<>(new PushNotificationResponseDTO(HttpStatus.OK.value(), "Notification has been sent."), HttpStatus.OK);
    }

        @PostMapping("/saveToken")
    public ResponseEntity<PushNotificationResponseDTO> saveToken(@RequestBody RequestTokenDTO request) {
        UserTokenModel saveUserTokenModel = chatIndb.saveUserToken(request);
        if(null!= saveUserTokenModel)
        {
            return new ResponseEntity<>(new PushNotificationResponseDTO(HttpStatus.OK.value(), "token saved"), HttpStatus.OK);
        }
        else
        {
            return new ResponseEntity<>(new PushNotificationResponseDTO(HttpStatus.BAD_REQUEST.value(), "token not saved"), HttpStatus.OK);
        }
    }


    private List<MessagesDTO> convertToMessageDto(List<MessagesModel> getMessageDetails) {
        return modelMapper.map(getMessageDetails, new TypeToken<List<MessagesDTO>>() {}.getType());
    }

    private List<? extends ServiceResponseDTO> getErrorMessage(String message) {
        ServiceResponseDTO messagesDTO = new ServiceResponseDTO();
        ErrorResponseDTO errorResponseDTO =  new ErrorResponseDTO();
        errorResponseDTO.setErrorString(message);
        errorResponseDTO.setCode("500");
        errorResponseDTO.setPath("getMessagesBetweenTwo");
        messagesDTO.setError(errorResponseDTO);

        List<ServiceResponseDTO> messagesDTOS = new ArrayList<>();
        messagesDTOS.add(messagesDTO);
        return messagesDTOS;
    }

}
