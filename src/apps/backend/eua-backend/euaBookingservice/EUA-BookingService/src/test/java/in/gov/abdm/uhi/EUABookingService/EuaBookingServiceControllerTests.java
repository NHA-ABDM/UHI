package in.gov.abdm.uhi.EUABookingService;

import static org.mockito.BDDMockito.given;

import java.util.List;

import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.reactive.WebFluxTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Description;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.springframework.test.web.reactive.server.WebTestClient.BodySpec;
import org.springframework.util.Assert;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import in.gov.abdm.uhi.EUABookingService.constants.ConstantsUtils;
import in.gov.abdm.uhi.EUABookingService.controller.EuaBookingController;
import in.gov.abdm.uhi.EUABookingService.entity.Orders;
import in.gov.abdm.uhi.EUABookingService.exceptions.UserException;
import in.gov.abdm.uhi.EUABookingService.repository.OrderRepository;
import in.gov.abdm.uhi.EUABookingService.service.SaveDataDbService;
import in.gov.abdm.uhi.EUABookingService.serviceImpl.SaveInDbServiceImpl;
import in.gov.abdm.uhi.common.dto.Request;
import in.gov.abdm.uhi.common.dto.Response;

@WebFluxTest(EuaBookingController.class)
class EuaBookingServiceControllerTests {

	@Mock
	EuaBookingController euaBookingController;

	@MockBean
	SaveDataDbService saveData;

	@MockBean
	SimpMessagingTemplate messagingTemplate;
	
	@MockBean
	Orders orders;
	
	@MockBean
	List<Orders> ordersList;

	@Autowired
	WebTestClient webTestClient;
	
	@MockBean
	WebClient webClient;
	

	Request onInit;
	Request onConfirm;
	Request onCancel;

	Orders order;
	Response MessageAck;
	ObjectMapper objectMapper;

