import 'package:easy_localization/easy_localization.dart';

class AppStrings {

  static String getProfilePhoto({required String? gender}) {
    String photo = maleDoctorImage;

    if(gender != null) {
      if (gender == 'M') {
        photo = maleDoctorImage;
      } else if (gender == 'F') {
        photo = femaleDoctorImage;
      }
    }

    return photo;
  }

  static String femaleDoctorImage = 'https://www.bangkokpattayahospital.com/doctors/pic_profile/noimages_female.jpg';
  static String maleDoctorImage = 'https://www.kindpng.com/picc/m/198-1985282_doctor-profile-icon-png-transparent-png.png';
  static String rupeeSymbol = 'rupeeSymbol'.tr();

  ///SPLASH SCREEN
  String welcomeToText = "welcomeToText".tr();

  ///USER ROLE SCREEN
  String roleAppBarTitle = 'roleAppBarTitle'.tr();
  String doctor = 'doctor'.tr();
  String therapist = 'therapist'.tr();
  String psychologist = 'psychologist'.tr();
  String others = 'others'.tr();

  /// MOBILE NUMBER AUTH SCREEN
  String mobileNumberAuthAppBarTitle = 'mobileNumberAuthAppBarTitle'.tr();
  String providerAuthAppBarTitle = 'providerAuthAppBarTitle'.tr();
  String enterMobileNumberLabel = 'enterMobileNumberLabel'.tr();
  String enterHprAddressLabel = 'enterHprAddressLabel'.tr();
  String willSedOTPLabel = 'willSedOTPLabel'.tr();
  String labelMobileNumber = 'labelMobileNumber'.tr();
  String dontHaveHPIDLabel = 'dontHaveHPIDLabel'.tr();

  /// OTP AUTH SCREEN
  String otpAuthAppBarTitle = 'otpAuthAppBarTitle'.tr();
  String otpAuthLabel = 'otpAuthLabel'.tr();
  String enterOtpLabel = 'enterOtpLabel'.tr();
  String dontReceiveOTPLabel = 'dontReceiveOTPLabel'.tr();
  String invalidOTP = 'invalidOTP'.tr();
  String invalidAadhaar = 'invalidAadhaar'.tr();
  String invalidMobile = 'invalidMobile'.tr();


  /// PROFILE SCREEN
  String profileAppBarTitle = 'profileAppBarTitle'.tr();
  String labelHPRProfile = 'labelHPRProfile'.tr();
  String labelDepartment = 'labelDepartment'.tr();
  String labelType = 'labelType'.tr();
  String labelExperience  = 'labelExperience'.tr();
  String labelEducation   = 'labelEducation'.tr();
  String labelLanguages   = 'labelLanguages'.tr();
  String labelHPRAddress   = 'labelHPRAddress'.tr();
  String labelHPRId   = 'labelHPRId'.tr();
  String labelMoveNext   = 'labelMoveNext'.tr();
  String editProfileAppBarTitle = 'editProfileAppBarTitle'.tr();
  String labelServicesOffered = 'labelServicesOffered'.tr();
  String labelYears = 'labelYears'.tr();
  String labelAlertStopConsultation({required consultType}) => 'labelAlertStopConsultation'.tr(args: [consultType]);
  String alertNote({required consultType}) => 'alertNote'.tr(args: [consultType]);

  /// PROFILE SCREEN
  String profileNotFoundAppBarTitle = 'profileNotFoundAppBarTitle'.tr();
  String profileNotFound = 'profileNotFound'.tr();

  /// SIGNUP SCREEN
  String signUpAppBarTitle = 'signUpAppBarTitle'.tr();
  String labelGenerateHPRId = 'labelGenerateHPRId'.tr();
  String labelOr = 'labelOr'.tr();

  /// SIGNUP WITH AADHAAR SCREEN
  String signUpWithAadhaarAppBarTitle = 'signUpWithAadhaarAppBarTitle'.tr();
  String labelSendOtpToLinkedNumber = 'labelSendOtpToLinkedNumber'.tr();
  String labelAadhaarNoVirtualOd = 'labelAadhaarNoVirtualOd'.tr();
  String labelAadhaarTermsCondition = 'labelAadhaarTermsCondition'.tr();
  String labelTermsCondition = 'labelTermsCondition'.tr();

  /// AADHAAR OTP AUTH SCREEN
  String labelEnterAadhaarOtp = 'labelEnterAadhaarOtp'.tr();

