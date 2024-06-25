package in.gov.abdm.uhi.hspa.utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.models.*;
import in.gov.abdm.uhi.hspa.models.opemMRSModels.*;
import reactor.core.publisher.Mono;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.Period;
import java.util.*;
import java.util.concurrent.atomic.AtomicReference;
import java.util.function.Predicate;

public class IntermediateBuilderUtils {

    private static final Logger LOGGER = LogManager.getLogger(IntermediateBuilderUtils.class);
    private static final String IDENTIFIER_TYPE = "7f820ce9-e6cb-4242-9aa3-1faaf8ad116e"; //ABHA
    private static final String IDENTIFIER_LOCATION = "58c57d25-8d39-41ab-8422-108a0c277d98"; //Outpatient

    private static final String DATE_TIME_PATTERN = ConstantsUtils.DATE_FORMAT;

    
    public static IntermediateAppointmentModel BuildAppointmenttype(String json,String type) {
        IntermediateAppointmentModel intermediateAppModel = new IntermediateAppointmentModel();
   	 try {
		 ObjectMapper maps = new ObjectMapper();
		JsonNode root = maps.readTree(json);
		 JsonNode resultsNode = root.path(ConstantsUtils.RESULTS);
		 
            if (resultsNode.isArray()) {


                for (JsonNode node : resultsNode) {
                	String uuid=node.path("uuid").asText();
                    LOGGER.info("BEZAWADAA "+uuid);
                	String name = node.path(ConstantsUtils.DISPLAY).asText();
                	if(name.equalsIgnoreCase(type))
                		{
                            intermediateAppModel.setAppointmentTypeDisplay(name);
                            intermediateAppModel.setAppointmentTypeUUID(uuid);
                		}

                	}
                }
	} catch (Exception ex) {
		LOGGER.error("Intermediate Builder::BuildIntermediateObj ::error::onErrorResume:: {}", ex, ex);
	}
        return intermediateAppModel;
    	
    }
    
    
    
    
    public static List<IntermediateProviderModel> BuildIntermediateObj(String json) {
        List<IntermediateProviderModel> collection = new ArrayList<>();

        try {
            ObjectMapper maps = new ObjectMapper();
            JsonNode root = maps.readTree(json);

            JsonNode resultsNode = root.path(ConstantsUtils.RESULTS);
            if (resultsNode.isArray()) {


                for (JsonNode node : resultsNode) {

                    IntermediateProviderModel objIntermediate = new IntermediateProviderModel();
                    JsonNode person = node.path(ConstantsUtils.PERSON);
                    String name = person.path(ConstantsUtils.DISPLAY).asText();
                    String hprId = node.path(ConstantsUtils.HPR_ID).asText();
                    String id = node.path(ConstantsUtils.IDENTIFIER).asText();
                    String uuid=node.path("uuid").asText();
                    objIntermediate.setUuid(uuid);
                    objIntermediate.setName(name);
                    objIntermediate.setHpr_id(hprId);
                    objIntermediate.setId(id);


                    String gender = person.path(ConstantsUtils.GENDER).asText();
                    String age = person.path("age").asText();
                    objIntermediate.setGender(gender);
                    objIntermediate.setAge(age);

                    objIntermediate.setEducation("");
                    objIntermediate.setExpr("");
                    objIntermediate.setFirst_consultation("");
                    objIntermediate.setFirst_consultation("");
                    objIntermediate.setFollow_up("");
                    objIntermediate.setHpr_id("");
                    objIntermediate.setLab_consultation("");
                    objIntermediate.setLanguages("");
                    objIntermediate.setReceive_payment("");
                    objIntermediate.setSpeciality("");
                    objIntermediate.setUpi_id("");
                    objIntermediate.setIs_teleconsultation("");
                    objIntermediate.setIs_physical_consultation("");

                    JsonNode attributes = node.path("attributes");

                    if (attributes.isArray()) {
                        for (JsonNode attrib : attributes) {
                            JsonNode attribVal = attrib.path("attributeType");
                            String attrKey = attribVal.path(ConstantsUtils.DISPLAY).asText();
                            String attrVal = attrib.path("value").asText();


                            switch (attrKey) {
                                case ConstantsUtils.EDUCATION -> objIntermediate.setEducation(attrVal);
                                case ConstantsUtils.EXPERIENCE -> objIntermediate.setExpr(attrVal);
                                case ConstantsUtils.CHARGES -> objIntermediate.setFirst_consultation(attrVal);
                                case ConstantsUtils.FIRST_CONSULTATION ->
                                        objIntermediate.setFirst_consultation(attrVal);
                                case ConstantsUtils.FOLLOW_UP -> objIntermediate.setFollow_up(attrVal);
                                case ConstantsUtils.HPR_ID -> objIntermediate.setHpr_id(attrVal);
                                case ConstantsUtils.LAB_REPORT_CONSULTATION ->
                                        objIntermediate.setLab_consultation(attrVal);
                                case ConstantsUtils.LANGUAGES -> objIntermediate.setLanguages(attrVal);
                                case ConstantsUtils.RECEIVE_PAYMENT -> objIntermediate.setReceive_payment(attrVal);
                                case ConstantsUtils.PARENT_CATEGORY -> objIntermediate.setParent_category(attrVal);
                                case ConstantsUtils.PARENT_CATEGORY_ID ->
                                        objIntermediate.setParent_category_id(attrVal);
                                case ConstantsUtils.CATEGORY_ID -> objIntermediate.setCategory_id(attrVal);
                                case ConstantsUtils.SPECIALITY -> objIntermediate.setSpeciality(attrVal);
                                case ConstantsUtils.UPI_ID -> objIntermediate.setUpi_id(attrVal);
                                case ConstantsUtils.IS_TELECONSULTATION ->
                                        objIntermediate.setIs_teleconsultation(attrVal);
                                case ConstantsUtils.IS_PHYSICAL_CONSULTATION ->
                                        objIntermediate.setIs_physical_consultation(attrVal);
                                case ConstantsUtils.PROFILE_PHOTO -> objIntermediate.setProfile_photo(attrVal);
                                default -> LOGGER.error(ConstantsUtils.UNSPECIFIED_CASE + " " + attrVal);
                            }
                        }
                    }
                    collection.add(objIntermediate);
                }
            }
        } catch (Exception ex) {

            LOGGER.error("Intermediate Builder::BuildIntermediateObj ::error::onErrorResume:: {}", ex, ex);
        }
        return collection;
    }

