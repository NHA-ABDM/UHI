package in.gov.abdm.uhi.hspa.utils;

import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.models.IntermediatePatientModel;
import in.gov.abdm.uhi.hspa.models.IntermediateProviderAppointmentModel;
import in.gov.abdm.uhi.hspa.models.IntermediateProviderModel;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.text.SimpleDateFormat;
import java.util.*;

public class ProtocolBuilderUtils {

    private static final Logger LOGGER = LogManager.getLogger(ProtocolBuilderUtils.class);

    private static final String DATE_TIME_PATTERN = "yyyy-MM-dd'T'HH:mm:ss";

    public static Catalog BuildCatalog(List<IntermediateProviderModel> list) {

        return BuildCatalog(list, null);
    }
    public static Catalog BuildCatalog(List<IntermediateProviderModel> list, Request request) {
        List<Item> listItems = new ArrayList<>();
        List<Fulfillment> listFulfillments = new ArrayList<>();
        String fulfillmentType = "";

        if (request != null)
        {
            fulfillmentType = request.getMessage().getIntent().getFulfillment().getType();
        }

        Catalog objCatalog = null;
        try {

            for (int i = 0; i < list.size(); i++) {

                IntermediateProviderModel obj = list.get(i);
                Item objItem = new Item();
                Fulfillment objFulfilment = new Fulfillment();

                Descriptor descriptor = new Descriptor();
                descriptor.setName("Consultation");

                Agent objAgent = new Agent();
                objAgent.setId(obj.id);
                objAgent.setName(obj.name);
                objAgent.setGender(obj.gender);

                Map<String, String> tags = new HashMap<>();
                tags.put("@abdm/gov/in/languages", obj.getLanguages());
                tags.put("@abdm/gov/in/education", obj.getEducation());
                tags.put("@abdm/gov/in/speciality", obj.getSpeciality());
                tags.put("@abdm/gov/in/experience", obj.getExpr());
                tags.put("@abdm/gov/in/first_consultation", obj.getFirst_consultation());
                tags.put("@abdm/gov/in/follow_up", obj.getFollow_up());
                tags.put("@abdm/gov/in/hpr_id", obj.getHpr_id());
                tags.put("@abdm/gov/in/lab_report_consultation", obj.getLab_consultation());
                tags.put("@abdm/gov/in/signature", obj.getSignature_uri());
                tags.put("@abdm/gov/in/upi_id", obj.getUpi_id());

                objAgent.setTags(tags);

                Price price = new Price();
                price.setCurrency("INR");
                price.setValue(obj.getFirst_consultation());

                objItem.setDescriptor(descriptor);
                objItem.setId(String.valueOf(i));

                objFulfilment.setAgent(objAgent);
                objFulfilment.setId(String.valueOf(i));

                if(fulfillmentType.equalsIgnoreCase("Teleconsultation") || fulfillmentType.equalsIgnoreCase("PhysicalConsultation")) {
                    objFulfilment.setType(fulfillmentType);
                }

                objItem.setPrice(price);

                objItem.setFulfillmentId(String.valueOf(i));

                //Check if need start time end time
                Start objStart = new Start();
                End objEnd = new End();
                Time objTIme = new Time();

                SimpleDateFormat sdf;
                sdf = new SimpleDateFormat("'T'HH:mmXXX");
                sdf.setTimeZone(TimeZone.getTimeZone("IST"));

                objTIme.setTimestamp(sdf.format(new Date(System.currentTimeMillis())));
                objStart.setTime(objTIme);
                objEnd.setTime(objTIme);

                objFulfilment.setStart(objStart);
                objFulfilment.setEnd(objEnd);


                listItems.add(objItem);
                listFulfillments.add(objFulfilment);

            }
            objCatalog = new Catalog();
            Descriptor descriptor = new Descriptor();
            descriptor.setName("HSPA");
            objCatalog.setDescriptor(descriptor);
            objCatalog.setItems(listItems);
            objCatalog.setFulfillments(listFulfillments);

            return objCatalog;
        } catch (Exception ex) {

            LOGGER.error("Protocol Builder::BuildCatalog ::error::" + ex);
        }

        return objCatalog;
    }

