package in.gov.abdm.uhi.EUABookingService;

import static org.hamcrest.CoreMatchers.is;
import static org.junit.Assert.assertEquals;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.web.reactive.function.client.WebClient;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.EUABookingService.entity.ChatUser;
import in.gov.abdm.uhi.EUABookingService.entity.Orders;
import in.gov.abdm.uhi.EUABookingService.repository.OrderRepository;
import in.gov.abdm.uhi.EUABookingService.service.SaveDataDbService;
import in.gov.abdm.uhi.EUABookingService.serviceImpl.SaveInDbServiceImpl;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Response;

@ExtendWith(MockitoExtension.class)
class EuaBookingServiceApplicationTests {
	
	@Mock
	OrderRepository orderRepo;
	
	@InjectMocks	
	SaveInDbServiceImpl saveInDbService;
	
	@Autowired
    private ObjectMapper objectMapper;
	
	
	@Mock
	Orders orders;
	
	@Mock
	List<Orders> ordersList;

	@Autowired
	WebTestClient webTestClient;

	Orders order;
	Response MessageAck;
	
	ChatUser chatUser;
	
	
	@BeforeEach
	public void setUp() throws JsonProcessingException {
		objectMapper = new ObjectMapper();
		MockitoAnnotations.openMocks(this);
		String ack = "{\r\n" + "    \"message\": {\r\n" + "        \"ack\": {\r\n"
				+ "            \"status\": \"ACK\"\r\n" + "        }\r\n" + "    }\r\n" + "}";
		MessageAck = objectMapper.readValue(ack, Response.class);	
		
		orders = objectMapper.readValue("{\"error\":null,\"orderId\":\"578a0e40-02f2-11ed-b79c-471dcc9624f4\",\"categoryId\":\"1\",\"appointmentId\":null,\"orderDate\":null,\"healthcareServiceName\":\"Consultation\",\"healthcareServiceId\":\"1\",\"healthcareProviderName\":null,\"healthcareProviderId\":null,\"healthcareProviderUrl\":\"http://100.96.9.171:8084/api/v1\",\"healthcareServiceProviderEmail\":null,\"healthcareServiceProviderPhone\":null,\"healthcareProfessionalName\":\"deepak.kumar@hpr.abdm - Deepak Kumar\",\"healthcareProfessionalImage\":null,\"healthcareProfessionalEmail\":null,\"healthcareProfessionalPhone\":null,\"healthcareProfessionalId\":\"deepak.kumar@hpr.abdm\",\"healthcareProfessionalGender\":\"M\",\"serviceFulfillmentStartTime\":\"2022-07-14T16:00:00\",\"serviceFulfillmentEndTime\":\"2022-07-14T16:15:00\",\"serviceFulfillmentType\":\"Teleconsultation\",\"symptoms\":null,\"languagesSpokenByHealthcareProfessional\":null,\"healthcareProfessionalExperience\":null,\"isServiceFulfilled\":\"CONFIRMED\",\"healthcareProfessionalDepartment\":null,\"message\":\"{\\\"context\\\":{\\\"domain\\\":\\\"nic2004:85111\\\",\\\"country\\\":\\\"IND\\\",\\\"city\\\":\\\"std:080\\\",\\\"action\\\":\\\"on_confirm\\\",\\\"timestamp\\\":\\\"2022-07-17T21:25:48.376113Z\\\",\\\"core_version\\\":\\\"0.7.1\\\",\\\"consumer_id\\\":\\\"eua-nha\\\",\\\"consumer_uri\\\":\\\"http://100.96.9.173:8080/api/v1/euaService\\\",\\\"provider_uri\\\":\\\"http://100.96.9.171:8084/api/v1\\\",\\\"transaction_id\\\":\\\"5cb7bd40-02f2-11ed-b79c-471dcc9624f4\\\",\\\"message_id\\\":\\\"5cb7bd40-02f2-11ed-b79c-471dcc9624f4\\\"},\\\"message\\\":{\\\"order\\\":{\\\"id\\\":\\\"578a0e40-02f2-11ed-b79c-471dcc9624f4\\\",\\\"state\\\":\\\"CONFIRMED\\\",\\\"item\\\":{\\\"id\\\":\\\"1\\\",\\\"descriptor\\\":{\\\"name\\\":\\\"Consultation\\\"},\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"1000\\\"},\\\"fulfillment_id\\\":\\\"325683d4-ccf7-4fac-a042-21171c9f7821\\\"},\\\"fulfillment\\\":{\\\"id\\\":\\\"325683d4-ccf7-4fac-a042-21171c9f7821\\\",\\\"type\\\":\\\"Teleconsultation\\\",\\\"agent\\\":{\\\"id\\\":\\\"deepak.kumar@hpr.abdm\\\",\\\"name\\\":\\\"deepak.kumar@hpr.abdm - Deepak Kumar\\\",\\\"gender\\\":\\\"M\\\",\\\"tags\\\":{\\\"@abdm/gov/in/education\\\":\\\"MS\\\",\\\"@abdm/gov/in/experience\\\":\\\"7.0\\\",\\\"@abdm/gov/in/follow_up\\\":\\\"200.0\\\",\\\"@abdm/gov/in/first_consultation\\\":\\\"500.0\\\",\\\"@abdm/gov/in/speciality\\\":\\\"ENT\\\",\\\"@abdm/gov/in/languages\\\":\\\"Eng, Hin\\\",\\\"@abdm/gov/in/upi_id\\\":\\\"9896271877@okicici\\\",\\\"@abdm/gov/in/hpr_id\\\":\\\"10696314\\\"}},\\\"start\\\":{\\\"time\\\":{\\\"timestamp\\\":\\\"2022-07-14T16:00:00\\\"}},\\\"end\\\":{\\\"time\\\":{\\\"timestamp\\\":\\\"2022-07-14T16:15:00\\\"}},\\\"tags\\\":{\\\"@abdm/gov.in/slot_id\\\":\\\"325683d4-ccf7-4fac-a042-21171c9f7821\\\"}},\\\"billing\\\":{\\\"name\\\":\\\"Deepak Kumar\\\",\\\"address\\\":{\\\"door\\\":\\\"21A\\\",\\\"name\\\":\\\"ABC Apartments\\\",\\\"locality\\\":\\\"Dwarka\\\",\\\"city\\\":\\\"New Delhi\\\",\\\"state\\\":\\\"New Delhi\\\",\\\"country\\\":\\\"India\\\",\\\"area_code\\\":\\\"110011\\\"},\\\"email\\\":\\\"\\\",\\\"phone\\\":\\\"9896271877\\\"},\\\"quote\\\":{\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"1000\\\"},\\\"breakup\\\":[{\\\"title\\\":\\\"Consultation\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"1000\\\"}},{\\\"title\\\":\\\"CGST @ 5%\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"50\\\"}},{\\\"title\\\":\\\"SGST @ 5%\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"50\\\"}},{\\\"title\\\":\\\"Registration\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"400\\\"}}]},\\\"customer\\\":{\\\"id\\\":\\\"\\\",\\\"cred\\\":\\\"deepakkumar3004@sbx\\\"},\\\"payment\\\":{\\\"uri\\\":\\\"https://api.bpp.com/pay?amt=1500&txn_id=ksh87yriuro34iyr3p4&mode=upi&vpa=sana.bhatt@upi\\\",\\\"type\\\":\\\"ON-ORDER\\\",\\\"status\\\":\\\"PAID\\\",\\\"tl_method\\\":\\\"http/get\\\",\\\"params\\\":{\\\"transaction_id\\\":\\\"abc128-riocn83920\\\",\\\"amount\\\":\\\"1500\\\",\\\"mode\\\":\\\"UPI\\\",\\\"vpa\\\":\\\"sana.bhatt@upi\\\"}}}}}\",\"slotId\":\"325683d4-ccf7-4fac-a042-21171c9f7821\",\"patientGender\":null,\"patientName\":null,\"patientConsumerUrl\":null,\"transId\":null,\"primaryDoctorName\":null,\"primaryDoctorHprAddress\":null,\"secondaryDoctorName\":null,\"secondaryDoctorHprAddress\":null,\"teleconUrl\":null,\"groupConsultStatus\":null,\"abhaId\":\"deepakkumar3004@sbx\",\"createDate\":null,\"modifyDate\":null,\"user\":null,\"payment\":{\"transactionId\":\"abc128-riocn83920\",\"method\":\"https://api.bpp.com/pay?amt=1500&txn_id=ksh87yriuro34iyr3p4&mode=upi&vpa=sana.bhatt@upi\",\"currency\":\"INR\",\"transactionTimestamp\":null,\"consultationCharge\":\"1000\",\"phrHandlingFees\":\"400\",\"sgst\":\"50\",\"cgst\":\"50\",\"transactionState\":\"PAID\",\"user\":null,\"userAbhaId\":\"deepakkumar3004@sbx\"},\"primaryDoctorGender\":null,\"primaryDoctorProviderURI\":null,\"secondaryDoctorGender\":null,\"secondaryDoctorProviderURI\":null}", Orders.class);	
		
		ordersList=objectMapper.readValue("[{\"error\":null,\"orderId\":\"578a0e40-02f2-11ed-b79c-471dcc9624f4\",\"categoryId\":\"1\",\"appointmentId\":null,\"orderDate\":null,\"healthcareServiceName\":\"Consultation\",\"healthcareServiceId\":\"1\",\"healthcareProviderName\":null,\"healthcareProviderId\":null,\"healthcareProviderUrl\":\"http://100.96.9.171:8084/api/v1\",\"healthcareServiceProviderEmail\":null,\"healthcareServiceProviderPhone\":null,\"healthcareProfessionalName\":\"deepak.kumar@hpr.abdm - Deepak Kumar\",\"healthcareProfessionalImage\":null,\"healthcareProfessionalEmail\":null,\"healthcareProfessionalPhone\":null,\"healthcareProfessionalId\":\"deepak.kumar@hpr.abdm\",\"healthcareProfessionalGender\":\"M\",\"serviceFulfillmentStartTime\":\"2022-07-14T16:00:00\",\"serviceFulfillmentEndTime\":\"2022-07-14T16:15:00\",\"serviceFulfillmentType\":\"Teleconsultation\",\"symptoms\":null,\"languagesSpokenByHealthcareProfessional\":null,\"healthcareProfessionalExperience\":null,\"isServiceFulfilled\":\"CONFIRMED\",\"healthcareProfessionalDepartment\":null,\"message\":\"{\\\"context\\\":{\\\"domain\\\":\\\"nic2004:85111\\\",\\\"country\\\":\\\"IND\\\",\\\"city\\\":\\\"std:080\\\",\\\"action\\\":\\\"on_confirm\\\",\\\"timestamp\\\":\\\"2022-07-17T21:25:48.376113Z\\\",\\\"core_version\\\":\\\"0.7.1\\\",\\\"consumer_id\\\":\\\"eua-nha\\\",\\\"consumer_uri\\\":\\\"http://100.96.9.173:8080/api/v1/euaService\\\",\\\"provider_uri\\\":\\\"http://100.96.9.171:8084/api/v1\\\",\\\"transaction_id\\\":\\\"5cb7bd40-02f2-11ed-b79c-471dcc9624f4\\\",\\\"message_id\\\":\\\"5cb7bd40-02f2-11ed-b79c-471dcc9624f4\\\"},\\\"message\\\":{\\\"order\\\":{\\\"id\\\":\\\"578a0e40-02f2-11ed-b79c-471dcc9624f4\\\",\\\"state\\\":\\\"CONFIRMED\\\",\\\"item\\\":{\\\"id\\\":\\\"1\\\",\\\"descriptor\\\":{\\\"name\\\":\\\"Consultation\\\"},\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"1000\\\"},\\\"fulfillment_id\\\":\\\"325683d4-ccf7-4fac-a042-21171c9f7821\\\"},\\\"fulfillment\\\":{\\\"id\\\":\\\"325683d4-ccf7-4fac-a042-21171c9f7821\\\",\\\"type\\\":\\\"Teleconsultation\\\",\\\"agent\\\":{\\\"id\\\":\\\"deepak.kumar@hpr.abdm\\\",\\\"name\\\":\\\"deepak.kumar@hpr.abdm - Deepak Kumar\\\",\\\"gender\\\":\\\"M\\\",\\\"tags\\\":{\\\"@abdm/gov/in/education\\\":\\\"MS\\\",\\\"@abdm/gov/in/experience\\\":\\\"7.0\\\",\\\"@abdm/gov/in/follow_up\\\":\\\"200.0\\\",\\\"@abdm/gov/in/first_consultation\\\":\\\"500.0\\\",\\\"@abdm/gov/in/speciality\\\":\\\"ENT\\\",\\\"@abdm/gov/in/languages\\\":\\\"Eng, Hin\\\",\\\"@abdm/gov/in/upi_id\\\":\\\"9896271877@okicici\\\",\\\"@abdm/gov/in/hpr_id\\\":\\\"10696314\\\"}},\\\"start\\\":{\\\"time\\\":{\\\"timestamp\\\":\\\"2022-07-14T16:00:00\\\"}},\\\"end\\\":{\\\"time\\\":{\\\"timestamp\\\":\\\"2022-07-14T16:15:00\\\"}},\\\"tags\\\":{\\\"@abdm/gov.in/slot_id\\\":\\\"325683d4-ccf7-4fac-a042-21171c9f7821\\\"}},\\\"billing\\\":{\\\"name\\\":\\\"Deepak Kumar\\\",\\\"address\\\":{\\\"door\\\":\\\"21A\\\",\\\"name\\\":\\\"ABC Apartments\\\",\\\"locality\\\":\\\"Dwarka\\\",\\\"city\\\":\\\"New Delhi\\\",\\\"state\\\":\\\"New Delhi\\\",\\\"country\\\":\\\"India\\\",\\\"area_code\\\":\\\"110011\\\"},\\\"email\\\":\\\"\\\",\\\"phone\\\":\\\"9896271877\\\"},\\\"quote\\\":{\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"1000\\\"},\\\"breakup\\\":[{\\\"title\\\":\\\"Consultation\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"1000\\\"}},{\\\"title\\\":\\\"CGST @ 5%\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"50\\\"}},{\\\"title\\\":\\\"SGST @ 5%\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"50\\\"}},{\\\"title\\\":\\\"Registration\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"400\\\"}}]},\\\"customer\\\":{\\\"id\\\":\\\"\\\",\\\"cred\\\":\\\"deepakkumar3004@sbx\\\"},\\\"payment\\\":{\\\"uri\\\":\\\"https://api.bpp.com/pay?amt=1500&txn_id=ksh87yriuro34iyr3p4&mode=upi&vpa=sana.bhatt@upi\\\",\\\"type\\\":\\\"ON-ORDER\\\",\\\"status\\\":\\\"PAID\\\",\\\"tl_method\\\":\\\"http/get\\\",\\\"params\\\":{\\\"transaction_id\\\":\\\"abc128-riocn83920\\\",\\\"amount\\\":\\\"1500\\\",\\\"mode\\\":\\\"UPI\\\",\\\"vpa\\\":\\\"sana.bhatt@upi\\\"}}}}}\",\"slotId\":\"325683d4-ccf7-4fac-a042-21171c9f7821\",\"patientGender\":null,\"patientName\":null,\"patientConsumerUrl\":null,\"transId\":null,\"primaryDoctorName\":null,\"primaryDoctorHprAddress\":null,\"secondaryDoctorName\":null,\"secondaryDoctorHprAddress\":null,\"teleconUrl\":null,\"groupConsultStatus\":null,\"abhaId\":\"deepakkumar3004@sbx\",\"createDate\":null,\"modifyDate\":null,\"user\":null,\"payment\":{\"transactionId\":\"abc128-riocn83920\",\"method\":\"https://api.bpp.com/pay?amt=1500&txn_id=ksh87yriuro34iyr3p4&mode=upi&vpa=sana.bhatt@upi\",\"currency\":\"INR\",\"transactionTimestamp\":null,\"consultationCharge\":\"1000\",\"phrHandlingFees\":\"400\",\"sgst\":\"50\",\"cgst\":\"50\",\"transactionState\":\"PAID\",\"user\":null,\"userAbhaId\":\"deepakkumar3004@sbx\"},\"primaryDoctorGender\":null,\"primaryDoctorProviderURI\":null,\"secondaryDoctorGender\":null,\"secondaryDoctorProviderURI\":null}]",new TypeReference<List<Orders>>(){});
		chatUser=new ChatUser();
		chatUser.setUserId("userid");
		chatUser.setUserName("username");
	}
	@Test
	void contextLoads() {
	}	
	