  /// SETUP SERVICES SCREEN
  String setUpServicesAppBarTitle = 'setUpServicesAppBarTitle'.tr();
  String labelSelectServices = 'labelSelectServices'.tr();
  String labelCanSelectMultipleServices = 'labelCanSelectMultipleServices'.tr();
  String labelTeleconsultation = 'labelTeleconsultation'.tr();
  String labelPhysicalConsultationNewLine = 'labelPhysicalConsultationNewLine'.tr();
  String labelPhysicalConsultation = 'labelPhysicalConsultation'.tr();
  String labelBoth = 'labelBoth'.tr();

  /// DAYS AND TIME SELECTION SCREEN
  String labelChooseDaysAndTime = 'labelChooseDaysAndTime'.tr();
  String labelChooseDatesAndTime = 'labelChooseDatesAndTime'.tr();
  String labelStartTime = 'labelStartTime'.tr();
  String labelEndTime = 'labelEndTime'.tr();
  String labelTimeInMin = 'labelTimeInMin'.tr();
  String labelFixed = 'labelFixed'.tr();
  String labelExcludeWeekends = 'labelExcludeWeekends'.tr();
  String labelFixedDurationSlot = 'labelFixedDurationSlot'.tr();

  /// SETUP FEES SCREEN
  String labelMentionFees = 'labelMentionFees'.tr();
  String labelFirstConsultation = 'labelFirstConsultation'.tr(args: [rupeeSymbol]);
  String labelFollowUp = 'labelFollowUp'.tr(args: [rupeeSymbol]);
  String labelLabReportConsultation = 'labelLabReportConsultation'.tr(args: [rupeeSymbol]);

  /// ADD UPI SCREEN
  String labelProvideUpiId = 'labelProvideUpiId'.tr();
  String labelUpiId = 'labelUpiId'.tr();
  String labelPaymentBeforeConsultation = 'labelPaymentBeforeConsultation'.tr();
  String labelPaymentAfterConsultation = 'labelPaymentAfterConsultation'.tr();
  String labelPaymentWithinWeek = 'labelPaymentWithinWeek'.tr();

  /// ADD UPLOAD PHOTO SCREEN
  String labelAddPhoto = 'labelAddPhoto'.tr();
  String labelSignatureUsage = 'labelSignatureUsage'.tr();

  /// DASHBOARD SCREEN
  String labelHelpAndSupport = 'labelHelpAndSupport'.tr();
  String labelRateUs = 'labelRateUs'.tr();
  String labelNotificationSettings = 'labelNotificationSettings'.tr();
  String labelTermsOfUsePolicy = 'labelTermsOfUsePolicy'.tr();
  String labelLogout = 'labelLogout'.tr();

  /// CONSULTATION DETAILS SCREEN
  String labelAccountStatement = 'labelAccountStatement'.tr();
  String labelAppointments = 'labelAppointments'.tr();

  /// UPDATE CONSULTATION DETAILS SCREEN
  String labelEditAvailability = 'labelEditAvailability'.tr();
  String labelEditFees = 'labelEditFees'.tr();
  String labelEditPayments = 'labelEditPayments'.tr();

  /// NOTIFICATION SETTINGS SCREEN
  String labelNewAppointments = 'labelNewAppointments'.tr();
  String labelRescheduledAppointments = 'labelRescheduledAppointments'.tr();
  String labelCancelledAppointments  = 'labelCancelledAppointments'.tr();
  String labelChats = 'labelChats'.tr();
  String labelPayments = 'labelPayments'.tr();
  String labelRatingsAndFeedback = 'labelRatingsAndFeedback'.tr();

  /// APPOINTMENTS SCREEN
  String labelNew = 'labelNew'.tr();
  String labelToday = 'labelToday'.tr();
  String labelUpcoming = 'labelUpcoming'.tr();
  String labelPrevious = 'labelPrevious'.tr();
  String labelViewDetails = 'labelViewDetails'.tr();
  String labelCancel = 'labelCancel'.tr();
  String labelReschedule = 'labelReschedule'.tr();
  String labelRequestReschedule = 'labelRequestReschedule'.tr();
  String labelStatus = 'labelStatus'.tr();
  String labelOriginalAppointment = 'labelOriginalAppointment'.tr();
  String labelRescheduledAppointment = 'labelRescheduledAppointment'.tr();

