
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

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.Response;
import in.gov.abdm.uhi.hspa.dto.*;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.models.*;
import in.gov.abdm.uhi.hspa.service.*;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.modelmapper.ModelMapper;
import org.modelmapper.TypeToken;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import reactor.core.publisher.Mono;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import javax.validation.constraints.NotEmpty;
import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.spec.InvalidKeySpecException;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import static in.gov.abdm.uhi.hspa.service.CommonService.*;
import static in.gov.abdm.uhi.hspa.utils.ConstantsUtils.*;

@RestController
@RequestMapping("/api/v1")
public class HSPAController {

    public static final String GET_USER_USERID_ENDPOINT = "/getUser/{userid}";
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
    CancelService cancelService;
    final
    MessageService messageService;
    final
    StatusService statusService;
    final
    SaveChatService chatIndb;
    final FileStorageService fileStorageService;
    final
    ModelMapper modelMapper;

    final ObjectMapper objectMapper;
    final
    PaymentService paymentService;
    final
    PushNotificationService pushNotificationService;

    @Value("${spring.file.upload-dir}")
    private String uploadDir;

    public HSPAController(SearchService searchService, SelectService selectService, InitService initService, ConfirmService confirmService, StatusService statusService, SaveChatService chatIndb, ModelMapper modelMapper, MessageService messageService, FileStorageService fileStorageService, ObjectMapper objectMapper, PushNotificationService pushNotificationService, CancelService cancelService, PaymentService paymentService) {
        this.searchService = searchService;
        this.selectService = selectService;
        this.initService = initService;
        this.confirmService = confirmService;
        this.objectMapper = objectMapper;
        this.cancelService = cancelService;
        this.statusService = statusService;
        this.chatIndb = chatIndb;
        this.modelMapper = modelMapper;
        this.messageService = messageService;
        this.fileStorageService = fileStorageService;
        this.pushNotificationService = pushNotificationService;
        this.paymentService = paymentService;
    }

    @PostMapping(value = SEARCH_ENDPOINT, consumes = APPLICATION_JSON, produces = APPLICATION_JSON)
    public ResponseEntity<Mono<Response>> search(@Valid @RequestBody String request, @RequestHeader Map<String, String> headers) throws Exception {
        LOGGER.info(REQUESTER_CALLED + SEARCH_ENDPOINT);

        ResponseEntity<Mono<Response>> res = null;

            if (headers.get(X_GATEWAY_AUTHORIZATION.toLowerCase()) == null) {
                    return ResponseEntity.status(HttpStatus.OK).body(selectService.processor(request, headers));

            } else {
                LOGGER.info("Gateway Headers {}", headers);

                    return ResponseEntity.status(HttpStatus.OK).body(searchService.processor(request, headers));

            }
    }

    @PostMapping(value = INIT_ENDPOINT, consumes = APPLICATION_JSON, produces = APPLICATION_JSON)
    public ResponseEntity<Mono<Response>> init(@Valid @RequestBody String request, @RequestHeader Map<String, String> headers) throws Exception {
        LOGGER.info(REQUESTER_CALLED + " " + INIT_ENDPOINT);
        ResponseEntity<Mono<Response>> res = null;
            res = CommonService.validateJson(request, INIT_SCHEMA_JSON_FILE);
            boolean ifrequestDoesntContainErrors = res == null;


                return ResponseEntity.status(HttpStatus.OK).body(initService.processor(request,headers));
    }

    @PostMapping(value = CONFIRM_ENDPOINT, consumes = APPLICATION_JSON, produces = APPLICATION_JSON)
    public ResponseEntity<Mono<Response>> confirm(@Valid @RequestBody String request, @RequestHeader Map<String, String> headers) throws Exception {
        LOGGER.info(REQUESTER_CALLED + CONFIRM_ENDPOINT);
        ResponseEntity<Mono<Response>> res = null;
                return ResponseEntity.status(HttpStatus.OK).body(confirmService.processor(request, headers));
    }