    public static List<IntermediateProviderAppointmentModel> BuildIntermediateProviderAppoitmentObj(String json) {
        List<IntermediateProviderAppointmentModel> collection = new ArrayList<>();

        try {
            ObjectMapper maps = new ObjectMapper();
            JsonNode root = maps.readTree(json);

            JsonNode resultsNode = root.path(ConstantsUtils.RESULTS);       
            if (resultsNode.isArray()) {


                for (JsonNode node : resultsNode) {

                    IntermediateProviderAppointmentModel objIntermediate = new IntermediateProviderAppointmentModel();

                    JsonNode appointmentBlock = node.path("appointmentBlock");                  
                    JsonNode provider = appointmentBlock.path("provider");
                    JsonNode person = provider.path(ConstantsUtils.PERSON);                   
                    String slotId = node.path("uuid").asText();
                    String name = person.path(ConstantsUtils.DISPLAY).asText();
                    String hprId = provider.path(ConstantsUtils.IDENTIFIER).asText();
                    String id = provider.path("uuid").asText();
                    int countOfAppointments = node.path("countOfAppointments").asInt();
                    String startDate = node.path("startDate").asText();
                    String endDate = node.path("endDate").asText();


                    if (appointmentSlotIsAlreadyBooked(slotId, countOfAppointments, startDate, endDate)) continue;

                    objIntermediate.setName(name);
                    objIntermediate.setHpr_id(hprId);
                    objIntermediate.setId(id);
                    objIntermediate.setSlotId(slotId);

                    String gender = person.path(ConstantsUtils.GENDER).asText();
                    String age = person.path("age").asText();
                    objIntermediate.setGender(gender);
                    objIntermediate.setAge(age);


                    JsonNode attributes = provider.path("attributes");                    
                    if (attributes.isArray()) {
                        for (JsonNode attrib : attributes) {                        	 
                            JsonNode attribVal = attrib.path("attributeType");
                            String attrKey = attribVal.path(ConstantsUtils.DISPLAY).asText();
                            String attrVal = attrib.path("value").asText();                           
                            switch (attrKey) {
                                case "education" -> objIntermediate.setEducation(attrVal);
                                case "experience" -> objIntermediate.setExpr(attrVal);
                                case "languages" -> objIntermediate.setLanguages(attrVal);
                                case "hpr_id" -> objIntermediate.setCharges(attrVal);
                                case "speciality" -> objIntermediate.setSpeciality(attrVal);
                            }
                        }
                    }

                    String start = node.path("startDate").asText();
                    String end = node.path("endDate").asText();

                    SimpleDateFormat simpleDateFormat = new SimpleDateFormat(DATE_TIME_PATTERN);

                    Date startDateTime = simpleDateFormat.parse(start);
                    Date endDateTime = simpleDateFormat.parse(end);

                    objIntermediate.startDateTime = simpleDateFormat.format(startDateTime);
                    objIntermediate.endDateTime = simpleDateFormat.format(endDateTime);             
                    
                 
                    collection.add(objIntermediate);
                } // end outer for
            }
        } catch (Exception ex) {
            LOGGER.error("Intermediate Builder :: BuildIntermediateProviderAppoitmentObj :: error::onErrorResume:: {}", ex, ex);
        }
        return collection;
    }