  /// RESCHEDULE APPOINTMENT SCREEN
  String labelRequestingReschedule = 'labelRequestingReschedule'.tr();
  String labelSelectAlternateSlot = 'labelSelectAlternateSlot'.tr();
  String labelChooseTimeSlot = 'labelChooseTimeSlot'.tr();
  String labelRescheduleAlertTitle = 'labelRescheduleAlertTitle'.tr();
  String labelRescheduleAlertDescription = 'labelRescheduleAlertDescription'.tr();

  /// CANCEL APPOINTMENT SCREEN
  String labelCancellation = 'labelCancellation'.tr();
  String labelCancellingAppointment = 'labelCancellingAppointment'.tr();
  String labelAppointmentDetails = 'labelAppointmentDetails'.tr();
  String labelSendMessage = 'labelSendMessage'.tr();
  String labelCancelAlertTitle = 'labelCancelAlertTitle'.tr();

  /// VIEW APPOINTMENT DETAILS SCREEN
  String labelAppointmentUpdates = 'labelAppointmentUpdates'.tr();


  String labelEnterBookingIdTitle = 'labelEnterBookingIdTitle'.tr();
  String labelEnterPatientId = 'labelEnterPatientId'.tr();

  /// CONSULTATION COMPETED SCREEN
  String labelPhysicalConsultationAppointment = 'labelPhysicalConsultationAppointment'.tr();
  String labelTeleconsultationAppointment = 'labelTeleconsultationAppointment'.tr();
  String labelConsultationCompleted = 'labelConsultationCompleted'.tr();
  String labelPhysicalConsultationCompleted = 'labelPhysicalConsultationCompleted'.tr();
  String labelTeleconsultationCompleted = 'labelTeleconsultationCompleted'.tr();

  /// SHARE PRESCRIPTION SCREEN
  String labelSharePrescription = 'labelSharePrescription'.tr();
  String labelSharePrescriptionHead = 'labelSharePrescriptionHead'.tr();
  String labelEnsurePrescriptionHasSignature = 'labelEnsurePrescriptionHasSignature'.tr();

  /// REGISTER PROVIDER SCREEN
  String titleRegisterProvider = 'titleRegisterProvider'.tr();
  String labelName = 'labelName'.tr();
  String labelFirstName = 'labelFirstName'.tr();
  String labelLastName = 'labelLastName'.tr();
  String labelHprAddress = 'labelHprAddress'.tr();
  String labelAge = 'labelAge'.tr();
  String labelSpeciality = 'labelSpeciality'.tr();
  String labelEducationWithHint = 'labelEducationWithHint'.tr();
  String labelLanguagesWithHint = 'labelLanguagesWithHint'.tr();
  String labelSelectGender = 'labelSelectGender'.tr();
  String labelMale = 'labelMale'.tr();
  String labelFemale = 'labelFemale'.tr();

  String errorEnterName = 'errorEnterName'.tr();
  String errorEnterFirstName = 'errorEnterFirstName'.tr();
  String errorEnterLastName = 'errorEnterLastName'.tr();
  String errorEnterHprAddress = 'errorEnterHprAddress'.tr();
  String errorInvalidHprAddress = 'errorInvalidHprAddress'.tr();
  String errorEnterHprId = 'errorEnterHprId'.tr();
  String errorInvalidHprId = 'errorInvalidHprId'.tr();
  String errorEnterEducation = 'errorEnterEducation'.tr();
  String errorEnterSpeciality = 'errorEnterSpeciality'.tr();
  String errorEnterLanguagesKnown = 'errorEnterLanguagesKnown'.tr();
  String errorSelectGender = 'errorSelectGender'.tr();

  /// WAITING ROOM SCREEN
  String labelWaitingRoom = 'labelWaitingRoom'.tr();
  String labelIncomingCall = 'labelIncomingCall'.tr();
  String labelPatientWantsToConnect = 'labelPatientWantsToConnect'.tr();
  String labelConnecting = 'labelConnecting'.tr();
  String labelWaitWhileConnectCall = 'labelWaitWhileConnectCall'.tr();

