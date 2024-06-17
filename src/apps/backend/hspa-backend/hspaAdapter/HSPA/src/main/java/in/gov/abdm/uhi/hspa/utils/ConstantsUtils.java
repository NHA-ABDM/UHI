package in.gov.abdm.uhi.hspa.utils;

public class ConstantsUtils {
    public static final String APPLICATION_DESTINATION_PREFIX = "/msg-hspa";
    public static final String USER_DESTINATION_PREFIX = "/msg";
    public static final String WEBSOCKET_CONNECT_ENDPOINT = "/hspa-chat";
    public static final String MESSAGE_ACTION = "message";
    public static final String ON_MESSAGE_ACTION = "on_message";
    public static final String QUEUE_SPECIFIC_USER = "/queue/specific-user";
    public static final String HSPA_SCHEMA_NAME = "hspa";
    public static final String CHAT = "chat";
    public static final String PROVIDERID = "hspa-nha";
    public static final String ABDM_GOV_IN_SPECIALITY_TAG = "@abdm/gov.in/speciality";
    public static final String ABDM_GOV_IN_LANGUAGES_TAG = "@abdm/gov.in/languages";
    public static final String INITIALIZED = "INITIALIZED";
    public static final String ON_CONFIRM = "on_confirm";
    public static final String ON_INIT = "on_init";
    public static final String ABDM_GOV_IN_PATIENT_KEY = "@abdm/gov.in/patient_key";
    public static final String REQUESTER_CALLED = "Requester::called ";
    public static final String TELECONSULTATION = "Online";
    public static final String BLOODBANK = "BloodStock";
    public static final String PHYSICAL_CONSULTATION = "Physical";
    public static final String PHYSICAL_OPD = "Physical-OPD";
    public static final String GROUP_CONSULTATION = "GroupConsultation";
    public static final String CONFIRMED = "CONFIRMED";
    public static final String CANCELLED = "CANCELLED";
    public static final String PATIENT = "patient";
    public static final String CANCEL = "cancel";
    public static final String REQUESTER_ERROR = "Requester::error:: {}";
    public static final String HPRID = "hprid";
    public static final String REQUESTER_MESSAGE_ID_IS = "Requester message id is --> {}";
    public static final String DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss";
    public static final String DATE_TIME_PATTERN = ConstantsUtils.DATE_FORMAT;
    public static final String FROM_DATE = "fromDate";
    public static final String TO_DATE = "toDate";
    public static final String SPECIALITY = "speciality";
    public static final String GENDER = "gender";
    public static final String PERSON = "person";
    public static final String IDENTIFIER = "identifier";
    public static final String DISPLAY = "display";
    public static final String RESULTS = "results";
    public static final Object ABDM_GOV_IN_PRIMARY_DOCTOR_NAME = "@abdm/gov.in/primaryDoctorName";
    public static final Object ABDM_GOV_IN_PRIMARY_DOCTOR_HPR = "@abdm/gov.in/primaryHprAddress";
    public static final Object ABDM_GOV_IN_PRIMARY_DOCTOR_PROVIDER_URL = "@abdm/gov.in/primaryDoctorProviderUrl";
    public static final Object ABDM_GOV_IN_PRIMARY_DOCTOR_GENDER = "@abdm/gov.in/primaryDoctorGender";

    public static final Object ABDM_GOV_IN_SECONDARY_DOCTOR_NAME = "@abdm/gov.in/secondaryDoctorName";
    public static final Object ABDM_GOV_IN_SECONDARY_DOCTOR_HPR = "@abdm/gov.in/secondaryHprAddress";
    public static final Object ABDM_GOV_IN_SECONDARY_DOCTOR_PROVIDER_URL = "@abdm/gov.in/secondaryDoctorProviderUrl";
    public static final Object ABDM_GOV_IN_SECONDARY_GENDER = "@abdm/gov.in/secondaryDoctorGender";