    public static Boolean BuildIntermediateProviderObj(String json) {
        List<IntermediateProviderModel> collection = new ArrayList<>();

        try {
            ObjectMapper maps = new ObjectMapper();
            JsonNode root = maps.readTree(json);

            JsonNode resultsNode = root.path(ConstantsUtils.RESULTS);
            if (resultsNode.isArray()) {


                for (JsonNode node : resultsNode) {

                    IntermediateProviderModel objIntermediate = new IntermediateProviderModel();

                    JsonNode appointmentBlock = node.path("appointmentBlock");
                    JsonNode provider = appointmentBlock.path("provider");
                    JsonNode person = provider.path(ConstantsUtils.PERSON);

                    String slotId = node.path("uuid").asText();
                    String name = person.path(ConstantsUtils.DISPLAY).asText();
                    String hprId = provider.path(ConstantsUtils.IDENTIFIER).asText();
                    String id = provider.path("uuid").asText();
                    int countOfAppointments = node.path("countOfAppointments").asInt();
                    return countOfAppointments > 0;

                } // end outer for
            }
        } catch (Exception ex) {
            LOGGER.error("Intermediate Builder :: BuildIntermediateProviderAppoitmentObj :: error::onErrorResume:: {}", ex, ex);
        }
        return false;
    }



    private static boolean appointmentSlotIsAlreadyBooked(String slotId, int countOfAppointments, String startDate, String endDate) {
        if (countOfAppointments > 0) {
            LOGGER.error("Appointment already booked. Skipping. Slot uuid is  ->> {}. Start date->  {} and endDate-> {}", slotId, startDate, endDate);
            return true;
        }
        return false;
    }

