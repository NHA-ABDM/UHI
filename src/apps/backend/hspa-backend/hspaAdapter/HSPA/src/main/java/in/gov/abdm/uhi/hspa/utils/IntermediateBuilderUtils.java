package in.gov.abdm.uhi.hspa.utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.models.*;
import in.gov.abdm.uhi.hspa.models.opemMRSModels.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;

import java.text.SimpleDateFormat;
import java.util.*;

public class IntermediateBuilderUtils {

    private static final Logger LOGGER = LogManager.getLogger(IntermediateBuilderUtils.class);
    private static final String IDENTIFIER_TYPE = "7f820ce9-e6cb-4242-9aa3-1faaf8ad116e"; //ABHA
    private static final String IDENTIFIER_LOCATION = "58c57d25-8d39-41ab-8422-108a0c277d98"; //Outpatient

    private static final String DATE_TIME_PATTERN = "yyyy-MM-dd'T'HH:mm:ss";

    @Autowired
    static
    ObjectMapper mapper;

    public static List<IntermediateProviderModel> BuildIntermediateObj(String json) {
        List<IntermediateProviderModel> collection = new ArrayList<>();

        try {
            ObjectMapper maps = new ObjectMapper();
            JsonNode root = maps.readTree(json);

            JsonNode resultsNode = root.path("results");
            if (resultsNode.isArray()) {


                for (JsonNode node : resultsNode) {

                    IntermediateProviderModel objIntermediate = new IntermediateProviderModel();

                    String name = node.path("display").asText();
                    String hprId = node.path("hpr_id").asText();
                    String Id = node.path("identifier").asText();
                    objIntermediate.setName(name);
                    objIntermediate.setHpr_id(hprId);
                    objIntermediate.setId(Id);

                    JsonNode person = node.path("person");
                    String gender = person.path("gender").asText();
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
                            String attrKey = attribVal.path("display").asText();
                            String attrVal = attrib.path("value").asText();


                            switch (attrKey) {
                                case "education" -> objIntermediate.setEducation(attrVal);
                                case "experience" -> objIntermediate.setExpr(attrVal);
                                case "charges" -> objIntermediate.setFirst_consultation(attrVal);
                                case "first_consultation" -> objIntermediate.setFirst_consultation(attrVal);
                                case "follow_up" -> objIntermediate.setFollow_up(attrVal);
                                case "hpr_id" -> objIntermediate.setHpr_id(attrVal);
                                case "lab_report_consultation" -> objIntermediate.setLab_consultation(attrVal);
                                case "languages" -> objIntermediate.setLanguages(attrVal);
                                case "receive_payment" -> objIntermediate.setReceive_payment(attrVal);
                                case "speciality" -> objIntermediate.setSpeciality(attrVal);
                                case "upi_id" -> objIntermediate.setUpi_id(attrVal);
                                case "is_teleconsultation" -> objIntermediate.setIs_teleconsultation(attrVal);
                                case "is_physical_consultation" -> objIntermediate.setIs_physical_consultation(attrVal);
                                default -> {
                                }
                            }
                        }
                    }
                    System.out.println("type : " + name);
                    System.out.println("ref : " + hprId);
                    collection.add(objIntermediate);
                }
            }
        } catch (Exception ex) {

            LOGGER.error("Intermediate Builder::BuildIntermediateObj ::error::onErrorResume::" + ex);
        }
        return collection;
    }

    public static List<IntermediateProviderAppointmentModel> BuildIntermediateProviderAppoitmentObj(String json) {
        List<IntermediateProviderAppointmentModel> collection = new ArrayList<>();

        try {
            ObjectMapper maps = new ObjectMapper();
            JsonNode root = maps.readTree(json);

            JsonNode resultsNode = root.path("results");
            if (resultsNode.isArray()) {


                for (JsonNode node : resultsNode) {

                    IntermediateProviderAppointmentModel objIntermediate = new IntermediateProviderAppointmentModel();

                    JsonNode appointmentBlock = node.path("appointmentBlock");
                    JsonNode provider = appointmentBlock.path("provider");
                    JsonNode person = provider.path("person");

                    String slotId = node.path("uuid").asText();
                    String name = provider.path("display").asText();
                    String hprId = provider.path("identifier").asText();
                    String id = provider.path("uuid").asText();
                    objIntermediate.setName(name);
                    objIntermediate.setHpr_id(hprId);
                    objIntermediate.setId(id);
                    objIntermediate.setSlotId(slotId);

                    String gender = person.path("gender").asText();
                    String age = person.path("age").asText();
                    objIntermediate.setGender(gender);
                    objIntermediate.setAge(age);


                    JsonNode attributes = provider.path("attributes");
                    if (attributes.isArray()) {
                        for (JsonNode attrib : attributes) {
                            JsonNode attribVal = attrib.path("attributeType");
                            String attrKey = attribVal.path("display").asText();
                            String attrVal = attrib.path("value").asText();

                            switch (attrKey) {
                                case "Education" -> objIntermediate.setEducation(attrVal);
                                case "Experience" -> objIntermediate.setExpr(attrVal);
                                case "Languages" -> objIntermediate.setLanguages(attrVal);
                                case "Charges" -> objIntermediate.setCharges(attrVal);
                                case "Speciality" -> objIntermediate.setSpeciality(attrVal);
                                default -> {
                                }
                            }

                            System.out.println("type : " + attrKey);
                            System.out.println("type : " + attrVal);
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
            LOGGER.error("Intermediate Builder :: BuildIntermediateProviderAppoitmentObj :: error::onErrorResume::" + ex);
        }
        return collection;
    }

    public static List<IntermediatePatientAppointmentModel> BuildIntermediatePatientAppoitmentObj(String appointment, String patient, Order order) {

        List<IntermediatePatientAppointmentModel> collection = new ArrayList<>();

        try {

            ObjectMapper maps = new ObjectMapper();
            JsonNode rootPatient = maps.readTree(patient);
            JsonNode rootAppointment = maps.readTree(appointment);

            JsonNode resultPatient = rootPatient.path("results");
            JsonNode resultAppointment = rootAppointment.path("results");

            if (resultAppointment.isEmpty() && rootAppointment.has("uuid") && (resultPatient.isArray() && resultPatient.elements().hasNext())) {
                IntermediatePatientAppointmentModel objIntermediate = new IntermediatePatientAppointmentModel();

                JsonNode appointmentId = rootAppointment.path("uuid");
                JsonNode appointmentStatus = rootAppointment.path("status");
                JsonNode appointmentType = rootAppointment.path("appointmentType");
                JsonNode appointmentTimeSlot = rootAppointment.path("timeSlot");
                JsonNode appointmentTimeSlotId = appointmentTimeSlot.path("uuid");
                JsonNode appointmentTypeName = appointmentType.path("display");

                JsonNode patientNode = resultPatient.get(0).path("person");
                JsonNode patientName = patientNode.path("display");
                JsonNode gender = patientNode.path("gender");

                objIntermediate.setAppointmentId(appointmentId.asText());
                objIntermediate.setAppointmentTypeName(appointmentTypeName.asText());
                objIntermediate.setStatus(appointmentStatus.asText());
                objIntermediate.setSlotId(appointmentTimeSlotId.asText());
                objIntermediate.setName(patientName.asText());
                objIntermediate.setGender(gender.asText());

                collection.add(objIntermediate);
                LOGGER.info("Intermediate Builder :: BuildIntermediateProviderAppoitmentObj :: patientlist::patients::" + resultPatient);

            } else if (resultPatient.isArray() && resultPatient.elements().hasNext()) {

                LOGGER.info("Intermediate Builder :: BuildIntermediateProviderAppoitmentObj :: patientlist::patients::" + resultPatient);

                for (JsonNode node : resultPatient) {

                    IntermediatePatientAppointmentModel objIntermediate = new IntermediatePatientAppointmentModel();

                    //String patientName = node.path("display").asText();
                    String patientId = node.path("uuid").asText();

                    if (resultAppointment.isArray()) {
                        JsonNode appointmentId = resultAppointment.get(0).path("uuid");
                        JsonNode appointmentName = resultAppointment.get(0).path("name");
                        objIntermediate.setAppointmentTypeId(appointmentId.asText());
                        objIntermediate.setAppointmentTypeName(appointmentName.asText());
                    }

                    objIntermediate.setSlotId(order.getFulfillment().getId());
                    objIntermediate.setPatientId(patientId);
                    objIntermediate.setStatus("SCHEDULED");

                    collection.add(objIntermediate);
                }
            }

        } catch (Exception ex) {
            LOGGER.error("Intermediate Builder :: BuildIntermediateProviderAppoitmentObj :: error::onErrorResume::" + ex);
        }
        return collection;
    }

    public static patient BuildPatientModel(Order order) {
        patient patient = new patient();
        try {

            //add abha
            identifier abha = new identifier();
            abha.setIdentifier(order.getCustomer().getCred());
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
            person.setAge("30");
            person.setGender("M");
            person.names = new ArrayList<>();
            person.names.add(name);

            address address = new address();
            address.setCountry(order.getBilling().getAddress().getCountry());
            address.setCityVillage(order.getBilling().getAddress().getCity());
            address.setPostalCode(order.getBilling().getAddress().getAreaCode());

            person.addresses = new ArrayList<>();
            person.addresses.add(address);
            patient.setPerson(person);

        } catch (Exception ex) {
            LOGGER.error("Intermediate Builder :: BuildPatientModel :: error::onErrorResume::" + ex);
        }
        return patient;
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
            LOGGER.error("Intermediate Builder :: BuildPatientModel :: error::onErrorResume::" + ex);
        }
        return appointmentObj;
    }

    public static List<IntermediateProviderModel> BuildIntermediateProviderDetails(String json) {
        List<IntermediateProviderModel> collection = new ArrayList<>();

        try {
            ObjectMapper maps = new ObjectMapper();
            JsonNode root = maps.readTree(json);

            JsonNode resultsNode = root.path("results");
            if (resultsNode.isArray()) {


                for (JsonNode node : resultsNode) {

                    IntermediateProviderModel objIntermediate = new IntermediateProviderModel();

                    JsonNode person = node.path("person");

                    String name = person.path("display").asText();
                    String hprId = node.path("identifier").asText();
                    String providerId = node.path("uuid").asText();
                    objIntermediate.setName(name);
                    objIntermediate.setHpr_id(hprId);
                    objIntermediate.setId(providerId);

                    collection.add(objIntermediate);
                } // end outer for
            }
        } catch (Exception ex) {
            LOGGER.error("IntermediateBuilder::BuildIntermediateProviderDetails::Request::" + ex);
            System.out.println("IntermediateBuilder::BuildIntermediateProviderDetails::Request::" + ex);
        }
        return collection;
    }

    public static IntermediatePatientModel BuildIntermediatePatient(String json) {

        IntermediatePatientModel patient = new IntermediatePatientModel();

        try {
            ObjectMapper maps = new ObjectMapper();
            JsonNode root = maps.readTree(json);
            JsonNode resultsExisitng = root.path("results");
            JsonNode resultsNew = root.path("identifiers");

            if (resultsExisitng.isArray()) {

                for (JsonNode node : resultsExisitng) {
                    JsonNode identifiers = node.path("identifiers");
                    if (identifiers.isArray()) {
                        for (JsonNode ident : identifiers) {
                            String identifier = ident.path("display").asText();
                            String[] vals = identifier.split("=");
                            if (Objects.equals(vals[0], "OpenMRS ID")) {
                                patient.setId(vals[1]);
                            } else {
                                patient.setAbha(vals[1]);
                            }
                        }
                    }
                    JsonNode person = node.path("person");
                    String name = person.path("display").asText();
                    String gender = person.path("gender").asText();
                    String age = person.path("age").asText();
                    JsonNode address = person.path("preferredAddress");
                    String add = address.path("display").asText();

                    patient.setAddress(add);
                    patient.setName(name);
                    patient.setGender(gender);
                    patient.setAge(age);


                }

            }
            if (resultsNew.isArray()) {
                for (JsonNode node : resultsNew) {
                    String identifier = node.path("display").asText();
                    String[] vals = identifier.split("=");
                    if (Objects.equals(vals[0], "OpenMRS ID")) {
                        patient.setId(vals[1]);
                    } else {
                        patient.setAbha(vals[1]);
                    }
                }
                JsonNode person = root.path("person");
                String name = person.path("display").asText();
                String gender = person.path("gender").asText();
                String age = person.path("age").asText();
                JsonNode address = person.path("preferredAddress");
                String add = address.path("display").asText();

                patient.setAddress(add);
                patient.setName(name);
                patient.setGender(gender);
                patient.setAge(age);


            } // end outer for
        } catch (Exception ex) {
            LOGGER.error("Intermediate Builder :: BuildIntermediatePatient :: error::onErrorResume::" + ex);
        }
        return patient;
    }

    public static Map<String, String> BuildSearchParametersIntent(Request request) {

        Map<String, String> listOfParams = new HashMap<>();

        Optional<Intent> intent = Optional.ofNullable(request.getMessage().getIntent());
        Optional<Order> order = Optional.ofNullable(request.getMessage().getOrder());

        String valueName = "";
        String valueHPRID = "";
        String valueType = "";
        Optional<Start> valueStart;
        Optional<End> valueEnd;
        Optional<Tag> tags;
        Map<String, String> valueTags;
        if (intent.isPresent()) {
            try {
                valueName = request.getMessage().getIntent().getFulfillment().getAgent().getName();
                valueHPRID = request.getMessage().getIntent().getFulfillment().getAgent().getId();
                valueType = request.getMessage().getIntent().getFulfillment().getType();
                valueStart = Optional.ofNullable(request.getMessage().getIntent().getFulfillment().getStart());
                valueEnd = Optional.ofNullable(request.getMessage().getIntent().getFulfillment().getEnd());
                valueTags = request.getMessage().getIntent().getFulfillment().getTags();

                SimpleDateFormat simpleDateFormat = new SimpleDateFormat(DATE_TIME_PATTERN);
                listOfParams.put("fromDate", "");
                listOfParams.put("toDate", "");

                if (valueStart.isPresent()) {
                    Date startDate = simpleDateFormat.parse(request.getMessage().getIntent().getFulfillment().getStart().getTime().getTimestamp());
                    String dtString = simpleDateFormat.format(startDate);
                    listOfParams.replace("fromDate", dtString);
                }

                if (valueEnd.isPresent()) {
                    Date endDate = simpleDateFormat.parse(request.getMessage().getIntent().getFulfillment().getEnd().getTime().getTimestamp());
                    String dtString = simpleDateFormat.format(endDate);
                    listOfParams.replace("toDate", dtString);
                }

                if (order.isPresent()) {
                    valueName = request.getMessage().getOrder().getFulfillment().getAgent().getName();
                    valueHPRID = request.getMessage().getOrder().getFulfillment().getAgent().getId();
                    //valueStart = Optional.ofNullable(request.getMessage().getOrder().getFulfillment().getStart());
                    //valueEnd = Optional.ofNullable(request.getMessage().getOrder().getFulfillment().getEnd());

                }


                if (valueName != null) {
                    listOfParams.put("name", valueName);
                }
                if (valueType != null) {
                    listOfParams.put("type", valueType);
                }

                if (valueName == null) {
                    listOfParams.put("name", "");
                }

                if (valueHPRID != null) {
                    listOfParams.put("hprid", valueHPRID);
                }

                if (valueTags != null) {
                    if (valueTags.get("@abdm/gov.in/languages") != null) {
                        listOfParams.put("languages", valueTags.get("@abdm/gov.in/languages"));
                    }
                    if (valueTags.get("@abdm/gov.in/speciality") != null) {
                        listOfParams.put("speciality", valueTags.get("@abdm/gov.in/speciality"));
                    }
                }

            } catch (Exception ex) {
                LOGGER.error("Intermediate Builder :: BuildSearchParametersIntent :: error::onErrorResume::" + ex);
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

                String pattern = "yyyy-MM-dd'T'HH:mm:ss";
                SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);
                listOfParams.put("fromDate", "");
                listOfParams.put("toDate", "");

                if (valueStart.isPresent()) {
                    Date startDate = simpleDateFormat.parse(request.getMessage().getOrder().getFulfillment().getStart().getTime().getTimestamp());
                    String dtString = simpleDateFormat.format(startDate);
                    listOfParams.replace("fromDate", dtString);
                }

                if (valueEnd.isPresent()) {
                    Date endDate = simpleDateFormat.parse(request.getMessage().getOrder().getFulfillment().getEnd().getTime().getTimestamp());
                    String dtString = simpleDateFormat.format(endDate);
                    listOfParams.replace("toDate", dtString);
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
                LOGGER.error("Intermediate Builder :: BuildSearchParametersOrder :: error::onErrorResume::" + ex);
            }
        }

        return listOfParams;
    }

    public static List<IntermediateAppointmentModel> BuildIntermediateAppointment(String json) {

        List<IntermediateAppointmentModel> collection = new ArrayList<>();

        try {
            ObjectMapper maps = new ObjectMapper();
            JsonNode root = maps.readTree(json);

            JsonNode resultsNode = root.path("results");
            if (resultsNode.isArray()) {

                for (JsonNode node : resultsNode) {


                    String display = node.path("display").asText();
                    String name = node.path("name").asText();
                    String uuid = node.path("uuid").asText();

                    IntermediateAppointmentModel appointment = new IntermediateAppointmentModel();
                    appointment.setAppointmentTypeName(display);
                    appointment.setAppointmentTypeDisplay(display);
                    appointment.setAppointmentTypeUUID(uuid);

                    collection.add(appointment);
                }
            }
        } catch (Exception ex) {
            LOGGER.error("Intermediate Builder :: BuildIntermediateAppointment :: error::onErrorResume::" + ex);
        }
        return collection;
    }

}