    public static final String ABDM_GOV_IN_PATIENT_GENDER = "@abdm/gov.in/patientGender";

    public static final String ABDM_GOV_IN_CONSUMER_URL = "@abdm/gov.in/consumerUrl";


    public static final Object ABDM_GOV_IN_GROUPCONSULT = "@abdm/gov.in/groupConsultation";
    public static final String False = "false";
    public static final String PROVIDERNAME = "Test Hospital";
    public static final String CATALOGPROVNAME = "Ref HSPA";
    public static final String CITY = "Delhi";
    public static final String CITYCODE = "011";
    public static final String COUNTRY = "INDIA";
    public static final String COUNTRYCODE = "+91";
    public static final String PROVIDERADDRESS = "3rd, 7th & 9th Floor, Tower-L, Jeevan Bharati Building, Connaught Place, New Delhi, Delhi 110001";
    public static final String PROVIDERGPS = "18.5246036,73.792927";

    public static final String CATALOG_SHORT_DESCRIPTION = "Reference HSPA Test hospital";
    public static final String CATALOG_LONG_DESCRIPTION = "Expert institution providing patient treatment with specialized health science and auxiliary healthcare staff and extraordinary medical equipments.";
    public static final String PROVIDER_LONG_DESCRIPTION = "We are Test hospital. We have established a very profound name in the healthcare industry by providing expert services in every healthcare fields that we have.";
    public static final String PROVIDER_SHORT_DESCRIPTION = "Expertise in every field with renowned staff.";

    public static final String EDUCATION = "education";
    public static final String EXPERIENCE = "experience";
    public static final String CHARGES = "charges";
    public static final String FIRST_CONSULTATION = "first_consultation";
    public static final String FOLLOW_UP = "follow_up";
    public static final String HPR_ID = "hpr_id";
    public static final String LAB_REPORT_CONSULTATION = "lab_report_consultation";
    public static final String LANGUAGES = "languages";
    public static final String RECEIVE_PAYMENT = "receive_payment";
    public static final String PARENT_CATEGORY = "parent_category";
    public static final String UPI_ID = "upi_id";
    public static final String IS_TELECONSULTATION = "is_teleconsultation";
    public static final String IS_PHYSICAL_CONSULTATION = "is_physical_consultation";
    public static final String PROFILE_PHOTO = "profile_photo";
    public static final String UNSPECIFIED_CASE = "Unspecified case";
    public static final String CONSULTATION_DESCRIPTOR = "Consultation";
    public static final String HSPA_IMAGE = "HSPA IMAGE";
    public static final String INVALID_FULFILLMENT_TYPE = "Invalid Fulfillment type";
    public static final String ARRAY_SHOULD_CONTAIN_ONLY_ONE_ITEM = "Array should contain only one item";
    public static final String PAYMENT_URL = "https://api.bpp.com/pay?amt=100&txn_id=ksh87yriuro34iyr3p4&mode=upi&vpa=doctor@upi";
    public static final String CGST_5 = "CGST @ 5%";
    public static final String SGST_5 = "SGST @ 5%";
    public static final String CURRENCY = "INR";
    public static final String PAYMENT_STATE_INIT = "ON-ORDER";
    public static final String PAYMENT_STATUS_INIT = "NOT-PAID";
    public static final String PAYMENT_STATUS_PAID = "PAID";
    public static final String PAYMENT_STATUS_FREE = "FREE";
    public static final String APPOINTMENT_STATUS_SCHEDULED = "SCHEDULED";
    public static final String INVALID_FULFILLMENTS = "Invalid fulfillments";
    public static final String PARENT_CATEGORY_ID = "parent_category_id";
    public static final String INVALID_CATEGORIES = "Invalid Categories";
    public static final String CATEGORY_ID = "category_id";
    public static final String ERROR_COMMON_SERVICE_MESSAGE_ID_IS = "Error::CommonService:: {}, Message id is {}";
    public static final String NULL = "null";
    public static final String FIRST_SEARCH_SCHEMA_FILE = "context-schema.json";

