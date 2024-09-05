package in.abdm.gov.openMrsWrapper.service;

import org.springframework.http.ResponseEntity;
import org.springframework.util.MultiValueMap;
import reactor.core.publisher.Mono;

public interface MrsWrapperService {
    Mono<ResponseEntity<String>> callMrsPost(String request, String url, MultiValueMap<String, String> params);

    Mono<ResponseEntity<String>> callMrsDelete(String request, String url, MultiValueMap<String, String> params);

    Mono<ResponseEntity<String>> callMrsGet(String url, MultiValueMap<String, String> params);
}