    public static Catalog BuildProviderCatalog(List<IntermediateProviderAppointmentModel> list)
    {
        List<Item> listItems = new ArrayList<>();
        List<Fulfillment> listFulfillments = new ArrayList<>();
        Catalog objCatalog = null;

        try {
            for (int i = 0; i < list.size(); i++) {

                IntermediateProviderAppointmentModel obj = list.get(i);
                Item objItem = new Item();
                Fulfillment objFulfilment = new Fulfillment();

                Descriptor descriptor = new Descriptor();
                descriptor.setName("Consultation");

                Agent objAgent = new Agent();
                objAgent.setId(obj.hpr_id);
                objAgent.setName(obj.name);
                objAgent.setGender(obj.gender);
                objAgent.setId(obj.hpr_id);

                Quote quote = new Quote();
                Price price = new Price();
                price.setCurrency("INR");
                price.setValue(obj.getCharges());
                quote.setPrice(price);


                objItem.setDescriptor(descriptor);
                objItem.setId(String.valueOf(i));

                objFulfilment.setAgent(objAgent);
                objFulfilment.setId(obj.slotId);
                objFulfilment.setType("DIGITAL-CONSULTATION");
                objFulfilment.setQuote(quote);

                objItem.setFulfillmentId(obj.slotId);

                //Check if need start time end time
                Start objStart = new Start();
                End objEnd = new End();
                Time objStartTime = new Time();
                Time objEndTime = new Time();


                SimpleDateFormat simpleDateFormat = new SimpleDateFormat(DATE_TIME_PATTERN);

                Date startDateTime = simpleDateFormat.parse(obj.startDateTime);
                Date endDateTime = simpleDateFormat.parse(obj.endDateTime);

                objStartTime.setTimestamp(simpleDateFormat.format(startDateTime));
                objEndTime.setTimestamp(simpleDateFormat.format(endDateTime));

                objStart.setTime(objStartTime);
                objEnd.setTime(objEndTime);

                objFulfilment.setStart(objStart);
                objFulfilment.setEnd(objEnd);

                Map<String, String> tags = new HashMap<>();
                tags.put("@abdm/gov.in/slot", obj.slotId);
                objFulfilment.setTags(tags);

                listItems.add(objItem);
                listFulfillments.add(objFulfilment);

            }
            objCatalog = new Catalog();
            Descriptor descriptor = new Descriptor();
            descriptor.setName("HSPA");
            objCatalog.setDescriptor(descriptor);
            objCatalog.setItems(listItems);
            objCatalog.setFulfillments(listFulfillments);

            return objCatalog;
        }
        catch (Exception ex)
        {
            LOGGER.error("Protocol Builder::BuildProviderCatalog ::error::" + ex);
        }

        return objCatalog;
    }

    public static Request BuildIntitialization(IntermediatePatientModel patientModel, Request request)
    {
        Order order = request.getMessage().getOrder();
        //order.setId(patientModel.getId());
        Quote quote = new Quote();

        quote.setPrice(order.getItem().getPrice());
        Payment payment = new Payment();
        ////TODO:change to get upi id
        payment.setUri("https://api.bpp.com/pay?amt=100&txn_id=ksh87yriuro34iyr3p4&mode=upi&vpa=doctor@upi");
        payment.setType("ON-ORDER");
        payment.setStatus("NOT-PAID");

        order.setPayment(payment);
        List<Breakup> breakups =  CreateBreakup(request.getMessage().getOrder().getItem().getPrice());

        quote.setBreakup(breakups);
        order.setQuote(quote);
        request.getMessage().setOrder(order);

        return  request;
    }

    private static List<Breakup> CreateBreakup(Price price)
    {
        Quote quote = new Quote();
        Breakup breakupConsultation = new Breakup();
        Price priceConsultation = new Price();
        Breakup breakupCGST = new Breakup();
        Price priceCGST = new Price();
        Breakup breakupSGST = new Breakup();
        Price priceSGST = new Price();
        Breakup breakupRegistration = new Breakup();
        Price priceRegistration = new Price();

        breakupConsultation.setTitle("Consultation");
        priceConsultation.setCurrency("INR");
        priceConsultation.setCurrency(price.getValue());
        breakupConsultation.setPrice(priceConsultation);

        breakupCGST.setTitle("CGST @ 5%");
        priceCGST.setCurrency("INR");

        Float cgst = Float.parseFloat(price.getValue());
        cgst = (5 /cgst * 100);

        priceCGST.setCurrency(cgst.toString());
        breakupCGST.setPrice(priceConsultation);

        breakupSGST.setTitle("SGST @ 5%");
        priceSGST.setCurrency("INR");

        Float sgst = Float.parseFloat(price.getValue());
        sgst = (5 /cgst * 100);

        priceSGST.setCurrency(sgst.toString());
        breakupSGST.setPrice(priceConsultation);

        breakupRegistration.setTitle("Registration");
        priceRegistration.setCurrency("INR");
        priceRegistration.setCurrency("0");
        breakupRegistration.setPrice(priceConsultation);

        quote.setPrice(price);

        List<Breakup> breakup = new ArrayList<>();
        breakup.add(breakupConsultation);
        breakup.add(breakupCGST);
        breakup.add(breakupSGST);
        breakup.add(breakupRegistration);

        return breakup;
    }
}