    public static List<IntermediatePatientAppointmentModel> BuildIntermediatePatientAppoitmentObj(String appointment, String patient, Order order) {

        List<IntermediatePatientAppointmentModel> collection = new ArrayList<>();

        try {

            ObjectMapper maps = new ObjectMapper();
            JsonNode rootPatient = maps.readTree(patient);
            JsonNode rootAppointment = maps.readTree(appointment);

            JsonNode resultPatient = rootPatient.path(ConstantsUtils.RESULTS);
            JsonNode resultAppointment = rootAppointment.path(ConstantsUtils.RESULTS);

            if (resultAppointment.isEmpty() && rootAppointment.has("uuid") && (resultPatient.isArray() && resultPatient.elements().hasNext())) {
                IntermediatePatientAppointmentModel objIntermediate = new IntermediatePatientAppointmentModel();

                JsonNode appointmentId = rootAppointment.path("uuid");
                JsonNode appointmentStatus = rootAppointment.path("status");
                JsonNode appointmentType = rootAppointment.path("appointmentType");
                JsonNode appointmentTimeSlot = rootAppointment.path("timeSlot");
                JsonNode appointmentTimeSlotId = appointmentTimeSlot.path("uuid");
                JsonNode appointmentTypeName = appointmentType.path(ConstantsUtils.DISPLAY);

                JsonNode patientNode = resultPatient.get(0).path(ConstantsUtils.PERSON);
                JsonNode patientName = patientNode.path(ConstantsUtils.DISPLAY);
                JsonNode gender = patientNode.path(ConstantsUtils.GENDER);

                objIntermediate.setAppointmentId(appointmentId.asText());
                objIntermediate.setAppointmentTypeName(appointmentTypeName.asText());
                objIntermediate.setStatus(appointmentStatus.asText());
                objIntermediate.setSlotId(appointmentTimeSlotId.asText());
                objIntermediate.setName(patientName.asText());
                objIntermediate.setGender(gender.asText());

                collection.add(objIntermediate);
                LOGGER.info("Intermediate Builder :: BuildIntermediateProviderAppoitmentObj :: patientlist::patients:: {}", resultPatient);

            } else if (resultPatient.isArray() && resultPatient.elements().hasNext()) {

                LOGGER.info("Intermediate Builder :: BuildIntermediateProviderAppoitmentObj :: patientlist::patients:: {}", resultPatient);

                for (JsonNode node : resultPatient) {

                    IntermediatePatientAppointmentModel objIntermediate = new IntermediatePatientAppointmentModel();

                    String patientId = node.path("uuid").asText();

                    if (resultAppointment.isArray()) {
                        JsonNode appointmentId = resultAppointment.get(0).path("uuid");
                        JsonNode appointmentName = resultAppointment.get(0).path("name");
                        objIntermediate.setAppointmentTypeId(appointmentId.asText());
                        objIntermediate.setAppointmentTypeName(appointmentName.asText());
                    }

                    objIntermediate.setSlotId(order.getFulfillment().getId());
                    objIntermediate.setPatientId(patientId);
                    objIntermediate.setStatus(ConstantsUtils.APPOINTMENT_STATUS_SCHEDULED);

                    collection.add(objIntermediate);
                }
            }

        } catch (Exception ex) {
            LOGGER.error("Intermediate Builder :: BuildIntermediateProviderAppoitmentObj :: error::onErrorResume:: {}", ex, ex);
        }
        return collection;
    }

    public static patient BuildPatientModel(Order order) {
        patient patient = new patient();
        try {

            //add abha
            identifier abha = new identifier();
            abha.setIdentifier(order.getCustomer().getId());
            abha.setIdentifierType(IDENTIFIER_TYPE);
            abha.setLocation(IDENTIFIER_LOCATION);
            abha.setPreferred(false);

            //add OpenMRS ID
            Date dNow = new Date();
            SimpleDateFormat ft = new SimpleDateFormat("yyMMddhhmmssMs");
            String idgenerated = ft.format(dNow);
            identifier openmrs = new identifier();
            openmrs.setIdentifier(idgenerated);
            openmrs.setIdentifierType(IDENTIFIER_TYPE);
            openmrs.setLocation(IDENTIFIER_LOCATION);
            openmrs.setPreferred(true);

            patient.identifiers = new ArrayList<>();
            patient.identifiers.add(abha);
            patient.identifiers.add(openmrs);

            name name = new name();
            name.setGivenName(order.getBilling().getName());
            name.setFamilyName("");

            person person = new person();

            Person patientPerson = order.getCustomer().getPerson();
            LocalDate dob = LocalDate.of(patientPerson.getYearOfBirth(), patientPerson.getMonthOfBirth(), patientPerson.getDayOfBirth());

            person.setAge(String.valueOf(calculateAge(dob, LocalDate.now())));
            person.setGender(patientPerson.getGender());
            person.names = new LinkedList<>();
            person.names.add(name);

            address address = new address();
            address.setCountry(order.getBilling().getAddress().getCountry());
            address.setCityVillage(order.getBilling().getAddress().getCity());
            address.setPostalCode(order.getBilling().getAddress().getAreaCode());

            person.addresses = new LinkedList<>();
            person.addresses.add(address);
            patient.setPerson(person);

        } catch (Exception ex) {
            LOGGER.error("Intermediate Builder :: BuildPatientModel :: error::onErrorResume:: {}", ex, ex);
        }
        return patient;
    }