  /// ERROR STRINGS
  String errorProvideServiceType = 'errorProvideServiceType'.tr();
  String errorProvideFees = 'errorProvideFees'.tr();
  String errorProvideProperFees = 'errorProvideProperFees'.tr();
  String errorProvideNonZeroFees = 'errorProvideNonZeroFees'.tr();
  String errorProvideUpi = 'errorProvideUpi'.tr();
  String errorProvideValidUpi = 'errorProvideValidUpi'.tr();
  String errorProvideAge = 'errorProvideAge'.tr();
  String errorProvideValidAge = 'errorProvideValidAge'.tr();
  String errorProvideNonZeroAge = 'errorProvideNonZeroAge'.tr();
  String errorProvideExperience = 'errorProvideExperience'.tr();
  String errorProvideValidExperience = 'errorProvideValidExperience'.tr();
  String errorProvideNonZeroExperience = 'errorProvideNonZeroExperience'.tr();
  String errorProvideCancelReason = 'errorProvideCancelReason'.tr();
  String errorNoTodayAppointments = 'errorNoTodayAppointments'.tr();
  String errorNoPreviousAppointments = 'errorNoPreviousAppointments'.tr();
  String errorNoUpcomingAppointments = 'errorNoUpcomingAppointments'.tr();
  String errorNoSlotsAvailable = 'errorNoSlotsAvailable'.tr();
  String errorSelectImage = 'errorSelectImage'.tr();
  String errorProviderUUIDNotFound = 'errorProviderUUIDNotFound'.tr();
  String errorInvalidDateRange = 'errorInvalidDateRange'.tr();
  String errorSelectStartTime = 'errorSelectStartTime'.tr();
  String errorSelectEndTime = 'errorSelectEndTime'.tr();
  String errorInvalidTimeRange = 'errorInvalidTimeRange'.tr();
  String errorInvalidStartTimeRange = 'errorInvalidStartTimeRange'.tr();
  String errorNoSlotsAvailableAsExcludeWeenEnds = 'errorNoSlotsAvailableAsExcludeWeenEnds'.tr();
  String errorEnterTimeInMinutes = 'errorEnterTimeInMinutes'.tr();
  String errorEnterValidTime = 'errorEnterValidTime'.tr();
  String errorEnterNonZeroTime = 'errorEnterNonZeroTime'.tr();
  String errorEnterValidTimeRange(int difference) => 'errorEnterValidTimeRange'.tr(args: [difference.toString()]);

  /// BUTTON
  String btnLogin = 'btnLogin'.tr();
  String btnContinue = 'btnContinue'.tr();
  String btnReset = 'btnReset'.tr();
  String btnCancel = 'btnCancel'.tr();
  String btnRegister = 'btnRegister'.tr();
  String btnResend = 'btnResend'.tr();
  String btnDelete = 'btnDelete'.tr();
  String btnNext = 'btnNext'.tr();
  String btnUseDifferentNumber = 'btnUseDifferentNumber'.tr();
  String btnSignUp = 'btnSignUp'.tr();
  String btnSubmit = 'btnSubmit'.tr();
  String btnShare = 'btnShare'.tr();
  String btnAadhaar = 'btnAadhaar'.tr();
  String btnDrivingLicense = 'btnDrivingLicense'.tr();
  String btnTakePhoto = 'btnTakePhoto'.tr();
  String btnStartConsultation = 'btnStartConsultation'.tr();
  String btnEndConsultation = 'btnEndConsultation'.tr();
  String btnSharePrescription  = 'btnSharePrescription'.tr();
  String btnReject  = 'btnReject'.tr();
  String btnAccept  = 'btnAccept'.tr();

  ///DIALOG
  String yes = 'yes'.tr();
  String no = 'no'.tr();
  String cancel = 'cancel'.tr();
  String confirm = 'confirm'.tr();
  String close = 'close'.tr();
  String startConsultation = 'startConsultation'.tr();
  String error = 'error'.tr();
  String somethingWentWrong = 'somethingWentWrong'.tr();
  String loading = 'loading'.tr();
  String comingSoon = 'comingSoon'.tr();
  String alert = 'alert'.tr();
  String camera = 'camera'.tr();
  String gallery = 'gallery'.tr();