	   @Test
	    public void testGetAllOrders() throws Exception {
	        when(orderRepo.findAll())
	                .thenReturn(ordersList);
	        assertEquals(1, saveInDbService.getOrderDetails().size());
	    }
	   
	   @Test
	    public void testGetOrderByAbhaId() throws Exception {
	        // given - precondition or setup
	        String abhaId = "nikhil@sbx";	        
	        when(orderRepo.findByAbhaIdOrderByServiceFulfillmentStartTime(abhaId)).thenReturn(ordersList);
	        assertEquals(1, saveInDbService.getOrderDetailsByAbhaId(abhaId).size());
	    }
	   
	   @Test
	    public void testGetOrderByOrderId() throws Exception {
	        // given - precondition or setup
	        String orderId = "432-87681";	        
	        when(orderRepo.findByOrderId(orderId)).thenReturn(ordersList);
	        assertEquals(1, saveInDbService.getOrderDetailsByOrderId(orderId).size());
	    }
	   
	   @Test
	    public void testGetOrderByAbhaIdDesc() throws Exception {
	        // given - precondition or setup
	        String abhaId = "nikhil@sbx";	        
	        when(orderRepo.findByAbhaIdOrderByServiceFulfillmentStartTimeDesc(abhaId)).thenReturn(ordersList);
	        assertEquals(1, saveInDbService.getOrderDetailsByAbhaIdDesc(abhaId).size());
	    }

	
	
	
	

}