    //ENDPOINTS
    public static final String INIT_ENDPOINT = "/init";
    public static final String SEARCH_ENDPOINT = "/search";
    public static final String CONFIRM_ENDPOINT = "/confirm";
    public static final String CANCEL_ENDPOINT = "/cancel";
    public static final String APPLICATION_JSON = "application/json";
    public static final String ON_MESSAGE_ENDPOINT = "/on_message";
    public static final String MESSAGE_ENDPOINT = "/message";
    public static final String GET_MESSAGES_SENDER_RECEIVER_ENDPOINT = "/getMessages/{sender}/{receiver}";
    public static final String NOTIFICATION_TOKEN_ENDPOINT = "/notification/token";
    public static final String SAVE_TOKEN_ENDPOINT = "/saveToken";
    public static final String LOGOUT_ENDPOINT = "/logout";
    public static final String SAVE_PUBLIC_KEY_ENDPOINT = "/savePublicKey";
    public static final String GET_PUBLIC_KEY_USERNAME_ENDPOINT = "/getPublicKey/{username}";
    public static final String SAVE_KEY_ENDPOINT = "/saveKey";
    public static final String GET_KEY_USER_NAME_ENDPOINT = "/getKey/{userName}";
    public static final String UPLOAD_FILE_ENDPOINT = "/uploadFile";
    public static final String UPLOAD_MULTIPLE_FILES_ENDPOINT = "/uploadMultipleFiles";
    public static final String DOWNLOAD_FILE_FILE_NAME_ENDPOINT = "/downloadFile/{fileName}";
    public static final String GET_ORDERS_ENDPOINT = "/getOrders";
    public static final String GET_ORDERS_BY_ORDERID_ORDERID_ENDPOINT = "/getOrdersByOrderid/{orderid}";
    public static final String GET_ORDERS_BY_ABHA_ID_ABHAID_ENDPOINT = "/getOrdersByAbhaId/{abhaid}";
    public static final String GET_ORDERS_BY_HPR_ID_HPRID_ENDPOINT = "/getOrdersByHprId/{hprid}";
    public static final String GET_ORDERS_BY_HPR_ID_AND_TYPE_HPRID_ENDPOINT = "/getOrdersByHprIdAndType/{hprid}";
    public static final String GET_ORDERS_BY_HPR_ID_AND_TYPE_HPRID_A_TYPE_ENDPOINT = "/getOrdersByHprIdAndType/{hprid}/{aType}";


    public static final String INVALID_JSON_REQUEST = "Invalid Json request. Kindly validate your JSON request. ";
    public static final String MESSAGE_SCHEMA_JSON_FILE = "message-schema.json";
    public static final String ACK = "ACK";
    public static final String NACK = "NACK";
    public static final String SAVE_TOKEN_SCHEMA_JSON_SCHEMA = "save-token-schema.json";
    public static final String INIT_SCHEMA_JSON_FILE = "init-schema.json";
    public static final String CONFIRM_SCHEMA_JSON_FILE = "confirm-schema.json";
    public static final String SECOND_SEARCH_SCHEMA_FILE = "second-search-schema.json";
    public static final String ON_SEARCH_ENDPOINT = "on_search";
    public static final String CONSULTATION_BREAKUP = "Consultation";
    public static final String CGST_BREAKUP_TITLE = "CGST @ ";
    public static final String CGST_PERCENT_BREAKUP = "5%";
    public static final String SGST_BREAKUP_TITLE = "SGST @ ";
    public static final String SGST_PERCENT_BREAKUP = "5%";
    public static final String INVALID_BREAKUP_ERROR = "Invalid breakup. Please include CGST, SGST and consultation charges";
    public static final String CREATE_MEETINGAPI_LINK_API = "https://apivc-lb.aieze.in/api/v1/meeting/create";
    public static final String MEDIA = "media";