  String appointmentSlotsCreated = 'appointmentSlotsCreated'.tr();
  String errorEnterMobileNumber = 'errorEnterMobileNumber'.tr();
  String errorEnterOTP = 'errorEnterOTP'.tr();
  String errorUnableToFetchAuthToken = 'errorUnableToFetchAuthToken'.tr();
  String labelSelectLanguage = 'labelSelectLanguage'.tr();
  String labelChangeLanguage = 'labelChangeLanguage'.tr();
  String labelEnglish = 'labelEnglish'.tr();
  String labelHindi = 'labelHindi'.tr();
  String noDataAvailable = 'noDataAvailable'.tr();
  String loadingData = 'loadingData'.tr();
  String titleCompleteProfile = 'titleCompleteProfile'.tr();
  String btnSaveProfile = 'btnSaveProfile'.tr();
  String titleSelectHprId = 'titleSelectHprId'.tr();
  String labelSelectHprId = 'labelSelectHprId'.tr();
  String errorInvalidExperience = 'errorInvalidExperience'.tr();
  String errorNoHprLinkedToMobile = 'errorNoHprLinkedToMobile'.tr();
  String btnSend = 'btnSend'.tr();
  String labelAuthenticating = 'labelAuthenticating'.tr();
  String labelLocalAuthentication = 'labelLocalAuthentication'.tr();
  String labelSettings = 'labelSettings'.tr();
  String labelSettingsAndPreferences = 'labelSettingsAndPreferences'.tr();
  String labelSecurity = 'labelSecurity'.tr();
  String labelChosenLanguage({required String selectedLanguage}) => 'labelChosenLanguage'.tr(args: [selectedLanguage]);
  String errorUnableSelectMedia = 'errorUnableSelectMedia'.tr();
  String accountStatement = 'accountStatement'.tr();
  String errorNoAccountStatements = 'errorNoAccountStatements'.tr();
  String paymentReceived = 'paymentReceived'.tr();
  String paymentPending = 'paymentPending'.tr();
  String errorExperienceShouldLessThanAge = 'errorExperienceShouldLessThanAge'.tr();
  String errorEnterValidName = 'errorEnterValidName'.tr();
  String noteAlreadyAddedSlotsDiscarded = 'noteAlreadyAddedSlotsDiscarded'.tr();
  String errorEnterValidEducation = 'errorEnterValidEducation'.tr();
  String errorEnterValidSpeciality = 'errorEnterValidSpeciality'.tr();
  String errorEnterValidLanguages = 'errorEnterValidLanguages'.tr();
  String errorNameShouldStartWithCharactersOnly = 'errorNameShouldStartWithCharactersOnly'.tr();
  String errorShouldContainSingleSpaceBetweenName = 'errorShouldContainSingleSpaceBetweenName'.tr();
  String errorShouldNotContainSpace = 'errorShouldNotContainSpace'.tr();
  String errorShouldStartWithCharactersOnly({required String type}) => 'errorShouldStartWithCharactersOnly'.tr(args: [type]);
  String errorRemoveCommaAtLast = 'errorRemoveCommaAtLast'.tr();
  String labelLoginForFirstTime = 'labelLoginForFirstTime'.tr();
  String labelSchedule = 'labelSchedule'.tr();
  String btnOk = 'btnOk'.tr();
  String labelSearchLanguage = 'labelSearchLanguage'.tr();
  String labelSelectQualification = 'labelSelectQualification'.tr();
  String labelSearchQualification = 'labelSearchQualification'.tr();
  String labelSelectSpeciality = 'labelSelectSpeciality'.tr();
  String labelSearchSpeciality = 'labelSearchSpeciality'.tr();
  String slotDuration({required String value}) => 'slotDuration'.tr(args: [value]);
  String labelNotBooked = 'labelNotBooked'.tr();
  String labelBooked = 'labelBooked'.tr();
  String errorEnterValidMobile = 'errorEnterValidMobile'.tr();
  String labelDocument = 'labelDocument'.tr();
  String messageConsultationCompleted = 'messageConsultationCompleted'.tr();
  String btnProceed = 'btnProceed'.tr();
  String tooltipFilterUpcoming = 'tooltipFilterUpcoming'.tr();
  String tooltipFilterPrevious = 'tooltipFilterPrevious'.tr();
  String errorMinimumSlotDuration = 'errorMinimumSlotDuration'.tr();
  String errorNotMatchedMinimumTimeRange = 'errorNotMatchedMinimumTimeRange'.tr();
  String titleProminentDisclosure = 'titleProminentDisclosure'.tr();
  String descProminentDisclosure = 'descProminentDisclosure'.tr();
  String btnDecline = 'btnDecline'.tr();
  String descCamera = 'descCamera'.tr();
  String labelMicrophone = 'labelMicrophone'.tr();
  String descMicrophone = 'descMicrophone'.tr();
  String labelStorage = 'labelStorage'.tr();
  String descStorage = 'descStorage'.tr();
  String labelSMS = 'labelSMS'.tr();
  String descSMS = 'descSMS'.tr();
  String labelSharingOfData = 'labelSharingOfData'.tr();
  String descSharingOfData = 'descSharingOfData'.tr();

  /// Service types strings to be passed in API calls
  static String teleconsultation = 'Teleconsultation';
  static String physicalConsultation = 'PhysicalConsultation';