    @PostMapping(value = STATUS_ENDPOINT, consumes = APPLICATION_JSON, produces = APPLICATION_JSON)
    public ResponseEntity<Mono<Response>> status(@Valid @RequestBody String request, @RequestHeader Map<String, String> headers) throws Exception {
        LOGGER.info(REQUESTER_CALLED + STATUS_ENDPOINT);
        ResponseEntity<Mono<Response>> res = null;
                return ResponseEntity.status(HttpStatus.OK).body(statusService.processor(request, headers));
    }

    @PostMapping(value = CANCEL_ENDPOINT, consumes = APPLICATION_JSON, produces = APPLICATION_JSON)
    public ResponseEntity<Mono<Response>> cancel(@Valid @RequestBody String request, @RequestHeader Map<String, String> headers) throws Exception {
        LOGGER.info(REQUESTER_CALLED + CANCEL_ENDPOINT);
               return ResponseEntity.status(HttpStatus.OK).body(cancelService.processor(request,headers));
    }

    @PostMapping(value = ON_MESSAGE_ENDPOINT, consumes = APPLICATION_JSON, produces = APPLICATION_JSON)
    public ResponseEntity<Mono<Response>> onMessage(@RequestBody String request, @RequestHeader Map<String, String> headers) throws Exception {
        LOGGER.info(REQUESTER_CALLED + ON_MESSAGE_ENDPOINT);

        ResponseEntity<Mono<Response>> res = null;

            return ResponseEntity.status(HttpStatus.OK).body(messageService.processor(request, headers));
    }

    @PostMapping(value = MESSAGE_ENDPOINT, produces = APPLICATION_JSON)
    public ResponseEntity<Mono<Response>> message(@RequestBody String req, @RequestHeader Map<String, String> headers) throws Exception {
        LOGGER.info(REQUESTER_CALLED + MESSAGE_ENDPOINT);
            return ResponseEntity.status(HttpStatus.OK).body(messageService.processor(req, headers));
    }

    @GetMapping(path = GET_MESSAGES_SENDER_RECEIVER_ENDPOINT)
    public ResponseEntity<List<MessagesDTO>> getMessagesBetweenTwo(@PathVariable("sender") String sender, @PathVariable("receiver") String receiver,
                                                                          @RequestParam(value = "pageNumber", defaultValue = "0", required = false) Integer pageNumber,
                                                                          @RequestParam(value = "pageSize", defaultValue = "200", required = false) Integer pageSize) {
        LOGGER.info(REQUESTER_CALLED + GET_MESSAGES_SENDER_RECEIVER_ENDPOINT);

        LOGGER.info("Requester::sender ::{}", sender);
        LOGGER.info("Requester::receiver :: {}", receiver);
        LOGGER.info("Requester::pageNumber :: {}", pageNumber);
        LOGGER.info("Requester::pageSize :: {}", pageSize);

            List<MessagesModel> getMessageDetails = chatIndb.getMessagesBetweenTwo(sender, receiver, pageNumber, pageSize);
            List<MessagesDTO> messagesDto = convertToMessageDto(getMessageDetails);
            return new ResponseEntity<>(messagesDto, HttpStatus.OK);

    }

    @GetMapping(path = GET_USER_USERID_ENDPOINT)
    public ResponseEntity<List<ChatUserModel>> getUserById(@Valid @NotEmpty(message = "user id is required") @PathVariable("userid") String userId) {
        LOGGER.info(REQUESTER_CALLED + GET_USER_USERID_ENDPOINT);


            LOGGER.info("user id given is -: ->>>>>> {}", userId);
            List<ChatUserModel> getUserDetails = chatIndb.getUserDetails(userId);
            return new ResponseEntity<>(getUserDetails, HttpStatus.OK);

    }
    @PostMapping(NOTIFICATION_TOKEN_ENDPOINT)
    public ResponseEntity<PushNotificationResponseDTO> sendTokenNotification(@RequestBody PushNotificationRequestDTO request) {
        LOGGER.info(REQUESTER_CALLED + NOTIFICATION_TOKEN_ENDPOINT);
        PushNotificationResponseDTO res = null;
        try {
            pushNotificationService.sendPushNotificationToToken(request);
        } catch (Exception e) {
            LOGGER.error("HSPA Controller :: POST:notification/token error {}", e.getMessage());
            res = new PushNotificationResponseDTO();
            res.setResponse(getErrorMessage(e.getMessage()));
            return new ResponseEntity<>(res, HttpStatus.INTERNAL_SERVER_ERROR);

        }
        res = new PushNotificationResponseDTO();
        res.setResponse(generateAck());
        LOGGER.info("sent notification");
        return new ResponseEntity<>(res, HttpStatus.OK);
    }

