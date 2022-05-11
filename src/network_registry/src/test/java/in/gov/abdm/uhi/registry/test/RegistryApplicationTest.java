/*
 * package in.gov.abdm.uhi.registry.test;
 * 
 * import java.io.IOException; import java.util.Date;
 * 
 * import org.junit.jupiter.api.BeforeEach; import org.junit.jupiter.api.Test;
 * import org.springframework.beans.factory.annotation.Autowired; import
 * org.springframework.boot.test.context.SpringBootTest; import
 * org.springframework.boot.test.mock.mockito.MockBean; import
 * org.springframework.http.MediaType; import
 * org.springframework.test.context.web.WebAppConfiguration; import
 * org.springframework.test.web.servlet.MockMvc; import
 * org.springframework.test.web.servlet.MvcResult; import
 * org.springframework.test.web.servlet.request.MockMvcRequestBuilders; import
 * org.springframework.test.web.servlet.setup.MockMvcBuilders; import
 * org.springframework.web.context.WebApplicationContext;
 * 
 * import com.fasterxml.jackson.core.JsonParseException; import
 * com.fasterxml.jackson.core.JsonProcessingException; import
 * com.fasterxml.jackson.databind.JsonMappingException; import
 * com.fasterxml.jackson.databind.ObjectMapper;
 * 
 * import static org.junit.jupiter.api.Assertions.assertEquals; import static
 * org.mockito.Mockito.when;
 * 
 * import in.gov.abdm.uhi.registry.dto.LookupDto; import
 * in.gov.abdm.uhi.registry.entity.Subscriber; import
 * in.gov.abdm.uhi.registry.repository.SubscriberRepository; import
 * in.gov.abdm.uhi.registry.serviceImpl.SubscriberServiceImpl;
 * 
 * @SpringBootTest
 * 
 * @WebAppConfiguration public class RegistryApplicationTest {
 * 
 * @Autowired SubscriberServiceImpl subscriberServiceImpl;
 * 
 * @MockBean SubscriberRepository subscriberRepository; Subscriber RECORD_1 =
 * new Subscriber(1, 10, "123453", "India", "SLN", "testDomain", "unique1",
 * "pub1", "fnkfsnfsmlsfmlmlsafm", "msdnksdnksdnmlsdmlsdml", "SUBSCRIBED", null,
 * null, new Date().toString(), null, "5", "BPP", "https://xyz.com", null,
 * null);
 * 
 * // Testing new Subscriber
 * 
 * @Test public void addSubscriberTest() throws Exception {
 * when(subscriberRepository.save(RECORD_1)).thenReturn(RECORD_1);
 * assertEquals(RECORD_1, subscriberServiceImpl.addSubscriber(RECORD_1)); }
 * 
 * // Testing lookup subscriber
 * 
 * @Test public void lookupTest() {
 * when(subscriberRepository.findByStatusAndSubTypeAndDomainAndCountryAndCity(
 * "SUBSCRIBED", "BPP", "testDomain", "India", "SLN")).thenReturn(RECORD_1);
 * LookupDto dto = new LookupDto("123453", "BPP", "testDomain", "India", "SLN");
 * assertEquals(RECORD_1, subscriberServiceImpl.lookup(dto)); }
 * 
 * // Testing update Subscriber
 * 
 * @Test public void updateSubscriberTest() { Subscriber updatedData = new
 * Subscriber(1, 10, "123451", "India", "Mumbai", "Domain", "unique1234",
 * "pub124", "fnkfsnfsmlsfmlmlsafm", "msdnksdnksdnmlsdmlsdml", "SUBSCRIBED",
 * null, null, new Date().toString(), null, "5", "BPP", "https://xyz.com", null,
 * null); when(subscriberRepository.save(RECORD_1)).thenReturn(RECORD_1);
 * when(subscriberRepository.findBySubscriberId("123451")).thenReturn(RECORD_1);
 * when(subscriberServiceImpl.updateSubscriber(updatedData)).thenReturn(
 * updatedData); assertEquals("Mumbai", updatedData.getCity());
 * 
 * }
 * 
 * // controller testing
 * 
 * protected MockMvc mvc;
 * 
 * @Autowired WebApplicationContext webApplicationContext;
 * 
 * @BeforeEach protected void setUp() { this.mvc =
 * MockMvcBuilders.webAppContextSetup(webApplicationContext).build(); }
 * 
 * protected String mapToJson(Object obj) throws JsonProcessingException {
 * ObjectMapper objectMapper = new ObjectMapper(); return
 * objectMapper.writeValueAsString(obj); }
 * 
 * protected <T> T mapFromJson(String json, Class<T> clazz) throws
 * JsonParseException, JsonMappingException, IOException { ObjectMapper
 * objectMapper = new ObjectMapper(); return objectMapper.readValue(json,
 * clazz); }
 * 
 * @Test public void createSubscriberTest() throws Exception { String uri =
 * "/api/subscribe"; Subscriber data = new Subscriber(1, 10, "1234517", "India",
 * "Mumbai", "Domain", "unique1234", "pub124", "fnkfsnfsmlsfmlmlsafm",
 * "msdnksdnksdnmlsdmlsdml", "SUBSCRIBED", null, null, new Date().toString(),
 * null, "5", "BPP", "https://xyz.com", null, null); String inputJson =
 * this.mapToJson(data); MvcResult mvcResult = mvc.perform(
 * MockMvcRequestBuilders.post(uri).contentType(MediaType.APPLICATION_JSON_VALUE
 * ).content(inputJson)) .andReturn(); int status =
 * mvcResult.getResponse().getStatus(); assertEquals(200, status); String
 * content = mvcResult.getResponse().getContentAsString();
 * System.out.println(content); }
 * 
 * 
 * 
 * }
 */