    public static final String TIMEFORMAT = "yyyy-MM-dd'T'HH:mm:ss";
    public static final String X_GATEWAY_AUTHORIZATION = "X-Gateway-Authorization";
    public static final String ABDM_GOV_IN_LANGUAGES = "@abdm/gov.in/languages";
    public static final String ABDM_GOV_IN_EDUCATION = "@abdm/gov.in/education";
    public static final String ABDM_GOV_IN_HPR_ID = "@abdm/gov.in/hpr_id";
    public static final String ABDM_GOV_IN_EXPERIENCE = "@abdm/gov.in/experience";
    public static final String UPDATE_ORDER_ID_ENDPOINT = "/order/{orderId}";
    public static final String STATUS_ENDPOINT = "/status";
    public static final String STATUS_SCHEMA_FILE = "status-schema.json";
    public static final String CANCEL_SCHEMA_FILE = "cancel-schema.json";
    public static final String ALL_BLOOD_GROUPS = "-1";
    public static final String RESPONSE_JSON_STRING = "{\"descriptor\":{\"name\":\"e-RaktKosh\",\"images\":\"e-RaktKoshIMAGE\",\"short_desc\":\"e-RaktKosh:ACentralizedBloodBankManagementSystem\",\"long_desc\":\"WeareTesthospital.Wehaveestablishedaveryprofoundnameinthehealthcareindustrybyprovidingexpertservicesineveryhealthcarefieldsthatwehave.\"},\"providers\":[{\"id\":\"0\",\"descriptor\":{\"name\":\"AzadPanchiGroup's,JansevaBloodCentre\",\"short_desc\":\"Charitable/Vol\",\"long_desc\":\"WeareTesthospital.Wehaveestablishedaveryprofoundnameinthehealthcareindustrybyprovidingexpertservicesineveryhealthcarefieldsthatwehave.\"},\"categories\":[{\"id\":\"0\",\"parent_category_id\":\"101\",\"descriptor\":{\"name\":\"WholeBlood\",\"code\":\"11\"}}],\"fulfillments\":[{\"id\":\"0\",\"type\":\"NotAvailable\",\"start\":{\"time\":{\"timestamp\":\"2023-01-03T12:30:00\"}}},{\"id\":\"1\",\"type\":\"Available\",\"start\":{\"time\":{\"timestamp\":\"2023-01-03T12:30:00\"}}}],\"items\":[{\"id\":\"0\",\"descriptor\":{\"name\":\"O+Ve\",\"code\":\"15\"},\"quantity\":{\"count\":2,\"Measure\":{\"unit\":\"Units\"}},\"category_id\":\"0\",\"fulfillment_id\":\"1\"},{\"id\":\"1\",\"descriptor\":{\"name\":\"AB+Ve\",\"code\":\"17\"},\"quantity\":{\"count\":16,\"Measure\":{\"unit\":\"Units\"}},\"category_id\":\"0\",\"fulfillment_id\":\"0\"},{\"id\":\"2\",\"descriptor\":{\"name\":\"AB-Ve\",\"code\":\"18\"},\"quantity\":{\"count\":11,\"Measure\":{\"unit\":\"Units\"}},\"category_id\":\"0\",\"fulfillment_id\":\"1\"},{\"id\":\"3\",\"descriptor\":{\"name\":\"A+Ve\",\"code\":\"11\"},\"quantity\":{\"count\":34,\"Measure\":{\"unit\":\"Units\"}},\"category_id\":\"0\",\"fulfillment_id\":\"1\"},{\"id\":\"4\",\"descriptor\":{\"name\":\"O-Ve\",\"code\":\"16\"},\"quantity\":{\"count\":23,\"Measure\":{\"unit\":\"Units\"}},\"category_id\":\"0\",\"fulfillment_id\":\"1\"}],\"location\":{\"id\":\"1\",\"descriptor\":{\"name\":\"AzadPanchiGroup's,JansevaBloodCentre\",\"short_desc\":\"Charitable/Vol\",\"long_desc\":\"WeareTesthospital.Wehaveestablishedaveryprofoundnameinthehealthcareindustrybyprovidingexpertservicesineveryhealthcarefieldsthatwehave.\"},\"city\":{\"name\":\"Pune\",\"code\":\"022\"},\"country\":{\"name\":\"INDIA\",\"code\":\"+91\"},\"state\":{\"name\":\"Maharashtra\",\"code\":\"27\"},\"district\":{\"name\":\"Pune\",\"code\":\"521\"},\"gps\":\"18.5246036,73.792927\",\"address\":\"BuildingNo.G,KalapiCiraCo-OperativeSociety,PaudRoad,S.No.1228&1229,Pirangut,Tal.-Mulshi,pirangut,Pune,Maharashtra\"},\"contact\":{\"phone\":\"8987628900\",\"email\":\"test@xyz.com\",\"tags\":{\"@abdm/gov/in/contact/fax\":\"7766728\"}}},{\"id\":\"1\",\"descriptor\":{\"name\":\"MetroBloodCentre,CivilHospitalAundhPune\",\"short_desc\":\"Govt.\",\"long_desc\":\"WeareTesthospital.Wehaveestablishedaveryprofoundnameinthehealthcareindustrybyprovidingexpertservicesineveryhealthcarefieldsthatwehave.\"},\"categories\":[{\"id\":\"0\",\"parent_category_id\":\"101\",\"descriptor\":{\"name\":\"WholeBlood\",\"code\":\"11\"}}],\"fulfillments\":[{\"id\":\"0\",\"type\":\"Available\",\"start\":{\"time\":{\"timestamp\":\"2023-01-03T12:30:00\"}}}],\"items\":[{\"id\":\"0\",\"descriptor\":{\"name\":\"O+Ve\",\"code\":\"15\"},\"quantity\":{\"count\":10,\"Measure\":{\"unit\":\"Units\"}},\"category_id\":\"0\",\"fulfillment_id\":\"1\"},{\"id\":\"1\",\"descriptor\":{\"name\":\"AB+Ve\",\"code\":\"17\"},\"quantity\":{\"count\":88,\"Measure\":{\"unit\":\"Units\"}},\"category_id\":\"0\",\"fulfillment_id\":\"0\"},{\"id\":\"2\",\"descriptor\":{\"name\":\"AB-Ve\",\"code\":\"18\"},\"quantity\":{\"count\":78,\"Measure\":{\"unit\":\"Units\"}},\"category_id\":\"0\",\"fulfillment_id\":\"1\"},{\"id\":\"3\",\"descriptor\":{\"name\":\"A+Ve\",\"code\":\"11\"},\"quantity\":{\"count\":66,\"Measure\":{\"unit\":\"Units\"}},\"category_id\":\"0\",\"fulfillment_id\":\"1\"},{\"id\":\"4\",\"descriptor\":{\"name\":\"O-Ve\",\"code\":\"16\"},\"quantity\":{\"count\":98,\"Measure\":{\"unit\":\"Units\"}},\"category_id\":\"0\",\"fulfillment_id\":\"1\"}],\"location\":{\"id\":\"1\",\"descriptor\":{\"name\":\"MetroBloodCentre,CivilHospitalAundhPune\",\"short_desc\":\"Govt.\",\"long_desc\":\"WeareTesthospital.Wehaveestablishedaveryprofoundnameinthehealthcareindustrybyprovidingexpertservicesineveryhealthcarefieldsthatwehave.\"},\"city\":{\"name\":\"Pune\",\"code\":\"022\"},\"country\":{\"name\":\"INDIA\",\"code\":\"+91\"},\"gps\":\"18.5246036,73.792927\",\"address\":\"AundhCamp,,Pune,Pune,Maharashtra\"},\"contact\":{\"phone\":\"8987628900\",\"email\":\"test@xyz.com\",\"tags\":{\"@abdm/gov/in/contact/fax\":\"7766728\"}}}]}";
}