    @PostMapping(SAVE_TOKEN_ENDPOINT)
    public ResponseEntity<PushNotificationResponseDTO> saveToken(@RequestBody String request) {
        LOGGER.info(REQUESTER_CALLED + SAVE_TOKEN_ENDPOINT);
        ResponseEntity<Mono<Response>> responseMono = null;
        PushNotificationResponseDTO res = null;
        try {
            responseMono = CommonService.validateJson(request, ConstantsUtils.SAVE_TOKEN_SCHEMA_JSON_SCHEMA);
            if (responseMono == null) {
                UserTokenModel saveUserTokenModel = chatIndb.saveUserToken(request);
                res = new PushNotificationResponseDTO();
                if (null != saveUserTokenModel) {
                    res.setResponse(generateAck());
                    return new ResponseEntity<>(res, HttpStatus.OK);
                } else {
                    res.setResponse(getErrorMessage("Unable to save token"));
                    return new ResponseEntity<>(res, HttpStatus.INTERNAL_SERVER_ERROR);
                }
            }
        } catch (Exception e) {
            res = new PushNotificationResponseDTO();
            res.setResponse(generateNack(e, INVALID_JSON_REQUEST, INVALID_JSON_REQUEST));
        }
        res = new PushNotificationResponseDTO();
        Response resErr = generateNack(new UserException("Something went wrong"), INVALID_JSON_REQUEST, INVALID_JSON_REQUEST);
        res.setResponse(resErr);
        return new ResponseEntity<>(res, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    @PostMapping(LOGOUT_ENDPOINT)
    public ResponseEntity<PushNotificationResponseDTO> logout(@RequestBody RequestTokenDTO request) {
        LOGGER.info(REQUESTER_CALLED + LOGOUT_ENDPOINT);
        PushNotificationResponseDTO res;
        res = new PushNotificationResponseDTO();
        try {
            chatIndb.deleteToken(request);
            res.setResponse(generateAck());
            return new ResponseEntity<>(res, HttpStatus.OK);
        } catch (Exception re) {
            res.setResponse(getErrorMessage(re.getMessage()));
            return new ResponseEntity<>(res, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }


    @PostMapping(SAVE_PUBLIC_KEY_ENDPOINT)
    public ResponseEntity<PushNotificationResponseDTO> savePublicKey(@RequestBody RequestPublicKeyDTO request) {
        LOGGER.info(REQUESTER_CALLED + SAVE_PUBLIC_KEY_ENDPOINT);

        PushNotificationResponseDTO res;
        res = new PushNotificationResponseDTO();
        PublicKeyModel savePublicKeyModel = chatIndb.savePublicKey(request);
        if (null != savePublicKeyModel) {
            res.setResponse(generateAck());
            return new ResponseEntity<>(res, HttpStatus.OK);
        } else {
            res.setResponse(getErrorMessage("Failed to save public key"));
            return new ResponseEntity<>(res, HttpStatus.INTERNAL_SERVER_ERROR);

        }
    }

    @GetMapping(path = GET_PUBLIC_KEY_USERNAME_ENDPOINT)
    public ResponseEntity<List<PublicKeyModel>> getKeyByUsername(@PathVariable("username") String userName) {
        LOGGER.info(REQUESTER_CALLED + GET_PUBLIC_KEY_USERNAME_ENDPOINT);

        List<PublicKeyModel> getKeyDetails = chatIndb.getKeyDetails(userName);
        return new ResponseEntity<>(getKeyDetails, HttpStatus.OK);
    }


    @PostMapping(SAVE_KEY_ENDPOINT)
    public ResponseEntity<SharedKeyModel> saveSharedKey(@RequestBody RequestSharedKeyDTO request) {
        LOGGER.info(REQUESTER_CALLED + SAVE_KEY_ENDPOINT);
        SharedKeyModel res;
        SharedKeyModel saveSharedKey = chatIndb.saveSharedKey(request);
        res = new SharedKeyModel();
        if (null != saveSharedKey) {
            res.setResponse(generateAck());
            return new ResponseEntity<>(saveSharedKey, HttpStatus.OK);
        } else {
            res.setResponse(getErrorMessage("Failed to save key"));
            return new ResponseEntity<>(res, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping(path = GET_KEY_USER_NAME_ENDPOINT)
    public ResponseEntity<List<SharedKeyModel>> getSharedKeyByUsername(@PathVariable("userName") String userName) {
        LOGGER.info(REQUESTER_CALLED + GET_KEY_USER_NAME_ENDPOINT);
        List<SharedKeyModel> getKeyDetails = chatIndb.getSharedKeyDetails(userName);
        return new ResponseEntity<>(getKeyDetails, HttpStatus.OK);
    }


    @PostMapping(UPLOAD_FILE_ENDPOINT)
    public UploadFileResponse uploadFile(@RequestParam("file") MultipartFile file) {
        LOGGER.info(REQUESTER_CALLED + UPLOAD_FILE_ENDPOINT);

        String fileName = fileStorageService.storeFile(file, uploadDir);

        String fileDownloadUri = ServletUriComponentsBuilder.fromCurrentContextPath()
                .path("/downloadFile/")
                .path(fileName)
                .toUriString();

        return new UploadFileResponse(fileName, fileDownloadUri,
                file.getContentType(), file.getSize());
    }

    @PostMapping(UPLOAD_MULTIPLE_FILES_ENDPOINT)
    public List<UploadFileResponse> uploadMultipleFiles(@RequestParam("files") MultipartFile[] files) {
        LOGGER.info(REQUESTER_CALLED + UPLOAD_MULTIPLE_FILES_ENDPOINT);

        return Arrays.stream(files)
                .map(this::uploadFile)
                .toList();
    }

    @GetMapping(DOWNLOAD_FILE_FILE_NAME_ENDPOINT)
    public ResponseEntity<Resource> downloadFile(@PathVariable String fileName, HttpServletRequest request) {
        LOGGER.info(REQUESTER_CALLED + DOWNLOAD_FILE_FILE_NAME_ENDPOINT);

        // Load file as Resource
        Resource resource = fileStorageService.loadFileAsResource(fileName, uploadDir);

        // Try to determine file's content type
        String contentType = null;
        try {
            contentType = request.getServletContext().getMimeType(resource.getFile().getAbsolutePath());
        } catch (IOException ex) {
            LOGGER.info("Could not determine file type.");
        }

        // Fallback to the default content type if type could not be determined
        if (contentType == null) {
            contentType = "application/octet-stream";
        }

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(contentType))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + resource.getFilename() + "\"")
                .body(resource);
    }


    @GetMapping(path = GET_ORDERS_ENDPOINT)
    public ResponseEntity<List<OrdersModel>> getOrders() {
        LOGGER.info(REQUESTER_CALLED + GET_ORDERS_ENDPOINT);
        List<OrdersModel> getOrderDetails = paymentService.getOrderDetails();
        return new ResponseEntity<>(getOrderDetails, HttpStatus.OK);
    }


    @GetMapping(path = GET_ORDERS_BY_ORDERID_ORDERID_ENDPOINT)
    public ResponseEntity<List<OrdersModel>> getOrderByOrderid(@PathVariable("orderid") String orderid) {
        LOGGER.info(REQUESTER_CALLED + GET_ORDERS_BY_ORDERID_ORDERID_ENDPOINT);
        List<OrdersModel> getOrderDetails = paymentService.getOrderDetailsByOrderId(orderid);
        return new ResponseEntity<>(getOrderDetails, HttpStatus.OK);
    }


    @GetMapping(path = GET_ORDERS_BY_ABHA_ID_ABHAID_ENDPOINT)
    public ResponseEntity<List<OrdersModel>> getOrderByAbhaid(@PathVariable("abhaid") String abhaid) {
        LOGGER.info(REQUESTER_CALLED + GET_ORDERS_BY_ABHA_ID_ABHAID_ENDPOINT);
        List<OrdersModel> getOrderDetails = paymentService.getOrderDetailsByAbhaId(abhaid);
        return new ResponseEntity<>(getOrderDetails, HttpStatus.OK);
    }

    @GetMapping(path = GET_ORDERS_BY_HPR_ID_HPRID_ENDPOINT)
    public ResponseEntity<List<OrdersModel>> getOrderByHprid(@PathVariable("hprid") String hprid) {
        LOGGER.info(REQUESTER_CALLED + GET_ORDERS_BY_HPR_ID_HPRID_ENDPOINT);

        List<OrdersModel> getOrderDetails = paymentService.getOrderDetailsByHprId(hprid);
        return new ResponseEntity<>(getOrderDetails, HttpStatus.OK);
    }

    @GetMapping(path = GET_ORDERS_BY_HPR_ID_AND_TYPE_HPRID_ENDPOINT)
    public ResponseEntity<List<OrdersModel>> getOrderByHpridAndType(@PathVariable("hprid") String hprid,
                                                                    @RequestParam(value = "limit", defaultValue = "100", required = false) Integer limit,
                                                                    @RequestParam(value = "aType", required = false) String aType,
                                                                    @RequestParam(value = "startDate", required = false) String startDate,
                                                                    @RequestParam(value = "endDate", required = false) String endDate,
                                                                    @RequestParam(value = "sort", required = false) String sort,
                                                                    @RequestParam(value = "state", required = false) String state) {
        LOGGER.info(REQUESTER_CALLED + GET_ORDERS_BY_HPR_ID_AND_TYPE_HPRID_ENDPOINT);


        List<OrdersModel> getOrderDetails = null;
        OrdersModel res;
        try {
            getOrderDetails = paymentService.getOrderDetailsByFilterParams(hprid, aType, limit, startDate, endDate, sort, state);
        } catch (Exception e) {
            LOGGER.error("HSPAController :: /getOrdersByHprIdAndType/{hprid}:: error {}", e.getMessage());
            res = new OrdersModel();
            res.setResponse(getErrorMessage(e.getMessage()));
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Collections.singletonList(res));
        }
        return new ResponseEntity<>(getOrderDetails, HttpStatus.OK);
    }

    @GetMapping(path = GET_ORDERS_BY_HPR_ID_AND_TYPE_HPRID_A_TYPE_ENDPOINT)
    public ResponseEntity<List<OrdersModel>> getOrderByHpridAndType(@PathVariable("hprid") String hprid, @PathVariable("aType") String aType) {
        LOGGER.info(REQUESTER_CALLED + GET_ORDERS_BY_HPR_ID_AND_TYPE_HPRID_A_TYPE_ENDPOINT);

        List<OrdersModel> getOrderDetails = paymentService.getOrderDetailsByHprIdAndType(hprid, aType);
        return new ResponseEntity<>(getOrderDetails, HttpStatus.OK);
    }

    private List<MessagesDTO> convertToMessageDto(List<MessagesModel> getMessageDetails) {
        return modelMapper.map(getMessageDetails, new TypeToken<List<MessagesDTO>>() {
        }.getType());
    }

    @PutMapping(path = UPDATE_ORDER_ID_ENDPOINT)
    public ResponseEntity<UpdateOrderDTO> updateOrder(@RequestBody String status, @PathVariable(name = "orderId") String orderId) throws NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException {
        UpdateOrderDTO statusUpdate = null;
        try {
          if(statusService.updateOrderStatus(status,orderId)){
              statusUpdate = new UpdateOrderDTO();
              statusUpdate.setResponse(generateAck());
              return new ResponseEntity<>(statusUpdate, HttpStatus.OK);
          }
        } catch (UserException | JsonProcessingException e) {
            statusUpdate = new UpdateOrderDTO();
            statusUpdate.setResponse(getErrorMessage(e.getLocalizedMessage()));
            return new ResponseEntity<>(statusUpdate, HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return null;
    }
}
