package in.gov.abdm.uhi.hspa.service.ServiceInterface;

import com.fasterxml.jackson.core.JsonProcessingException;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Response;
import org.springframework.web.bind.annotation.RequestBody;
import reactor.core.publisher.Mono;

public interface IService {
    Mono<Response> processor(@RequestBody String json) throws Exception;
    Mono<String> run(Request request, String s) throws Exception;

    Mono<String> logResponse(String result);
}
