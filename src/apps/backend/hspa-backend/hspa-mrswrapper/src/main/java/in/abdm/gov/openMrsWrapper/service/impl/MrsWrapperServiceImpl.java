package in.abdm.gov.openMrsWrapper.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.abdm.gov.openMrsWrapper.dtos.ErrorDTO;
import in.abdm.gov.openMrsWrapper.dtos.ResponseDTO;
import in.abdm.gov.openMrsWrapper.service.MrsWrapperService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
public class MrsWrapperServiceImpl implements MrsWrapperService {

    private static final Logger LOGGER = LoggerFactory.getLogger(MrsWrapperServiceImpl.class);
    final ObjectMapper objectMapper;
    final WebClient webClient;
    @Value("${spring.openmrs_baselink}")
    String OPENMRS_BASE_LINK;
    @Value("${spring.openmrs_api}")
    String OPENMRS_API;
    @Value("${spring.hspa.base_url}")
    String HSPA_ADAPTER_BASE_LINK;
    @Value("${spring.hspa.base_version}")
    String HSPA_ADAPTER_BASE_VERSION;

    public MrsWrapperServiceImpl(ObjectMapper objectMapper, WebClient webClient) {
        this.objectMapper = objectMapper;
        this.webClient = webClient;
    }

    @Override
    public Mono<ResponseEntity<String>> callMrsPost(String request, String url, MultiValueMap<String, String> params) {

        String uri = OPENMRS_API + url;


        return this.webClient.post().uri(uriBuilder -> uriBuilder.path(uri).queryParams(params).build())
                .contentType(MediaType.APPLICATION_JSON)
                .body(BodyInserters.fromValue(request))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).map(Exception::new))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).map(Exception::new))
                .toEntity(String.class)
                .onErrorResume(throwable -> {
                    ResponseDTO responseDTO = getErrorSchema(throwable);
                    try {
                        return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(objectMapper.writeValueAsString(responseDTO)));
                    } catch (JsonProcessingException e) {
                        LOGGER.error("MrsWrapperService::Error converting into string in onErrorResume. Error occurred ->>>" + throwable.getMessage());
                    }
                    return null;
                });
    }


    public Mono<ResponseEntity<String>> callHspaPost(String request, String url, MultiValueMap<String, String> params) {
        String uri = HSPA_ADAPTER_BASE_LINK + HSPA_ADAPTER_BASE_VERSION + url;



        return webClient.post().uri(uri)
                .contentType(MediaType.APPLICATION_JSON)
                .body(BodyInserters.fromValue(request))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).map(Exception::new))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).map(Exception::new))
                .toEntity(String.class)
                .onErrorResume(throwable -> {
                    ResponseDTO responseDTO = getErrorSchema(throwable);
                    try {
                        return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(objectMapper.writeValueAsString(responseDTO)));
                    } catch (JsonProcessingException e) {
                        LOGGER.error("MrsWrapperService::Error converting into string in onErrorResume. Error occurred ->>>" + throwable.getMessage());
                    }
                    return null;
                });
    }

    @Override
    public Mono<ResponseEntity<String>> callMrsDelete(String request, String url, MultiValueMap<String, String> params) {
        String uri = OPENMRS_API + url;


        return this.webClient.method(HttpMethod.DELETE).uri(uriBuilder -> uriBuilder.path(uri).queryParams(params).build())
                .contentType(MediaType.APPLICATION_JSON)
                .body(BodyInserters.fromValue(request))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new Exception(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new Exception(error))))
                .toEntity(String.class)
                .onErrorResume(throwable -> {
                    ResponseDTO responseDTO = getErrorSchema(throwable);
                    try {
                        return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(objectMapper.writeValueAsString(responseDTO)));
                    } catch (JsonProcessingException e) {
                        LOGGER.error("MrsWrapperService::Error converting into string in onErrorResume. Error occurred ->>>" + throwable.getMessage());
                    }
                    return null;
                });

    }

    @Override
    public Mono<ResponseEntity<String>> callMrsGet(String url, MultiValueMap<String, String> params) {
        String uri = OPENMRS_API + url;


        return this.webClient.get().uri(uriBuilder -> uriBuilder.path(uri).queryParams(params).build())
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new Exception(error))))
                .onStatus(HttpStatus::is5xxServerError,
                        response -> response.bodyToMono(String.class).flatMap(error -> Mono.error(new Exception(error))))
                .toEntity(String.class)
                .onErrorResume(throwable -> {
                    ResponseDTO responseDTO = getErrorSchema(throwable);
                    try {
                        return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(objectMapper.writeValueAsString(responseDTO)));
                    } catch (JsonProcessingException e) {
                        LOGGER.error("MrsWrapperService::Error converting into string in onErrorResume. Error occurred ->>>" + throwable.getMessage());
                    }
                    return null;
                });
    }



    private ResponseDTO getErrorSchema(Throwable throwable) {
        ResponseDTO responseDTO = new ResponseDTO();
        ErrorDTO errorDTO = new ErrorDTO();
        errorDTO.setType("Internal Server Error");
        errorDTO.setCode(HttpStatus.INTERNAL_SERVER_ERROR);
        errorDTO.setPath("MrsWrapperservice");
        responseDTO.setError(errorDTO);
        responseDTO.setResponse(throwable.getMessage());
        return responseDTO;
    }
}
