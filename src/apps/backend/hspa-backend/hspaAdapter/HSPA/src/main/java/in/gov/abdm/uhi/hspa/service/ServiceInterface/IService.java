package in.gov.abdm.uhi.hspa.service.ServiceInterface;

import com.fasterxml.jackson.core.JsonProcessingException;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Response;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import org.springframework.web.bind.annotation.RequestBody;
import reactor.core.publisher.Mono;

import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.spec.InvalidKeySpecException;
import java.util.Map;
import java.util.Objects;

public interface IService {
    Mono<Response> processor(@RequestBody String json, Map<String, String> headers) throws Exception;

    Mono<String> run(Request request, String s) throws Exception;

    Mono<Map<String, Object>> runBloodBank(Request request, String s) throws Exception;

    Mono<String> logResponse(String result, Request request);

    boolean updateOrderStatus(String status, String orderId) throws UserException, JsonProcessingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchProviderException;
}