    public static int calculateAge(LocalDate birthDate, LocalDate currentDate) {
        if ((birthDate != null) && (currentDate != null)) {
            return Period.between(birthDate, currentDate).getYears();
        } else {
            return 0;
        }
    }

    public static appointment BuildAppointmentModel(IntermediatePatientAppointmentModel appointment) {
        appointment appointmentObj = new appointment();
        try {
            appointmentObj.appointmentType = appointment.getAppointmentTypeId();
            appointmentObj.timeSlot = appointment.getSlotId();
            appointmentObj.status = appointment.getStatus();
            appointmentObj.patient = appointment.getPatientId();
            appointmentObj.visit = "7b0f5697-27e3-40c4-8bae-f4049abfb4ed";

        } catch (Exception ex) {
            LOGGER.error("Intermediate Builder :: BuildPatientModel :: error::onErrorResume:: {}", ex, ex);
        }
        return appointmentObj;
    }

    public static String getUUID(String result) {
        JsonNode resultsNode = null;
        try {
            ObjectMapper maps = new ObjectMapper();
            JsonNode root = maps.readTree(result);
            resultsNode = root.path("uuid");


        } catch (Exception ex) {
            LOGGER.error("Extracting uuid from mrs :: {}", ex, ex);
        }
        return resultsNode != null ? resultsNode.textValue() : null;
    }

    public static List<IntermediateProviderModel> BuildIntermediateProviderDetails(String json) {
        List<IntermediateProviderModel> collection = new ArrayList<>();

        try {
            ObjectMapper maps = new ObjectMapper();
            JsonNode root = maps.readTree(json);

            JsonNode resultsNode = root.path(ConstantsUtils.RESULTS);
            if (resultsNode.isArray()) {


                for (JsonNode node : resultsNode) {

                    IntermediateProviderModel objIntermediate = new IntermediateProviderModel();

                    JsonNode person = node.path(ConstantsUtils.PERSON);

                    String name = person.path(ConstantsUtils.DISPLAY).asText();
                    String hprId = node.path(ConstantsUtils.IDENTIFIER).asText();
                    String providerId = node.path("uuid").asText();
                    objIntermediate.setName(name);
                    objIntermediate.setHpr_id(hprId);
                    objIntermediate.setId(providerId);

                    collection.add(objIntermediate);
                } // end outer for
            }
        } catch (Exception ex) {
            LOGGER.error("IntermediateBuilder::BuildIntermediateProviderDetails::Request:: {}", ex, ex);
        }
        return collection;
    }

