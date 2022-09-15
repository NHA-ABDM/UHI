class RequestUrls {
  static const String openMrsUrl = 'https://qa-refapp.openmrs.org/openmrs/';
  static const String nhaHostUrl =
      'http://100.65.158.41:8082/openmrs-standalone/';
  static const String hspaBetaUrl =
      'https://uhihspabeta.abdm.gov.in/openmrs-standalone/';
  static const String hspaHackathonUrl =
      'http://121.242.73.124:8181/openmrs-standalone/';

  static const String baseUrl = hspaBetaUrl;

  /// OpenMrs APIs without wrapper
  static const String getProviderOpenMrs = baseUrl + 'ws/rest/v1/provider';
  static const String addAttributeToProviderOpenMrs = baseUrl + 'ws/rest/v1/provider';
  static const String getProviderAppointmentSlotsOpenMrs =
      baseUrl + 'ws/rest/v1/appointmentscheduling/timeslot';
  static const String getProviderAppointmentsOpenMrs =
      baseUrl + 'ws/rest/v1/appointmentscheduling/appointment';
  static const String cancelProviderAppointmentOpenMrs =
      baseUrl + 'ws/rest/v1/appointmentscheduling/appointment';
  static const String addProviderAppointmentSlotsOpenMrs =
      baseUrl + 'ws/rest/v1/appointmentscheduling/appointmentblockwithtimeslot';
  static const String getProviderAppointmentHistoryOpenMrs =
      baseUrl + 'ws/rest/v1/appointmentscheduling/appointmentstatushistory';

  /// OpenMrs Wrapper URLs
  // static const String hspaWrapperBetaUrl = 'http://100.65.158.41:8088/';
  static const String hspaWrapperBetaUrl = 'https://uhihspabeta.abdm.gov.in/';
  static const String hspaWrapperSandboxUrl = 'http://121.242.73.124:8082/';
  static const String wrapperBaseUrl = hspaWrapperSandboxUrl;

  static const String getProviderWrapper = wrapperBaseUrl + 'providers';
  static const String addAttributeToProviderWrapper = wrapperBaseUrl + 'providers';
  static const String getProviderAppointmentSlotsWrapper =
      wrapperBaseUrl + 'slots';
  static const String getProviderAppointmentsWrapper =
      wrapperBaseUrl + 'appointments';
  static const String cancelProviderAppointmentWrapper =
      wrapperBaseUrl + 'cancel/appointment';
  static const String addProviderAppointmentSlotsWrapper =
      wrapperBaseUrl + 'slot';
  static const String getProviderAppointmentHistoryWrapper =
      wrapperBaseUrl + 'appointments/statushistory';

  /// OpenMrs APIs with or without openmrs wrapper
  static const String getProvider = getProviderWrapper;
  static const String addAttributeToProvider = addAttributeToProviderWrapper;
  static const String getProviderAppointmentSlots = getProviderAppointmentSlotsWrapper;
  static const String getProviderAppointments = getProviderAppointmentsWrapper;
  static const String cancelProviderAppointment = cancelProviderAppointmentWrapper;
  static const String addProviderAppointmentSlots = addProviderAppointmentSlotsWrapper;
  static const String getProviderAppointmentHistory = getProviderAppointmentHistoryWrapper;

  /// HP ID APIS
  static const String hprBetaUrl = 'https://hpridbeta.ndhm.gov.in/api/v2/';
  static const String hprSandboxUrl = 'https://hpridsbx.ndhm.gov.in/api/v2/';
  static const String hprBaseUrl = hprBetaUrl;

  static const String getSessionToken =
      'https://preprod.ndhm.gov.in/gateway/v0.5/sessions';
  static const String sendMobileOtp = hprBaseUrl + 'auth/loginViaMobileSendOTP';
  static const String verifyMobileOtp = hprBaseUrl + 'auth/loginViaMobileVerifyOTP';
  static const String getHprIdAuthToken = hprBaseUrl + 'auth/login/userAuthorizedToken';
  static const String getHprIdDoctorProfile = hprBaseUrl + 'account/profile';

  /// Chat messages urls
  // static const String bookingService = 'http://100.65.158.41:8084/api/v1/';
  static const String bookingService = 'https://hspabeta.abdm.gov.in/api/v1/';
  static const String bookingServiceHackathon = 'http://121.242.73.124:8084/api/v1/';
  static const String chatMessageBaseUrl = bookingServiceHackathon;
  static const String getChatMessages = '${chatMessageBaseUrl}getMessages';
  static const String postChatMessage = "${chatMessageBaseUrl}message";
  static const String publicChatStompSocketUrl =
      "ws://uhieuabeta.abdm.gov.in/api/v1/bookingService/hspa-chat";
  static const String publicChatStompSocketUrlHackathon =
      "ws://121.242.73.124/api/v1/bookingService/hspa-chat";
  // static const String vpnChatStompSocketUrl = "ws://100.65.158.41:8084/hspa-chat";
  static const String vpnChatStompSocketUrl =
      "wss://hspabeta.abdm.gov.in/hspa-chat";
  static const String vpnChatStompSocketUrlHackathon =
      "ws://121.242.73.124:8084/hspa-chat";
  static const String euaChatStompSocketUrl = vpnChatStompSocketUrlHackathon;
  static const String saveFirebaseToken = chatMessageBaseUrl + 'saveToken';
  static const String deleteFirebaseToken = chatMessageBaseUrl + 'logout';
  static const String savePublicKey = chatMessageBaseUrl + 'savePublicKey';
  static const String getPublicKey = chatMessageBaseUrl + 'getPublicKey';
  static const String savePrivatePublicKey = chatMessageBaseUrl + 'saveKey';
  static const String getPrivatePublicKey = chatMessageBaseUrl + 'getKey';
  static const String getPaymentStatus = chatMessageBaseUrl + 'getOrdersByHprId';

  /// Consumer URI
  static const String consumerUriBeta = 'http://100.65.158.41:8903/api/v1/bookingService';
  static const String consumerUriHackathon = 'http://100.96.9.173:8080/api/v1/bookingService';
  static const String consumerUri = consumerUriHackathon;
  static const String cancelConsumerUri = 'http://100.65.158.41:8901/api/v1/euaService';
  static const String cancelConsumerUriSandbox = 'http://100.96.9.173:8901/api/v1/euaService';
}
