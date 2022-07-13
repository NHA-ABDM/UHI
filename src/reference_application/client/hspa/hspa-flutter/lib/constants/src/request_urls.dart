class RequestUrls {
  static const String openMrsUrl = 'https://qa-refapp.openmrs.org/openmrs/';
  static const String nhaHostUrl =
      'http://100.65.158.41:8082/openmrs-standalone/';
  static const String hspaBetaUrl =
      'https://uhihspabeta.abdm.gov.in/openmrs-standalone/';
  static const String hspaHackathonUrl =
      'http://121.242.73.124:8181/openmrs-standalone/';

  static const String baseUrl = hspaHackathonUrl;

  static const String getProvider = baseUrl + 'ws/rest/v1/provider';
  static const String addAttributeToProvider = baseUrl + 'ws/rest/v1/provider';
  static const String getProviderAppointmentSlots =
      baseUrl + 'ws/rest/v1/appointmentscheduling/timeslot';
  static const String getProviderAppointments =
      baseUrl + 'ws/rest/v1/appointmentscheduling/appointment';
  static const String addProviderAppointmentSlots =
      baseUrl + 'ws/rest/v1/appointmentscheduling/appointmentblockwithtimeslot';
  static const String getProviderAppointmentHistory =
      baseUrl + 'ws/rest/v1/appointmentscheduling/appointmentstatushistory';

  /// HP ID APIS
  static const String getSessionToken =
      'https://preprod.ndhm.gov.in/gateway/v0.5/sessions';
  static const String sendMobileOtp =
      'https://hpridbeta.ndhm.gov.in/api/v2/auth/loginViaMobileSendOTP';
  static const String verifyMobileOtp =
      'https://hpridbeta.ndhm.gov.in/api/v2/auth/loginViaMobileVerifyOTP';
  static const String getHprIdAuthToken =
      'https://hpridbeta.ndhm.gov.in/api/v2/auth/login/userAuthorizedToken';
  static const String getHprIdDoctorProfile =
      'https://hpridbeta.ndhm.gov.in/api/v2/account/profile';

  /// Chat messages urls
  // static const String bookingService = 'http://100.65.158.41:8084/api/v1/';
  static const String bookingService = 'https://hspabeta.abdm.gov.in/api/v1/';
  static const String bookingServiceHackathon = 'http://121.242.73.124/api/v1/';
  static const String getChatMessages = '${bookingServiceHackathon}getMessages';
  static const String postChatMessage = "${bookingServiceHackathon}message";
  static const String publicChatStompSocketUrl =
      "ws://uhieuabeta.abdm.gov.in/api/v1/bookingService/hspa-chat";
  static const String publicChatStompSocketUrlHackathon =
      "ws://121.242.73.124/api/v1/bookingService/hspa-chat";
  // static const String vpnChatStompSocketUrl = "ws://100.65.158.41:8084/hspa-chat";
  static const String vpnChatStompSocketUrl =
      "wss://hspabeta.abdm.gov.in/hspa-chat";
  static const String vpnChatStompSocketUrlHackathon =
      "wss://121.242.73.124/hspa-chat";
  static const String euaChatStompSocketUrl = vpnChatStompSocketUrlHackathon;
  static const String saveFirebaseToken = bookingServiceHackathon + 'saveToken';
}