    public static IntermediatePatientModel BuildIntermediatePatient(String json) {

        IntermediatePatientModel patient = new IntermediatePatientModel();

        try {
            ObjectMapper maps = new ObjectMapper();
            JsonNode root = maps.readTree(json);
            JsonNode resultsExisitng = root.path(ConstantsUtils.RESULTS);
            JsonNode resultsNew = root.path("identifiers");

            if (resultsExisitng.isArray()) {

                for (JsonNode node : resultsExisitng) {
                    JsonNode identifiers = node.path("identifiers");
                    if (identifiers.isArray()) {
                        for (JsonNode ident : identifiers) {
                            String identifier = ident.path(ConstantsUtils.DISPLAY).asText();
                            String[] vals = identifier.split("=");
                            if (Objects.equals(vals[0], "OpenMRS ID")) {
                                patient.setId(vals[1]);
                            } else {
                                patient.setAbha(vals[1]);
                            }
                        }
                    }
                    JsonNode person = node.path(ConstantsUtils.PERSON);
                    String name = person.path(ConstantsUtils.DISPLAY).asText();
                    String gender = person.path(ConstantsUtils.GENDER).asText();
                    String age = person.path("age").asText();
                    JsonNode address = person.path("preferredAddress");
                    String add = address.path(ConstantsUtils.DISPLAY).asText();

                    patient.setAddress(add);
                    patient.setName(name);
                    patient.setGender(gender);
                    patient.setAge(age);


                }

            }
            if (resultsNew.isArray()) {
                for (JsonNode node : resultsNew) {
                    String identifier = node.path(ConstantsUtils.DISPLAY).asText();
                    String[] vals = identifier.split("=");
                    if (Objects.equals(vals[0], "OpenMRS ID")) {
                        patient.setId(vals[1]);
                    } else {
                        patient.setAbha(vals[1]);
                    }
                }
                JsonNode person = root.path(ConstantsUtils.PERSON);
                String name = person.path(ConstantsUtils.DISPLAY).asText();
                String gender = person.path(ConstantsUtils.GENDER).asText();
                String age = person.path("age").asText();
                JsonNode address = person.path("preferredAddress");
                String add = address.path(ConstantsUtils.DISPLAY).asText();

                patient.setAddress(add);
                patient.setName(name);
                patient.setGender(gender);
                patient.setAge(age);


            } // end outer for
        } catch (Exception ex) {
            LOGGER.error("Intermediate Builder :: BuildIntermediatePatient :: error::onErrorResume:: {}", ex, ex);

        }
        return patient;
    }