	@BeforeEach
	public void setUp() throws JsonProcessingException {
		objectMapper = new ObjectMapper();
		MockitoAnnotations.openMocks(this);
		onInit = objectMapper.readValue("{\"context\":{\"domain\":\"Health\",\"country\":\"IND\",\"city\":\"std:080\",\"action\":\"on_init\",\"timestamp\":\"2023-01-06T05:41:46.640Z\",\"core_version\":\"0.7.1\",\"consumer_id\":\"eua-nha\",\"consumer_uri\":\"https://uhieuasandbox.abdm.gov.in/api/v1/euaService\",\"provider_id\":\"https://d13vrgqy7ae26s.cloudfront.net/\",\"provider_uri\":\"https://d13vrgqy7ae26s.cloudfront.net/api/v3/vaccinator/HSPA\",\"transaction_id\":\"c28f8ae0-8d84-11ed-ad3c-557734746c90\",\"message_id\":\"c28f8ae0-8d84-11ed-ad3c-557734746c90\"},\"message\":{\"order\":{\"id\":\"4321\",\"provider\":{\"id\":\"1690\"},\"item\":{\"id\":\"0\",\"descriptor\":{\"name\":\"Consultation\",\"code\":\"Consultation\"},\"price\":{\"currency\":\"INR\",\"value\":\"500\"},\"fulfillment_id\":\"913a24f8-b0ba-4922-8014-8d88952ee35e|15\"},\"fulfillment\":{\"id\":\"913a24f8-b0ba-4922-8014-8d88952ee35e|15\",\"type\":\"Online\",\"agent\":{\"id\":\"shatul@hpr.ndhm\",\"name\":\"Shatul Shankar Patil\",\"gender\":\"M\",\"tags\":{\"@abdm/gov/in/education\":\"MBBS\",\"@abdm/gov/in/experience\":\"3.5\",\"@abdm/gov/in/follow_up\":\"300\",\"@abdm/gov/in/first_consultation\":\"500\",\"@abdm/gov/in/speciality\":\"General Medicine\",\"@abdm/gov/in/languages\":\"English\",\"@abdm/gov/in/upi_id\":\"shatul@oktest\",\"@abdm/gov/in/hpr_id\":\"\",\"@abdm/gov.in/groupConsultation\":\"false\",\"@abdm/gov.in/consumerUrl\":\"https://uhieuasandbox.abdm.gov.in/api/v1/bookingService/\"}},\"start\":{\"time\":{\"timestamp\":\"2023-01-06T13:00:00\"}},\"end\":{\"time\":{\"timestamp\":\"2023-01-06T13:15:00\"}},\"tags\":{\"@abdm/gov.in/slot\":\"913a24f8-b0ba-4922-8014-8d88952ee35e|15\"}},\"billing\":{\"name\":\"Srikanth\",\"address\":{\"door\":\"\",\"name\":\"Srikanth\",\"locality\":\"Hyderabad \",\"city\":\"Medchal Malkajgiri\",\"state\":\"Telangana\",\"country\":\"INDIA\",\"area_code\":\"\"},\"email\":\"\",\"phone\":\"9908173727\"},\"quote\":{\"price\":{\"currency\":\"INR\",\"value\":\"500\"},\"breakup\":[{\"title\":\"Consultation\",\"price\":{\"currency\":\"INR\",\"value\":\"0.00\"}},{\"title\":\"CGST @ 5%\",\"price\":{\"currency\":\"INR\",\"value\":\"0.0\"}},{\"title\":\"SGST @ 5%\",\"price\":{\"currency\":\"INR\",\"value\":\"0.0\"}},{\"title\":\"Registration\",\"price\":{\"currency\":\"INR\",\"value\":\"0.0\"}}]},\"customer\":{\"id\":\"srikanth.bantu@sbx\",\"person\":{\"gender\":\"F\",\"dob\":\"2022-8-26\"}},\"payment\":{\"uri\":\"\",\"type\":\"POST-FULFILLMENT\",\"status\":\"FREE\"}}}}",Request.class);
		String ack = "{\r\n" + "    \"message\": {\r\n" + "        \"ack\": {\r\n"
				+ "            \"status\": \"ACK\"\r\n" + "        }\r\n" + "    }\r\n" + "}";
		MessageAck = objectMapper.readValue(ack, Response.class);	
		
		orders = objectMapper.readValue("{\"error\":null,\"orderId\":\"578a0e40-02f2-11ed-b79c-471dcc9624f4\",\"categoryId\":\"1\",\"appointmentId\":null,\"orderDate\":null,\"healthcareServiceName\":\"Consultation\",\"healthcareServiceId\":\"1\",\"healthcareProviderName\":null,\"healthcareProviderId\":null,\"healthcareProviderUrl\":\"http://100.96.9.171:8084/api/v1\",\"healthcareServiceProviderEmail\":null,\"healthcareServiceProviderPhone\":null,\"healthcareProfessionalName\":\"deepak.kumar@hpr.abdm - Deepak Kumar\",\"healthcareProfessionalImage\":null,\"healthcareProfessionalEmail\":null,\"healthcareProfessionalPhone\":null,\"healthcareProfessionalId\":\"deepak.kumar@hpr.abdm\",\"healthcareProfessionalGender\":\"M\",\"serviceFulfillmentStartTime\":\"2022-07-14T16:00:00\",\"serviceFulfillmentEndTime\":\"2022-07-14T16:15:00\",\"serviceFulfillmentType\":\"Teleconsultation\",\"symptoms\":null,\"languagesSpokenByHealthcareProfessional\":null,\"healthcareProfessionalExperience\":null,\"isServiceFulfilled\":\"CONFIRMED\",\"healthcareProfessionalDepartment\":null,\"message\":\"{\\\"context\\\":{\\\"domain\\\":\\\"nic2004:85111\\\",\\\"country\\\":\\\"IND\\\",\\\"city\\\":\\\"std:080\\\",\\\"action\\\":\\\"on_confirm\\\",\\\"timestamp\\\":\\\"2022-07-17T21:25:48.376113Z\\\",\\\"core_version\\\":\\\"0.7.1\\\",\\\"consumer_id\\\":\\\"eua-nha\\\",\\\"consumer_uri\\\":\\\"http://100.96.9.173:8080/api/v1/euaService\\\",\\\"provider_uri\\\":\\\"http://100.96.9.171:8084/api/v1\\\",\\\"transaction_id\\\":\\\"5cb7bd40-02f2-11ed-b79c-471dcc9624f4\\\",\\\"message_id\\\":\\\"5cb7bd40-02f2-11ed-b79c-471dcc9624f4\\\"},\\\"message\\\":{\\\"order\\\":{\\\"id\\\":\\\"578a0e40-02f2-11ed-b79c-471dcc9624f4\\\",\\\"state\\\":\\\"CONFIRMED\\\",\\\"item\\\":{\\\"id\\\":\\\"1\\\",\\\"descriptor\\\":{\\\"name\\\":\\\"Consultation\\\"},\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"1000\\\"},\\\"fulfillment_id\\\":\\\"325683d4-ccf7-4fac-a042-21171c9f7821\\\"},\\\"fulfillment\\\":{\\\"id\\\":\\\"325683d4-ccf7-4fac-a042-21171c9f7821\\\",\\\"type\\\":\\\"Teleconsultation\\\",\\\"agent\\\":{\\\"id\\\":\\\"deepak.kumar@hpr.abdm\\\",\\\"name\\\":\\\"deepak.kumar@hpr.abdm - Deepak Kumar\\\",\\\"gender\\\":\\\"M\\\",\\\"tags\\\":{\\\"@abdm/gov/in/education\\\":\\\"MS\\\",\\\"@abdm/gov/in/experience\\\":\\\"7.0\\\",\\\"@abdm/gov/in/follow_up\\\":\\\"200.0\\\",\\\"@abdm/gov/in/first_consultation\\\":\\\"500.0\\\",\\\"@abdm/gov/in/speciality\\\":\\\"ENT\\\",\\\"@abdm/gov/in/languages\\\":\\\"Eng, Hin\\\",\\\"@abdm/gov/in/upi_id\\\":\\\"9896271877@okicici\\\",\\\"@abdm/gov/in/hpr_id\\\":\\\"10696314\\\"}},\\\"start\\\":{\\\"time\\\":{\\\"timestamp\\\":\\\"2022-07-14T16:00:00\\\"}},\\\"end\\\":{\\\"time\\\":{\\\"timestamp\\\":\\\"2022-07-14T16:15:00\\\"}},\\\"tags\\\":{\\\"@abdm/gov.in/slot_id\\\":\\\"325683d4-ccf7-4fac-a042-21171c9f7821\\\"}},\\\"billing\\\":{\\\"name\\\":\\\"Deepak Kumar\\\",\\\"address\\\":{\\\"door\\\":\\\"21A\\\",\\\"name\\\":\\\"ABC Apartments\\\",\\\"locality\\\":\\\"Dwarka\\\",\\\"city\\\":\\\"New Delhi\\\",\\\"state\\\":\\\"New Delhi\\\",\\\"country\\\":\\\"India\\\",\\\"area_code\\\":\\\"110011\\\"},\\\"email\\\":\\\"\\\",\\\"phone\\\":\\\"9896271877\\\"},\\\"quote\\\":{\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"1000\\\"},\\\"breakup\\\":[{\\\"title\\\":\\\"Consultation\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"1000\\\"}},{\\\"title\\\":\\\"CGST @ 5%\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"50\\\"}},{\\\"title\\\":\\\"SGST @ 5%\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"50\\\"}},{\\\"title\\\":\\\"Registration\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"400\\\"}}]},\\\"customer\\\":{\\\"id\\\":\\\"\\\",\\\"cred\\\":\\\"deepakkumar3004@sbx\\\"},\\\"payment\\\":{\\\"uri\\\":\\\"https://api.bpp.com/pay?amt=1500&txn_id=ksh87yriuro34iyr3p4&mode=upi&vpa=sana.bhatt@upi\\\",\\\"type\\\":\\\"ON-ORDER\\\",\\\"status\\\":\\\"PAID\\\",\\\"tl_method\\\":\\\"http/get\\\",\\\"params\\\":{\\\"transaction_id\\\":\\\"abc128-riocn83920\\\",\\\"amount\\\":\\\"1500\\\",\\\"mode\\\":\\\"UPI\\\",\\\"vpa\\\":\\\"sana.bhatt@upi\\\"}}}}}\",\"slotId\":\"325683d4-ccf7-4fac-a042-21171c9f7821\",\"patientGender\":null,\"patientName\":null,\"patientConsumerUrl\":null,\"transId\":null,\"primaryDoctorName\":null,\"primaryDoctorHprAddress\":null,\"secondaryDoctorName\":null,\"secondaryDoctorHprAddress\":null,\"teleconUrl\":null,\"groupConsultStatus\":null,\"abhaId\":\"deepakkumar3004@sbx\",\"createDate\":null,\"modifyDate\":null,\"user\":null,\"payment\":{\"transactionId\":\"abc128-riocn83920\",\"method\":\"https://api.bpp.com/pay?amt=1500&txn_id=ksh87yriuro34iyr3p4&mode=upi&vpa=sana.bhatt@upi\",\"currency\":\"INR\",\"transactionTimestamp\":null,\"consultationCharge\":\"1000\",\"phrHandlingFees\":\"400\",\"sgst\":\"50\",\"cgst\":\"50\",\"transactionState\":\"PAID\",\"user\":null,\"userAbhaId\":\"deepakkumar3004@sbx\"},\"primaryDoctorGender\":null,\"primaryDoctorProviderURI\":null,\"secondaryDoctorGender\":null,\"secondaryDoctorProviderURI\":null}", Orders.class);	
		
		onConfirm = objectMapper.readValue("{\"context\":{\"domain\":\"nic2004:85111\",\"country\":\"IND\",\"city\":\"std:080\",\"action\":\"on_confirm\",\"timestamp\":\"2023-01-09T14:57:53.221072Z\",\"core_version\":\"0.7.1\",\"consumer_id\":\"eua-nha\",\"consumer_uri\":\"https://uhieuasandbox.abdm.gov.in/api/v1/euaService\",\"provider_id\":\"hspa-nha\",\"provider_uri\":\"https://hspasbx.abdm.gov.in/api/v1\",\"transaction_id\":\"423783f0-8d09-11ed-b720-9be597b40bea\",\"message_id\":\"423783f0-8d09-11ed-b720-9be597b40bea\"},\"message\":{\"order\":{\"id\":\"3742-314144-8136\",\"provider\":{\"id\":\"1\"},\"state\":\"CONFIRMED\",\"item\":{\"id\":\"0\",\"descriptor\":{\"name\":\"Consultation\",\"code\":\"CONSULTATION\"},\"price\":{\"currency\":\"INR\",\"value\":\"0.0\"},\"fulfillment_id\":\"d2b1d97f-3ef6-4483-a195-5fe542884cde\"},\"fulfillment\":{\"id\":\"d2b1d97f-3ef6-4483-a195-5fe542884cde\",\"type\":\"Online\",\"agent\":{\"id\":\"ganeshborse@hpr.ndhm\",\"name\":\"Ganesh Vikram Borse\",\"gender\":\"M\",\"tags\":{\"@abdm/gov/in/education\":\"MBBS\",\"@abdm/gov/in/experience\":\"5.0\",\"@abdm/gov/in/languages\":\"Eng, Hin\",\"@abdm/gov/in/hpr_id\":\"73-5232-1888-8686\",\"@abdm/gov.in/groupConsultation\":\"false\",\"@abdm/gov.in/patientGender\":\"M\",\"@abdm/gov.in/experience\":\"5.0\"}},\"start\":{\"time\":{\"timestamp\":\"2023-01-05T20:30:00\"}},\"end\":{\"time\":{\"timestamp\":\"2023-01-05T20:45:00\"}},\"tags\":{\"@abdm/gov.in/slot_id\":\"d2b1d97f-3ef6-4483-a195-5fe542884cde\",\"@abdm/gov.in/patient_key\":\"[19, 16, 72, 159, 181, 247, 124, 137, 179, 209, 162, 55, 64, 194, 176, 138, 37, 128, 89, 99, 128, 251, 243, 108, 76, 65, 120, 200, 176, 172, 201, 73]\",\"@abdm/gov.in/doctors_key\":\"[250, 140, 77, 58, 99, 72, 235, 4, 29, 107, 226, 172, 252, 207, 36, 22, 175, 95, 57, 203, 224, 229, 12, 157, 210, 43, 67, 243, 96, 8, 63, 0]\"}},\"billing\":{\"name\":\"Satish\",\"address\":{\"door\":\"\",\"name\":\"Satish\",\"locality\":\"Nanded\",\"city\":\"Nanded\",\"state\":\"Maharashtra\",\"country\":\"INDIA\",\"area_code\":\"\"},\"email\":\"\",\"phone\":\"9511225358\"},\"quote\":{\"price\":{\"currency\":\"INR\",\"value\":\"0.0\"},\"breakup\":[{\"title\":\"Consultation\",\"price\":{\"currency\":\"INR\",\"value\":\"0.0\"}},{\"title\":\"CGST @ 5%\",\"price\":{\"currency\":\"INR\",\"value\":\"0\"}},{\"title\":\"SGST @ 5%\",\"price\":{\"currency\":\"INR\",\"value\":\"0\"}},{\"title\":\"Registration\",\"price\":{\"currency\":\"INR\",\"value\":\"0\"}}]},\"customer\":{\"id\":\"satish661993@sbx\",\"person\":{\"gender\":\"M\",\"dob\":\"1993-6-6\"}},\"payment\":{\"uri\":\"\",\"type\":\"ON-ORDER\",\"status\":\"FREE\",\"tl_method\":\"\",\"params\":{\"transaction_id\":\"\",\"amount\":\"0.0\",\"mode\":\"\",\"vpa\":\"\"}}}}}", Request.class);	

		onCancel=objectMapper.readValue("{\"context\":{\"domain\":\"nic2004:85111\",\"country\":\"IND\",\"city\":\"std:080\",\"action\":\"on_cancel\",\"timestamp\":\"2023-01-05T14:56:41.736388Z\",\"core_version\":\"0.7.1\",\"consumer_id\":\"eua-nha\",\"consumer_uri\":\"https://uhieuasandbox.abdm.gov.in/api/v1/euaService\",\"provider_id\":\"hspa-nha\",\"provider_uri\":\"https://hspasbx.abdm.gov.in/api/v1\",\"transaction_id\":\"299228a0-8d09-11ed-b720-9be597b40bea\",\"message_id\":\"299228a0-8d09-11ed-b720-9be597b40bea\"},\"message\":{\"order\":{\"id\":\"4522-133302-7322\",\"state\":\"CANCELLED\",\"fulfillment\":{\"tags\":{\"@abdm/gov.in/cancelledby\":\"patient\"}}}}}",Request.class);
		ordersList=objectMapper.readValue("[{\"error\":null,\"orderId\":\"578a0e40-02f2-11ed-b79c-471dcc9624f4\",\"categoryId\":\"1\",\"appointmentId\":null,\"orderDate\":null,\"healthcareServiceName\":\"Consultation\",\"healthcareServiceId\":\"1\",\"healthcareProviderName\":null,\"healthcareProviderId\":null,\"healthcareProviderUrl\":\"http://100.96.9.171:8084/api/v1\",\"healthcareServiceProviderEmail\":null,\"healthcareServiceProviderPhone\":null,\"healthcareProfessionalName\":\"deepak.kumar@hpr.abdm - Deepak Kumar\",\"healthcareProfessionalImage\":null,\"healthcareProfessionalEmail\":null,\"healthcareProfessionalPhone\":null,\"healthcareProfessionalId\":\"deepak.kumar@hpr.abdm\",\"healthcareProfessionalGender\":\"M\",\"serviceFulfillmentStartTime\":\"2022-07-14T16:00:00\",\"serviceFulfillmentEndTime\":\"2022-07-14T16:15:00\",\"serviceFulfillmentType\":\"Teleconsultation\",\"symptoms\":null,\"languagesSpokenByHealthcareProfessional\":null,\"healthcareProfessionalExperience\":null,\"isServiceFulfilled\":\"CONFIRMED\",\"healthcareProfessionalDepartment\":null,\"message\":\"{\\\"context\\\":{\\\"domain\\\":\\\"nic2004:85111\\\",\\\"country\\\":\\\"IND\\\",\\\"city\\\":\\\"std:080\\\",\\\"action\\\":\\\"on_confirm\\\",\\\"timestamp\\\":\\\"2022-07-17T21:25:48.376113Z\\\",\\\"core_version\\\":\\\"0.7.1\\\",\\\"consumer_id\\\":\\\"eua-nha\\\",\\\"consumer_uri\\\":\\\"http://100.96.9.173:8080/api/v1/euaService\\\",\\\"provider_uri\\\":\\\"http://100.96.9.171:8084/api/v1\\\",\\\"transaction_id\\\":\\\"5cb7bd40-02f2-11ed-b79c-471dcc9624f4\\\",\\\"message_id\\\":\\\"5cb7bd40-02f2-11ed-b79c-471dcc9624f4\\\"},\\\"message\\\":{\\\"order\\\":{\\\"id\\\":\\\"578a0e40-02f2-11ed-b79c-471dcc9624f4\\\",\\\"state\\\":\\\"CONFIRMED\\\",\\\"item\\\":{\\\"id\\\":\\\"1\\\",\\\"descriptor\\\":{\\\"name\\\":\\\"Consultation\\\"},\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"1000\\\"},\\\"fulfillment_id\\\":\\\"325683d4-ccf7-4fac-a042-21171c9f7821\\\"},\\\"fulfillment\\\":{\\\"id\\\":\\\"325683d4-ccf7-4fac-a042-21171c9f7821\\\",\\\"type\\\":\\\"Teleconsultation\\\",\\\"agent\\\":{\\\"id\\\":\\\"deepak.kumar@hpr.abdm\\\",\\\"name\\\":\\\"deepak.kumar@hpr.abdm - Deepak Kumar\\\",\\\"gender\\\":\\\"M\\\",\\\"tags\\\":{\\\"@abdm/gov/in/education\\\":\\\"MS\\\",\\\"@abdm/gov/in/experience\\\":\\\"7.0\\\",\\\"@abdm/gov/in/follow_up\\\":\\\"200.0\\\",\\\"@abdm/gov/in/first_consultation\\\":\\\"500.0\\\",\\\"@abdm/gov/in/speciality\\\":\\\"ENT\\\",\\\"@abdm/gov/in/languages\\\":\\\"Eng, Hin\\\",\\\"@abdm/gov/in/upi_id\\\":\\\"9896271877@okicici\\\",\\\"@abdm/gov/in/hpr_id\\\":\\\"10696314\\\"}},\\\"start\\\":{\\\"time\\\":{\\\"timestamp\\\":\\\"2022-07-14T16:00:00\\\"}},\\\"end\\\":{\\\"time\\\":{\\\"timestamp\\\":\\\"2022-07-14T16:15:00\\\"}},\\\"tags\\\":{\\\"@abdm/gov.in/slot_id\\\":\\\"325683d4-ccf7-4fac-a042-21171c9f7821\\\"}},\\\"billing\\\":{\\\"name\\\":\\\"Deepak Kumar\\\",\\\"address\\\":{\\\"door\\\":\\\"21A\\\",\\\"name\\\":\\\"ABC Apartments\\\",\\\"locality\\\":\\\"Dwarka\\\",\\\"city\\\":\\\"New Delhi\\\",\\\"state\\\":\\\"New Delhi\\\",\\\"country\\\":\\\"India\\\",\\\"area_code\\\":\\\"110011\\\"},\\\"email\\\":\\\"\\\",\\\"phone\\\":\\\"9896271877\\\"},\\\"quote\\\":{\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"1000\\\"},\\\"breakup\\\":[{\\\"title\\\":\\\"Consultation\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"1000\\\"}},{\\\"title\\\":\\\"CGST @ 5%\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"50\\\"}},{\\\"title\\\":\\\"SGST @ 5%\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"50\\\"}},{\\\"title\\\":\\\"Registration\\\",\\\"price\\\":{\\\"currency\\\":\\\"INR\\\",\\\"value\\\":\\\"400\\\"}}]},\\\"customer\\\":{\\\"id\\\":\\\"\\\",\\\"cred\\\":\\\"deepakkumar3004@sbx\\\"},\\\"payment\\\":{\\\"uri\\\":\\\"https://api.bpp.com/pay?amt=1500&txn_id=ksh87yriuro34iyr3p4&mode=upi&vpa=sana.bhatt@upi\\\",\\\"type\\\":\\\"ON-ORDER\\\",\\\"status\\\":\\\"PAID\\\",\\\"tl_method\\\":\\\"http/get\\\",\\\"params\\\":{\\\"transaction_id\\\":\\\"abc128-riocn83920\\\",\\\"amount\\\":\\\"1500\\\",\\\"mode\\\":\\\"UPI\\\",\\\"vpa\\\":\\\"sana.bhatt@upi\\\"}}}}}\",\"slotId\":\"325683d4-ccf7-4fac-a042-21171c9f7821\",\"patientGender\":null,\"patientName\":null,\"patientConsumerUrl\":null,\"transId\":null,\"primaryDoctorName\":null,\"primaryDoctorHprAddress\":null,\"secondaryDoctorName\":null,\"secondaryDoctorHprAddress\":null,\"teleconUrl\":null,\"groupConsultStatus\":null,\"abhaId\":\"deepakkumar3004@sbx\",\"createDate\":null,\"modifyDate\":null,\"user\":null,\"payment\":{\"transactionId\":\"abc128-riocn83920\",\"method\":\"https://api.bpp.com/pay?amt=1500&txn_id=ksh87yriuro34iyr3p4&mode=upi&vpa=sana.bhatt@upi\",\"currency\":\"INR\",\"transactionTimestamp\":null,\"consultationCharge\":\"1000\",\"phrHandlingFees\":\"400\",\"sgst\":\"50\",\"cgst\":\"50\",\"transactionState\":\"PAID\",\"user\":null,\"userAbhaId\":\"deepakkumar3004@sbx\"},\"primaryDoctorGender\":null,\"primaryDoctorProviderURI\":null,\"secondaryDoctorGender\":null,\"secondaryDoctorProviderURI\":null}]",new TypeReference<List<Orders>>(){});
	
	}
	
	

