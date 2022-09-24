class RequestUrls {
  ///++++++++++++++++++ ENVIRONMENT ++++++++++++++++++///
  ///UHI EUA ENVIRONMENT URLS
  static const String uhiEuaAbdmBeta = "https://uhieuabeta.abdm.gov.in/api/v1/";
  static const String uhiEuaAbdmSandbox =
      "https://uhieuabeta.abdm.gov.in/api/v1/";
  static const String uhiEuaAbdmBackup =
      "https://uhieuabeta.abdm.gov.in/api/v1/";
  static const String uhiEuaAbdmHackathon =
      "http://121.242.73.125:8080/api/v1/";

  ///UHI EUA URL
  static const String uhiEua = uhiEuaAbdmHackathon;

  ///NDHM DEV ENVIRONMENT URL
  static const String ndhmDev = "https://dev.ndhm.gov.in/";

  ///UHI EUA BETA ENVIRONMENT SOCKET URL
  static const String uhiEuaAbdmBetaSocket =
      "wss://uhieuabeta.abdm.gov.in/api/v1/";
  static const String uhiEuaAbdmSandboxSocket =
      "wss://uhieuabeta.abdm.gov.in/api/v1/";
  static const String uhiEuaAbdmBackupSocket =
      "wss://uhieuabeta.abdm.gov.in/api/v1/";
  static const String uhiEuaAbdmHackathonSocket =
      "ws://121.242.73.125:8080/api/v1/";

  ///UHI EUA SOCKET URL
  static const String uhiEuaSocket = uhiEuaAbdmHackathonSocket;

  ///++++++++++++++++++ ENDPOINTS ++++++++++++++++++///

  ///**************** EUA SERVICE ****************///
  ///EUA SERVICE URL
  static const String euaServiceBeta = "${uhiEua}euaService/";
  static const String euaService = euaServiceBeta;

  ///EUA CLIENT STOMP SOCKET URL
  static const String euaClientStompSocketUrlBeta =
      "${uhiEuaSocket}euaService/ws-client";
  static const String euaClientStompSocketUrl = euaClientStompSocketUrlBeta;

  ///SEARCH API URL
  static String postDiscoveryDetails = "${euaService}search";

  ///SELECT API URL
  static String postFulfillmentDetails = "${euaService}select";

  ///CONFIRM API URL
  static String postConfirmBookingDetails = "${euaService}confirm";

  ///INIT API URL
  static String postInitBookingDetails = "${euaService}init";

  ///APPOINTMENT STATUS API URL
  static String postAppointmentStatus = "${euaService}status";

  ///CANCEL APPOINTMENT API URL
  static String postCancelAppointment = "${euaService}cancel";

  ///GET URLS
  ///Common GET URL for all APIs
  static String getDetails = "${euaService}on_search";

  ///**************** BOOKING SERVICE ****************///
  ///BOOKING SERVICE URL
  static const String bookingServiceBeta = "${uhiEua}bookingService/";
  static const String bookingService = bookingServiceBeta;

  ///EUA CHAT URL
  static const String euaChatStompSocketUrlBeta =
      "${uhiEuaSocket}bookingService/eua-chat";
  static const String euaChatStompSocketUrl = euaChatStompSocketUrlBeta;

  ///GET APPOINTMENTS URL
  static String getOrderDetails = "${bookingService}getOrdersByAbhaId/";

  ///SAVE FCM TOKEN URL
  static String postFCMToken = "${bookingService}saveToken";

  ///LOGOUT USER URL
  static String postLogoutDetails = "${bookingService}logout";

  ///MESSAGE API URL
  static String postChatMessage = "${bookingService}message";

  ///MESSAGE HISTORY API URL
  static String getChatMessages = "${bookingService}getMessages";

  ///SAVE SHARED KEY API URL
  static String postSharedKey = "${bookingService}saveKey";

  ///GET SHARED KEY API URL
  static String getSharedKey = "${bookingService}getKey/";

  ///**************** LOGIN SERVICE ****************///
  ///LOGIN URL
  static String loginService = "${ndhmDev}cm/v1/apps/login/mobileEmail/";

  ///LOGIN INIT API URL
  static String postLoginInitAuth = "${loginService}auth-init";

  static String postAbhaAddressLoginInitAuth =
      "${ndhmDev}cm/v1/apps/phrAddress/auth-init";

  static String postAbhaAddressLoginAuthConfirm =
      "${ndhmDev}cm/v1/apps/phrAddress/auth-confirm";

  ///LOGIN VERIFY API URL
  static String postLoginVerify = "${loginService}pre-Verify";

  ///LOGIN CONFIRM API URL
  static String postLoginConfirm = "${loginService}auth-confirm";

  ///**************** SESSIONS AND PROFILE SERVICE ****************///
  ///SESSIONS URL
  static String getAccessTokenUrl = "${ndhmDev}gateway/v0.5/sessions";

  ///USER PROFILE URL
  static String getUserDetailsAPI = "${ndhmDev}cm/v1/apps/profile/me";

  ///EUA SAVE USER URL
  static String saveUserDataToEUA = "${uhiEua}user/saveUser";

  ///EUA USER PROFILE URL
  static String getUserDataFromEUA = "${uhiEua}user/getUser";

  ///STATE LIST URL
  static String getStateListUrl = "${ndhmDev}cm/states";

  ///DISTRICT LIST URL
  static String getDistrictListUrl = "${ndhmDev}cm/";
}