    public static Map<String, String> BuildSearchParametersIntent(Request request, boolean isSecondSearch) {
        String messageId = request.getContext().getMessageId();
        Map<String, String> listOfParams = new HashMap<>();

        Optional<Intent> intent = Optional.ofNullable(request.getMessage().getIntent());
        Optional<Order> order = Optional.ofNullable(request.getMessage().getOrder());
        Optional<Provider> provider = Optional.ofNullable(request.getMessage().getIntent().getProvider());

        String valueName = null;
        String valueHPRID = null;
        String valueType = null;
        Optional<Start> valueStart;
        Optional<End> valueEnd;
        Map<String, String> valueTags;
        Map<String, String> specialityTags = null;
        String specialitySearch = null;
        Set<Category> categories = null;
        if (intent.isPresent()) {
            try {
                SimpleDateFormat simpleDateFormat = new SimpleDateFormat(DATE_TIME_PATTERN);
                if (provider.isPresent() && isSecondSearch) {
                    if (request.getMessage().getIntent().getProvider().getFulfillments().size() > 1) {
                        throw new UserException("Invalid fulfillments. " + ConstantsUtils.ARRAY_SHOULD_CONTAIN_ONLY_ONE_ITEM);
                    } else {
                        valueType = request.getMessage().getIntent().getProvider().getFulfillments().get(0).getType();
                        valueStart = Optional.ofNullable(request.getMessage().getIntent().getProvider().getFulfillments().get(0).getStart());
                        valueEnd = Optional.ofNullable(request.getMessage().getIntent().getProvider().getFulfillments().get(0).getEnd());
                        valueTags = request.getMessage().getIntent().getProvider().getFulfillments().get(0).getTags();

                        if (null != request.getMessage().getIntent().getProvider().getFulfillments().get(0).getAgent()) {
                            valueName = request.getMessage().getIntent().getProvider().getFulfillments().get(0).getAgent().getName();
                            valueHPRID = request.getMessage().getIntent().getProvider().getFulfillments().get(0).getAgent().getId();
                            specialityTags = request.getMessage().getIntent().getProvider().getFulfillments().get(0).getAgent().getTags();
                        }

                        categories = request.getMessage().getIntent().getProvider().getCategories();

                        if (null != categories) {
                            List<Category> categoriesList = categories.stream().toList();
                            if (isSecondSearch) {
                                Predicate<Category> skipParentCategory = c -> null != c.getParent_category_id();
                                categoriesList = categoriesList.stream().filter(skipParentCategory).toList();
                            }
                            specialitySearch = categoriesList.get(0).getDescriptor().getCode();
                        }
                        listOfParams.put(ConstantsUtils.FROM_DATE, "");
                        listOfParams.put(ConstantsUtils.TO_DATE, "");

                        if (valueStart.isPresent()) {
                            Date startDate = simpleDateFormat.parse(request.getMessage().getIntent().getProvider().getFulfillments().get(0).getStart().getTime().getTimestamp());
                            String dtString = simpleDateFormat.format(startDate);
                            listOfParams.replace(ConstantsUtils.FROM_DATE, dtString);
                        }

                        if (valueEnd.isPresent()) {
                            Date endDate = simpleDateFormat.parse(request.getMessage().getIntent().getProvider().getFulfillments().get(0).getEnd().getTime().getTimestamp());
                            String dtString = simpleDateFormat.format(endDate);
                            listOfParams.replace(ConstantsUtils.TO_DATE, dtString);
                        }

                    }
                } else {

                    valueType = request.getMessage().getIntent().getFulfillment().getType();
                    valueStart = Optional.ofNullable(request.getMessage().getIntent().getFulfillment().getStart());
                    valueEnd = Optional.ofNullable(request.getMessage().getIntent().getFulfillment().getEnd());
                    valueTags = request.getMessage().getIntent().getFulfillment().getTags();
                    if (null != request.getMessage().getIntent().getFulfillment().getAgent()) {
                        valueName = request.getMessage().getIntent().getFulfillment().getAgent().getName();
                        valueHPRID = request.getMessage().getIntent().getFulfillment().getAgent().getId();
                        specialityTags = request.getMessage().getIntent().getFulfillment().getAgent().getTags();
                    }
                    if (null != request.getMessage().getIntent().getCategory()) {
                        specialitySearch = request.getMessage().getIntent().getCategory().getDescriptor().getCode();
                    }

                    listOfParams.put(ConstantsUtils.FROM_DATE, "");
                    listOfParams.put(ConstantsUtils.TO_DATE, "");

                    if (valueStart.isPresent()) {
                        Date startDate = simpleDateFormat.parse(request.getMessage().getIntent().getFulfillment().getStart().getTime().getTimestamp());
                        String dtString = simpleDateFormat.format(startDate);
                        listOfParams.replace(ConstantsUtils.FROM_DATE, dtString);
                    }

                    if (valueEnd.isPresent()) {
                        Date endDate = simpleDateFormat.parse(request.getMessage().getIntent().getFulfillment().getEnd().getTime().getTimestamp());
                        String dtString = simpleDateFormat.format(endDate);
                        listOfParams.replace(ConstantsUtils.TO_DATE, dtString);
                    }

                    if (order.isPresent()) {
                        valueName = request.getMessage().getOrder().getFulfillment().getAgent().getName();
                        valueHPRID = request.getMessage().getOrder().getFulfillment().getAgent().getId();
                    }

                }
                if (null != valueName) {
                    listOfParams.put("name", valueName);
                }
                if (null != valueType) {
                    listOfParams.put("type", valueType);
                }

                if (null != valueHPRID) {
                    listOfParams.put("hprid", valueHPRID);
                }

                if (null != valueTags) {
                    if (valueTags.get(ConstantsUtils.ABDM_GOV_IN_LANGUAGES_TAG) != null) {
                        listOfParams.put(ConstantsUtils.LANGUAGES, valueTags.get(ConstantsUtils.ABDM_GOV_IN_LANGUAGES_TAG));
                    }
                    if (valueTags.get(ConstantsUtils.ABDM_GOV_IN_SPECIALITY_TAG) != null) {
                        listOfParams.put(ConstantsUtils.SPECIALITY, valueTags.get(ConstantsUtils.ABDM_GOV_IN_SPECIALITY_TAG));
                    }
                }

                if (null != specialitySearch) {
                    if (!specialitySearch.isBlank()) {
                        listOfParams.put(ConstantsUtils.SPECIALITY, specialitySearch);
                    }
                }


            } catch (Exception ex) {
                LOGGER.error("Intermediate Builder :: BuildSearchParametersIntent :: error::onErrorResume:: {}", ex, ex);
                LOGGER.info(ConstantsUtils.REQUESTER_MESSAGE_ID_IS, messageId);

            }
        }

        return listOfParams;
    }