  /// Preferences
  static String chatUserName = 'chat_user_name';
  static String doctorProfile = 'doctor_profile';
  static String accessToken = 'access_token';
  static String isLocalAuth = 'is_local_auth';
  static const String encryptionPrivateKey = 'encryptionPrivateKey';
  static String isProminentDisclosureAgreed = 'is_prominent_disclosure_agrees';

  static List<String> educations = <String>[
    'MBBS',
    'BDS',
    'BAMS',
    'BHMS',
    'BUMS',
    'BYNS',
    'MD',
    'MS',
    'DNB',
    'M.Ch'
  ];

  static List<String> specialities = <String>[
    'MD - Anaesthesiology',
    'MD - Biochemistry',
    'MD - Community Health',
    'MD - Dermatology',
    'MD - Family Medicine',
    'MD - Forensic Medicine',
    'MD - General Medicine',
    'Microbiology - Microbiology',
    'MD - Paediatrics',
    'MD - Palliative Medicine',
    'MD - Pathology',
    'MD - Skin and Venereal diseases',
    'MD - Pharmacology',
    'MD - Physical Medicine and Rehabilitation',
    'MD - Physiology',
    'MD - Preventive and Social Medicine',
    'MD - Psychiatry',
    'MD - Radio-Diagnosis',
    'MD - Radio-Therapy',
    'MD - Tuberculosis and Respiratory diseases',
    'MD - Emergency and Critical care',
    'MD - Nuclear Medicine',
    'MD - Transfusion Medicine',
    'MD - Tropical Medicine',
    'MS - Ear, Nose and Throat',
    'MS - General Surgery',
    'MS - Ophthalmology',
    'MS - Orthopaedics',
    'MS - Obstetrics and Gynaecology',
    'MS - Dermatology, Venerology and Leprosy',
    'DNB - Anaesthesiology',
    'DNB - Anatomy',
    'DNB - Biochemistry',
    'DNB - Dermatology',
    'DNB - Emergency Medicine',
    'DNB - Family Medicine',
    'DNB - Field Epidemiology',
    'DNB - Forensic Medicine',
    'DNB - General Medicine',
    'DNB - General Surgery',
    'DNB - Health Administration',
    'DNB - Ophthalmology',
    'DNB - Psychiatry',
    'DNB - Radio-Diagnosis',
    'DNB - Radio-Therapy',
    'DNB - Orthopaedic Surgery',
    'DNB - Oto-Rhino Laryngology',
    'DNB - Paediatrics',
    'DNB - Pathology',
    'DNB - Pharmacology',
    'DNB - Physical Medicine and Rehabilitation',
    'DNB - Physiology',
    'DNB - Immunohematology and transfusion medicine',
    'DNB - Maternal and Child Health',
    'DNB - Nuclear Medicine',
    'DNB - Obstetric and Gynecology',
    'DNB - Respiratory diseases',
    'DNB - Rural Surgery',
    'DNB - Social and Preventive Medicine',
    'D.M. - Psychiatry',
    'D.M. - Cardiac-Anaesthesiology',
    'D.M. - Cardiology',
    'D.M. - Haematology',
    'D.M. - Pharmacology',
    'D.M. - Anaesthesiology, Pain Medicine and Critical Care',
    'D.M. - Endocrinology',
    'D.M. - Gastroenterology',
    'D.M. - Medicine and Microbiology',
    'D.M. - Onco-Anesthesiology and Palliative Medicine',
    'D.M. - Cardiology',
    'D.M. - Pulmonary and Sleep disorders',
    'D.M. - Obstetrics and Gynecology',
    'D.M. - Nuclear Medicine',
    'D.M. - Cardiac-Radiology',
    'D.M. - Paediatrics',
    'D.M. - Nephrology',
    'D.M. - Neuro-Anaesthesiology and Critical Care',
    'D.M. - Neurology',
    'M.Ch - Surgery',
    'M.Ch - Cardiothoracic and Vascular Surgery',
    'M.Ch - Gastrointestinal Surgery',
    'M.Ch - Obstetrics and Gynaecology',
    'M.Ch - ENT',
    'M.Ch - Neuro Surgery',
    'M.Ch - Pediatric Surgery',
    'M.Ch - Plastic and Reconstructive Surgery',
    'M.Ch - Surgical Oncology',
    'M.Ch - Surgery Trauma Centre',
    'M.Ch - Urology',
  ];
}