	@Test
	public void contextLoads() {
		Assertions.assertThat(euaBookingController).isNotNull();
	}

	@Test
	@Description("To test on init call")
	public void givenResponseForOnInit() throws JsonProcessingException, UserException {
		given(saveData.saveDataInDb(onInit,ConstantsUtils.ON_INIT)).willReturn(orders);		
		Response response = webTestClient.post().uri("/api/v1/bookingService/on_init")
				.body(BodyInserters.fromValue(onInit)).exchange()
				.expectBody(Response.class).returnResult().getResponseBody();
		Assert.isTrue(response.getMessage().getAck().getStatus().equals("ACK"), "ACK");

	}
	
	@Test
	@Description("To test on confirm call")
	public void givenResponseForOnConfirm() throws JsonProcessingException, UserException {
		given(saveData.saveDataInDb(onConfirm,ConstantsUtils.ON_CONFIRM)).willReturn(orders);		
		Response response = webTestClient.post().uri("/api/v1/bookingService/on_confirm")
				.body(BodyInserters.fromValue(onConfirm)).exchange()
				.expectBody(Response.class).returnResult().getResponseBody();
		Assert.isTrue(response.getMessage().getAck().getStatus().equals("ACK"), "ACK");

	}

	@Test
	@Description("To test on status call")
	public void givenResponseForOnStatus() throws JsonProcessingException, UserException {
		given(saveData.saveDataInDb(onConfirm,ConstantsUtils.ON_CONFIRM)).willReturn(orders);
		Response response = webTestClient.post().uri("/api/v1/bookingService/on_status")
				.body(BodyInserters.fromValue(onConfirm)).exchange()
				.expectBody(Response.class).returnResult().getResponseBody();
		Assert.isTrue(response.getMessage().getAck().getStatus().equals("ACK"), "ACK");

	}
	
	@Test
	@Description("To test on cancel call")
	public void givenResponseForOnCancel() throws JsonProcessingException, UserException {
		given(saveData.saveDataInDbCancel(onCancel)).willReturn(orders);		
		Response response = webTestClient.post().uri("/api/v1/bookingService/on_cancel")
				.body(BodyInserters.fromValue(onCancel)).exchange()
				.expectBody(Response.class).returnResult().getResponseBody();
		Assert.isTrue(response.getMessage().getAck().getStatus().equals("ACK"), "ACK");

	}
	
	@Test
	@Description("Test to get all orders")
	public void givenResponseForGetAllOrders() throws JsonProcessingException, UserException {
		given(saveData.getOrderDetails()).willReturn(ordersList);		
		List<Orders> o = webTestClient.get().uri("/api/v1/bookingService/getOrders")
				.exchange()
				.expectBodyList(Orders.class).returnResult().getResponseBody();		
		Assert.isTrue(!o.isEmpty(), "NOT Empty");

	}

}