    public static Map<String, String> BuildSearchParametersOrder(Request request) {

        Map<String, String> listOfParams = new HashMap<>();

        Optional<Order> order = Optional.ofNullable(request.getMessage().getOrder());

        String valueName = "";
        String valueHPRID = "";
        Optional<Start> valueStart;
        Optional<End> valueEnd;
        Map<String, String> valueTags;

        if (order.isPresent()) {
            try {
                valueName = request.getMessage().getOrder().getFulfillment().getAgent().getName();
                valueHPRID = request.getMessage().getOrder().getFulfillment().getAgent().getId();
                valueStart = Optional.ofNullable(request.getMessage().getOrder().getFulfillment().getStart());
                valueEnd = Optional.ofNullable(request.getMessage().getOrder().getFulfillment().getEnd());

                String pattern = ConstantsUtils.DATE_FORMAT;
                SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);
                listOfParams.put(ConstantsUtils.FROM_DATE, "");
                listOfParams.put(ConstantsUtils.TO_DATE, "");

                if (valueStart.isPresent()) {
                    Date startDate = simpleDateFormat.parse(request.getMessage().getOrder().getFulfillment().getStart().getTime().getTimestamp());
                    String dtString = simpleDateFormat.format(startDate);
                    listOfParams.replace(ConstantsUtils.FROM_DATE, dtString);
                }

                if (valueEnd.isPresent()) {
                    Date endDate = simpleDateFormat.parse(request.getMessage().getOrder().getFulfillment().getEnd().getTime().getTimestamp());
                    String dtString = simpleDateFormat.format(endDate);
                    listOfParams.replace(ConstantsUtils.TO_DATE, dtString);
                }

                if (valueName != null) {
                    listOfParams.put("name", valueName);
                }

                if (valueName == null) {
                    listOfParams.put("name", "");
                }

                if (valueHPRID != null) {
                    listOfParams.put("hprid", valueHPRID);
                }
            } catch (Exception ex) {
                LOGGER.error("Intermediate Builder :: BuildSearchParametersOrder :: error::onErrorResume::{}", ex, ex);
                String messageId = request.getContext().getMessageId();
                LOGGER.info(ConstantsUtils.REQUESTER_MESSAGE_ID_IS, messageId);
            }
        }

        return listOfParams;
    }

    public static List<IntermediateAppointmentModel> BuildIntermediateAppointment(String json) {

        List<IntermediateAppointmentModel> collection = new ArrayList<>();

        try {
            ObjectMapper maps = new ObjectMapper();
            JsonNode root = maps.readTree(json);

            JsonNode resultsNode = root.path(ConstantsUtils.RESULTS);
            if (resultsNode.isArray()) {

                for (JsonNode node : resultsNode) {
                    String display = node.path(ConstantsUtils.DISPLAY).asText();
                    if (display.equalsIgnoreCase("PhysicalConsultation")) {
                        display = ConstantsUtils.PHYSICAL_CONSULTATION;
                    } else if (display.equalsIgnoreCase("Teleconsultation")) {
                        display = ConstantsUtils.TELECONSULTATION;
                    }
                    String uuid = node.path("uuid").asText();

                    IntermediateAppointmentModel appointment = new IntermediateAppointmentModel();
                    appointment.setAppointmentTypeName(display);
                    appointment.setAppointmentTypeDisplay(display);
                    appointment.setAppointmentTypeUUID(uuid);

                    collection.add(appointment);
                }
            }
        } catch (Exception ex) {
            LOGGER.error("Intermediate Builder :: BuildIntermediateAppointment :: error::onErrorResume:: {}", ex, ex);
        }
        return collection;
    }

}
