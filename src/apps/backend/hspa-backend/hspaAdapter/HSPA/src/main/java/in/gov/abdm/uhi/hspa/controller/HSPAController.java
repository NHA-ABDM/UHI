
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
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import reactor.core.publisher.Mono;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import javax.validation.constraints.NotEmpty;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Validated
@RestController
@RequestMapping("/api/v1")
public class HSPAController {

    private static final Logger LOGGER = LogManager.getLogger(HSPAController.class);

    @Value("${spring.file.upload-dir}")
    private String uploadDir;

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
    
    final
    PaymentService paymentService;

    final
    PushNotificationService pushNotificationService;
    public HSPAController(SearchService searchService, SelectService selectService, InitService initService, ConfirmService confirmService, StatusService statusService, SaveChatService chatIndb, ModelMapper modelMapper, MessageService messageService, FileStorageService fileStorageService, PushNotificationService pushNotificationService, CancelService cancelService, PaymentService paymentService) {
        this.searchService = searchService;
        this.selectService = selectService;
        this.initService = initService;
        this.confirmService = confirmService;
		this.cancelService = cancelService;
        this.statusService = statusService;
        this.chatIndb = chatIndb;
        this.modelMapper = modelMapper;
        this.messageService = messageService;
        this.fileStorageService = fileStorageService;
        this.pushNotificationService = pushNotificationService;
        this.paymentService = paymentService;
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
                LOGGER.info("Gateway Headers {}", gatewayHeader);

                res = searchService.processor(request);
            }
        } catch (Exception ex) {
            LOGGER.info("Search::error:: {}", request);
            LOGGER.error("Search::error:: {}" , ex, ex);
        }

        return res;
    }

    @PostMapping(value = "/select", consumes = "application/json", produces = "application/json")
    public Mono<Response> select(@Valid @RequestBody String request) {
        LOGGER.info(ConstantsUtils.REQUESTER_CALLED+" select");
        Mono<Response> res = Mono.just(new Response());
        try {
            res = selectService.processor(request);

        } catch (Exception ex) {
            LOGGER.info(ConstantsUtils.REQUESTER_ERROR, request);
            LOGGER.error(ConstantsUtils.REQUESTER_ERROR, ex, ex);
        }
        return res;
    }

    @PostMapping(value = "/init", consumes = "application/json", produces = "application/json")
    public Mono<Response> init(@Valid @RequestBody String request)  {
        LOGGER.info(ConstantsUtils.REQUESTER_CALLED);
        Mono<Response> res = Mono.just(new Response());
        try
        {
            res =  initService.processor(request);

        } catch (Exception ex) {
            LOGGER.info(ConstantsUtils.REQUESTER_ERROR, request);
            LOGGER.error(ConstantsUtils.REQUESTER_ERROR, ex, ex);
        }
        return res;
    }

    @PostMapping(value = "/confirm", consumes = "application/json", produces = "application/json")
    public Mono<Response> confirm(@Valid @RequestBody String request)  {
        LOGGER.info(ConstantsUtils.REQUESTER_CALLED);

        Mono<Response> res = Mono.just(new Response());
        try
        {
           res =  confirmService.processor(request);
        } catch (Exception ex) {
            LOGGER.info(ConstantsUtils.REQUESTER_ERROR, request);
            LOGGER.error(ConstantsUtils.REQUESTER_ERROR, ex, ex);
        }
        return res;
    }

    @PostMapping(value = "/cancel", consumes = "application/json", produces = "application/json")
    public Mono<Response> cancel(@Valid @RequestBody String request)  {
        LOGGER.info(ConstantsUtils.REQUESTER_CALLED);

        Mono<Response> res = Mono.just(new Response());
        try
        {
           res =  cancelService.processor(request);
        } catch (Exception ex) {
            LOGGER.info(ConstantsUtils.REQUESTER_ERROR, request);
            LOGGER.error(ConstantsUtils.REQUESTER_ERROR, ex, ex);
        }
        return res;
    }
    @PostMapping(value = "/status", consumes = "application/json", produces = "application/json")
    public Mono<Response> status(@Valid @RequestBody String request) {
        LOGGER.info(ConstantsUtils.REQUESTER_CALLED);

        Mono<Response> res = Mono.just(new Response());
        try
        {
            res = statusService.processor(request);

        } catch (Exception ex) {
            LOGGER.info(ConstantsUtils.REQUESTER_ERROR, request);
            LOGGER.error("Requester::error::{}", ex, ex);
        }

        return res;
    }

    @PostMapping(value = "/on_message", consumes = "application/json", produces = "application/json")
    public Mono<Response> onMessage(@Valid @RequestBody String request) {
        LOGGER.info("Requester::called on_message");
        Mono<Response> res;
        try
        {
            res =  messageService.processor(request);

        } catch (Exception ex) {
            LOGGER.info(ConstantsUtils.REQUESTER_ERROR, request);
            LOGGER.error(ConstantsUtils.REQUESTER_ERROR, ex, ex);
            res = MessageService.generateNack(ex);
        }

        return res;
    }

    @PostMapping(value = "/message", produces = "application/json")
    public Mono<Response> message(@RequestBody String req) {
        LOGGER.info("Requester::called message");

        Mono<Response> res;
        try
        {
            res =  messageService.processor(req);
        } catch (Exception ex) {
            LOGGER.info(ConstantsUtils.REQUESTER_ERROR, req);
            LOGGER.error("Requester::error::{}", ex, ex);
            res = MessageService.generateNack(ex);

        }

        return res;
    }

    @GetMapping(path = "/getMessages/{sender}/{receiver}")
    public ResponseEntity<List<? extends ServiceResponseDTO>> getMessagesBetweenTwo(@PathVariable("sender") String sender, @PathVariable("receiver") String receiver,
                                                                                    @RequestParam(value ="pageNumber",defaultValue="0",required=false)Integer pageNumber,
                                                                                    @RequestParam(value ="pageSize",defaultValue="200",required=false)Integer pageSize) {
        LOGGER.info("inside getMessagesBetweenTwo");

        LOGGER.info("Requester::sender ::{}", sender);
        LOGGER.info("Requester::receiver :: {}" , receiver);
        LOGGER.info("Requester::pageNumber :: {}" , pageNumber);
        LOGGER.info("Requester::pageSize :: {}" , pageSize);

        try {
            List<MessagesModel> getMessageDetails = chatIndb.getMessagesBetweenTwo(sender, receiver, pageNumber, pageSize);
            List<MessagesDTO> messagesDto = convertToMessageDto(getMessageDetails);
            return new ResponseEntity<>(messagesDto, HttpStatus.OK);
        } catch (Exception e) {
            LOGGER.info("Requester::error::sender :: {}" , sender);
            LOGGER.info("Requester::error::receiver :: {}" , receiver);

            LOGGER.error(e.getMessage());
            List<? extends ServiceResponseDTO> messagesDTOS = getErrorMessage(e.getMessage());

            return new ResponseEntity<>(messagesDTOS, HttpStatus.INTERNAL_SERVER_ERROR);

        }

    }

    @GetMapping(path = "/getUser/{userid}")
    public ResponseEntity<List<? extends ServiceResponseDTO>> getUserById(@Valid @NotEmpty(message = "user id is required") @PathVariable("userid") String userId) {
        LOGGER.info("inside Get user by id");
        try {
            LOGGER.info("user id given is -: ->>>>>> {}", userId);
            List<ChatUserModel> getUserDetails = chatIndb.getUserDetails(userId);
            return new ResponseEntity<>(getUserDetails, HttpStatus.OK);
        }catch (Exception e) {
            LOGGER.info("Requester::error :: {}", e.getMessage());
            List<? extends ServiceResponseDTO> messagesDTOS = getErrorMessage(e.getMessage());

            return new ResponseEntity<>(messagesDTOS, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }



//    @ApiOperation(value = "Send notification to HSPA ", notes="this endpoint will send notification to HSPA based on given token ")
    @PostMapping("/notification/token")
    public ResponseEntity<PushNotificationResponseDTO> sendTokenNotification(@RequestBody PushNotificationRequestDTO request) {
        try {
            pushNotificationService.sendPushNotificationToToken(request);
        } catch (Exception e) {
            LOGGER.error("HSPA Controller :: POST:notification/token error {}", e.getMessage());
        }
        LOGGER.info("send notification");
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
            return new ResponseEntity<>(new PushNotificationResponseDTO(HttpStatus.BAD_REQUEST.value(), "token not saved"), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/logout")
    public ResponseEntity<PushNotificationResponseDTO> logout(@RequestBody RequestTokenDTO request) {
        try {
            chatIndb.deleteToken(request);
            return new ResponseEntity<>(new PushNotificationResponseDTO(HttpStatus.OK.value(), "token deleted"), HttpStatus.OK);
        }
        catch(Exception re) {
            return new ResponseEntity<>(new PushNotificationResponseDTO(HttpStatus.INTERNAL_SERVER_ERROR.value(), "Error deleting token"), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }


    private List<MessagesDTO> convertToMessageDto(List<MessagesModel> getMessageDetails) {
        return modelMapper.map(getMessageDetails, new TypeToken<List<MessagesDTO>>() {}.getType());
    }

    private List<ServiceResponseDTO> getErrorMessage(String message) {
        ServiceResponseDTO messagesDTO = new ServiceResponseDTO();
        ErrorResponseDTO errorResponseDTO =  new ErrorResponseDTO();
        errorResponseDTO.setErrorString(message);
        errorResponseDTO.setCode("500");
        errorResponseDTO.setPath("HSPAController");
        messagesDTO.setError(errorResponseDTO);

        List<ServiceResponseDTO> messagesDTOS = new ArrayList<>();
        messagesDTOS.add(messagesDTO);
        return messagesDTOS;
    }
    
    
    @PostMapping("/savePublicKey")
    public ResponseEntity<PushNotificationResponseDTO> savePublicKey(@RequestBody RequestPublicKeyDTO request) {
    	PublicKeyModel savePublicKeyModel = chatIndb.savePublicKey(request);
        if(null!= savePublicKeyModel)
        {
            return new ResponseEntity<>(new PushNotificationResponseDTO(HttpStatus.OK.value(), "Key saved"), HttpStatus.OK);
        }
        else
        {
            return new ResponseEntity<>(new PushNotificationResponseDTO(HttpStatus.BAD_REQUEST.value(), "Key not saved"), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping(path = "/getPublicKey/{username}")
	public ResponseEntity<List<PublicKeyModel>> getKeyByUsername(@PathVariable("username") String userName){
		LOGGER.info("Get Key  by hpr address");
		List<PublicKeyModel> getKeyDetails = chatIndb.getKeyDetails(userName);		
		return new ResponseEntity<>(getKeyDetails,HttpStatus.OK);		
	}
    
    
    @PostMapping("/saveKey")
    public ResponseEntity<SharedKeyModel> saveSharedKey(@RequestBody RequestSharedKeyDTO request) {
    	SharedKeyModel saveSharedKey = chatIndb.saveSharedKey(request);
        if(null!= saveSharedKey)
        {
            return new ResponseEntity<>(saveSharedKey, HttpStatus.OK);
        }
        else
        {
            return new ResponseEntity<>(new SharedKeyModel(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    @GetMapping(path = "/getKey/{userName}")
	public ResponseEntity<List<SharedKeyModel>> getSharedKeyByUsername(@PathVariable("userName") String userName){
		LOGGER.info("Get Key  by consumer provider");
		List<SharedKeyModel> getKeyDetails = chatIndb.getSharedKeyDetails(userName);		
		return new ResponseEntity<>(getKeyDetails,HttpStatus.OK);		
	}


    @PostMapping("/uploadFile")
    public UploadFileResponse uploadFile(@RequestParam("file") MultipartFile file) {
        String fileName = fileStorageService.storeFile(file,uploadDir);

        String fileDownloadUri = ServletUriComponentsBuilder.fromCurrentContextPath()
                .path("/downloadFile/")
                .path(fileName)
                .toUriString();

        return new UploadFileResponse(fileName, fileDownloadUri,
                file.getContentType(), file.getSize());
    }

    @PostMapping("/uploadMultipleFiles")
    public List<UploadFileResponse> uploadMultipleFiles(@RequestParam("files") MultipartFile[] files) {
        return Arrays.stream(files)
                .map(this::uploadFile)
                .toList();
    }

    @GetMapping("/downloadFile/{fileName}")
    public ResponseEntity<Resource> downloadFile(@PathVariable String fileName, HttpServletRequest request) {
        // Load file as Resource
        Resource resource = fileStorageService.loadFileAsResource(fileName,uploadDir);

        // Try to determine file's content type
        String contentType = null;
        try {
            contentType = request.getServletContext().getMimeType(resource.getFile().getAbsolutePath());
        } catch (IOException ex) {
            LOGGER.info("Could not determine file type.");
        }

        // Fallback to the default content type if type could not be determined
        if(contentType == null) {
            contentType = "application/octet-stream";
        }

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(contentType))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + resource.getFilename() + "\"")
                .body(resource);
    }
    

	@GetMapping(path = "/getOrders")
	public ResponseEntity<List<OrdersModel>> getOrders(){		
		LOGGER.info("inside Get Orders");		
		List<OrdersModel> getOrderDetails = paymentService.getOrderDetails();		 
		return new ResponseEntity<>(getOrderDetails,HttpStatus.OK);		
	}
	

	@GetMapping(path = "/getOrdersByOrderid/{orderid}")
	public ResponseEntity<List<OrdersModel>> getOrderByOrderid(@PathVariable("orderid") String orderid){	
		LOGGER.info("inside Get order by orderid");
		List<OrdersModel> getOrderDetails = paymentService.getOrderDetailsByOrderId(orderid);		
		return new ResponseEntity<>(getOrderDetails,HttpStatus.OK);		
	}
	

	@GetMapping(path = "/getOrdersByAbhaId/{abhaid}")
	public ResponseEntity<List<OrdersModel>> getOrderByAbhaid(@PathVariable("abhaid") String abhaid){	
		LOGGER.info("inside Get order by abhaid");
		List<OrdersModel> getOrderDetails = paymentService.getOrderDetailsByAbhaId(abhaid);		
		return new ResponseEntity<>(getOrderDetails,HttpStatus.OK);		
	}
	
	@GetMapping(path = "/getOrdersByHprId/{hprid}")
	public ResponseEntity<List<OrdersModel>> getOrderByHprid(@PathVariable("hprid") String hprid){	
		LOGGER.info("inside Get order by hprid");
		List<OrdersModel> getOrderDetails = paymentService.getOrderDetailsByHprId(hprid);		
		return new ResponseEntity<>(getOrderDetails,HttpStatus.OK);		
	}
	
	@GetMapping(path = "/getOrdersByHprIdAndType/{hprid}")
	public ResponseEntity<List<OrdersModel>> getOrderByHpridAndType(@PathVariable("hprid") String hprid,
                                                                    @RequestParam(value ="limit",defaultValue="100",required=false)Integer limit,
                                                                    @RequestParam(value ="aType", required = false)String aType,
                                                                    @RequestParam(value ="startDate", required = false) String startDate,
                                                                    @RequestParam(value ="endDate", required = false) String endDate,
                                                                    @RequestParam(value ="sort", required = false) String sort,
                                                                    @RequestParam(value ="state", required = false) String state) {
        LOGGER.info("inside Get order by hprid and type");

        List<OrdersModel> getOrderDetails = null;
        try {
            getOrderDetails = paymentService.getOrderDetailsByFilterParams(hprid, aType, limit, startDate, endDate, sort, state);
        } catch (Exception e) {
            LOGGER.error("HSPAController :: /getOrdersByHprIdAndType/{hprid}:: error {}", e.getMessage());
            OrdersModel error = new OrdersModel();
            ServiceResponseDTO messagesDTO = new ServiceResponseDTO();
            ErrorResponseDTO errorResponseDTO =  new ErrorResponseDTO();
            errorResponseDTO.setErrorString(e.getMessage());
            errorResponseDTO.setCode("500");
            errorResponseDTO.setPath("HSPAController");
            messagesDTO.setError(errorResponseDTO);
            error.setError(errorResponseDTO);
            List<OrdersModel> errorDto = new ArrayList<>();
            errorDto.add(error);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorDto);
        }
        return new ResponseEntity<>(getOrderDetails, HttpStatus.OK);
    }

    @GetMapping(path = "/getOrdersByHprIdAndType/{hprid}/{aType}")
    public ResponseEntity<List<OrdersModel>> getOrderByHpridAndType(@PathVariable("hprid") String hprid,@PathVariable("aType") String aType){
        LOGGER.info("inside Get order by hprid and type");
        List<OrdersModel> getOrderDetails = paymentService.getOrderDetailsByHprIdAndType(hprid,aType);
        return new ResponseEntity<>(getOrderDetails,HttpStatus.OK);
    }
}
