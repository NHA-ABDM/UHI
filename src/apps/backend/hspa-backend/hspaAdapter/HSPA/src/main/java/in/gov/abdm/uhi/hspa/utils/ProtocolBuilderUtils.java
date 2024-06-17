package in.gov.abdm.uhi.hspa.utils;

import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.models.IntermediateProviderAppointmentModel;
import in.gov.abdm.uhi.hspa.models.IntermediateProviderModel;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.text.SimpleDateFormat;
import java.util.*;

import static in.gov.abdm.uhi.hspa.service.CommonService.isFulfillmentTypeOrPaymentStatusCorrect;

public class ProtocolBuilderUtils {

    private static final Logger LOGGER = LogManager.getLogger(ProtocolBuilderUtils.class);

    private static final String DATE_TIME_PATTERN = "yyyy-MM-dd'T'HH:mm:ss";


    public static Catalog BuildCatalog(List<IntermediateProviderModel> list, boolean isSecondSearch) {

        return BuildCatalog(list, null, isSecondSearch);
    }

    public static Catalog  BuildCatalog(List<IntermediateProviderModel> list, Request request, boolean isSecondSearch) {
        LinkedList<Item> listItems = new LinkedList<>();
        LinkedHashSet<Category> listCategory = new LinkedHashSet<>();
        LinkedList<Fulfillment> listFulfillments = new LinkedList<>();
        String fulfillmentType = "";
        Optional<Provider> provider = Optional.ofNullable(request.getMessage().getIntent().getProvider());
        if (null != request) {
            if (provider.isPresent() && isSecondSearch) {
                fulfillmentType = request.getMessage().getIntent().getProvider().getFulfillments().get(0).getType();
            } else {
                fulfillmentType = request.getMessage().getIntent().getFulfillment().getType();
            }
        }

        Catalog objCatalog = null;
        try {

            for (int i = 0; i < list.size(); i++) {

                IntermediateProviderModel obj = list.get(i);
                Item objItem = new Item();
                Category parentCategory = setCategory(obj, true);
                Category category = setCategory(obj, false);

                Fulfillment objFulfilment = new Fulfillment();

                Descriptor descriptor = new Descriptor();
                descriptor.setName(ConstantsUtils.CONSULTATION_DESCRIPTOR);
                descriptor.setCode(ConstantsUtils.CONSULTATION_DESCRIPTOR.toUpperCase());

                Agent objAgent = new Agent();
                objAgent.setId(obj.id);
                objAgent.setName(obj.name);
                objAgent.setGender(obj.gender);
                objAgent.setImage(obj.profile_photo);

                Map<String, String> tags = new HashMap<>();
                tags.put(ConstantsUtils.ABDM_GOV_IN_LANGUAGES, obj.getLanguages());
                tags.put(ConstantsUtils.ABDM_GOV_IN_EDUCATION, obj.getEducation());
                tags.put(ConstantsUtils.ABDM_GOV_IN_EXPERIENCE, obj.getExpr());
                tags.put(ConstantsUtils.ABDM_GOV_IN_HPR_ID, obj.getHpr_id());

                objAgent.setTags(tags);

                Price price = new Price();
                price.setCurrency(ConstantsUtils.CURRENCY);
                price.setValue(obj.getFirst_consultation());


                objFulfilment.setAgent(objAgent);

                objFulfilment.setId(String.valueOf(i));


                if (isFulfillmentTypeOrPaymentStatusCorrect(fulfillmentType, ConstantsUtils.TELECONSULTATION, ConstantsUtils.PHYSICAL_CONSULTATION)) {
                    objFulfilment.setType(fulfillmentType);
                }

                objItem.setPrice(price);
                objItem.setDescriptor(descriptor);
                objItem.setId(String.valueOf(i));
                objItem.setFulfillmentId(String.valueOf(i));
                String category_id = obj.getCategory_id();
                objItem.setCategoryId(category_id);


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

                objFulfilment.setStart(request.getMessage().getIntent().getFulfillment().getStart());
                objFulfilment.setEnd(request.getMessage().getIntent().getFulfillment().getEnd());
                listCategory.add(parentCategory);
                listCategory.add(category);


                listItems.add(objItem);
                listFulfillments.add(objFulfilment);
            }
            objCatalog = new Catalog();
            Descriptor descriptor = new Descriptor();
            descriptor.setName(ConstantsUtils.CATALOGPROVNAME);
            descriptor.setShortDesc(ConstantsUtils.CATALOG_SHORT_DESCRIPTION);
            descriptor.setLongDesc(ConstantsUtils.CATALOG_LONG_DESCRIPTION);
            descriptor.setImages(ConstantsUtils.HSPA_IMAGE);
            objCatalog.setDescriptor(descriptor);
            extractProviderDetails(objCatalog, listItems, listFulfillments, listCategory);


            return objCatalog;
        } catch (Exception ex) {

            LOGGER.error("Protocol Builder::BuildCatalog ::error::" + ex);
        }

        return objCatalog;
    }

    private static Category setCategory(IntermediateProviderModel obj, boolean isParent) {
        Random random = new Random();
        Category category = new Category();
        String parent_category_id = obj.getParent_category_id();
        parent_category_id = parent_category_id == null ? "101" : parent_category_id;
        Descriptor catDescriptor = new Descriptor();
        if (isParent) {
            String parent_category = obj.getParent_category();
            parent_category = null == parent_category ? "Allopathy" : parent_category;
            catDescriptor.setName(parent_category);

            catDescriptor.setCode(parent_category.toUpperCase());
            category.setId(parent_category_id);
        } else {
            catDescriptor.setName(obj.getSpeciality());
            catDescriptor.setCode(obj.getSpeciality().toUpperCase());
            String category_id = obj.getCategory_id();
            category.setId(category_id);
            category.setParent_category_id(parent_category_id);
        }
        category.setDescriptor(catDescriptor);
        return category;
    }

    private static Catalog extractProviderDetails(Catalog catalog, LinkedList<Item> listItems, LinkedList<Fulfillment> listFulfillments, LinkedHashSet<Category> listCategory) {
        Descriptor descriptor = new Descriptor();
        descriptor.setName(ConstantsUtils.PROVIDERNAME);
        descriptor.setShortDesc(ConstantsUtils.PROVIDER_SHORT_DESCRIPTION);
        descriptor.setLongDesc(ConstantsUtils.PROVIDER_LONG_DESCRIPTION);
        City city = new City();
        city.setName(ConstantsUtils.CITY);
        city.setCode(ConstantsUtils.CITYCODE);
        Country country = new Country();
        country.setName(ConstantsUtils.COUNTRY);
        country.setCode(ConstantsUtils.COUNTRYCODE);


        Location location = new Location();
        location.setId("1");
        location.setDescriptor(descriptor);
        location.setGps(ConstantsUtils.PROVIDERGPS);
        location.setAddress(ConstantsUtils.PROVIDERADDRESS);
        location.setCity(city);
        location.setCountry(country);


        Provider provider = new Provider();
        provider.setId("1");
        provider.setDescriptor(descriptor);

        provider.setLocation(location);
        provider.setItems(listItems);
        provider.setFulfillments(listFulfillments);
        if (listCategory != null)
            provider.setCategories(listCategory);

        LinkedList<Provider> providers = new LinkedList<>();
        providers.add(provider);

        catalog.setProviders(providers);
        return catalog;
    }

    public static Catalog BuildProviderCatalog(List<IntermediateProviderAppointmentModel> list, String appointmentType, Request request) {
        LinkedList<Item> listItems = new LinkedList<>();
        LinkedList<Fulfillment> listFulfillments = new LinkedList<>();
        Catalog objCatalog = null;
        
       

        try {
            for (int i = 0; i < list.size(); i++) {

                IntermediateProviderAppointmentModel obj = list.get(i);
                Item objItem = new Item();
                Fulfillment objFulfilment = new Fulfillment();

                Descriptor descriptor = new Descriptor();
                descriptor.setName(ConstantsUtils.CONSULTATION_DESCRIPTOR);
                descriptor.setCode(ConstantsUtils.CONSULTATION_DESCRIPTOR.toUpperCase());

                Agent objAgent = new Agent();
                objAgent.setId(obj.hpr_id);
                objAgent.setName(obj.name);
                objAgent.setGender(obj.gender);
                objAgent.setId(obj.hpr_id);
                
                Map<String, String> tags = new HashMap<>();
                tags.put(ConstantsUtils.ABDM_GOV_IN_LANGUAGES, obj.getLanguages());
                tags.put(ConstantsUtils.ABDM_GOV_IN_EDUCATION, obj.getEducation());
                tags.put(ConstantsUtils.ABDM_GOV_IN_EXPERIENCE, obj.getExpr());
                tags.put(ConstantsUtils.ABDM_GOV_IN_HPR_ID, obj.getHpr_id());

                objAgent.setTags(tags);


                Price price = new Price();
                price.setValue("0.0");
                price.setCurrency(ConstantsUtils.CURRENCY);
                objItem.setPrice(price);


                objItem.setDescriptor(descriptor);
                objItem.setId(String.valueOf(i));

                objFulfilment.setAgent(objAgent);
                objFulfilment.setId(obj.slotId);
                objFulfilment.setType(appointmentType);


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

                listItems.add(objItem);
                listFulfillments.add(objFulfilment);
            }

            objCatalog = new Catalog();
            Descriptor descriptor = new Descriptor();
            descriptor.setName(ConstantsUtils.CATALOGPROVNAME);
            descriptor.setShortDesc(ConstantsUtils.CATALOG_SHORT_DESCRIPTION);
            descriptor.setLongDesc(ConstantsUtils.CATALOG_LONG_DESCRIPTION);
            objCatalog.setDescriptor(descriptor);
            objCatalog = extractProviderDetails(objCatalog, listItems, listFulfillments, null);

            return objCatalog;
        } catch (Exception ex) {
            LOGGER.error("Protocol Builder::BuildProviderCatalog ::error::" + ex);
        }
        return objCatalog;
    }

    public static Request BuildIntitialization(Request request) {


        Order order = request.getMessage().getOrder();
        //order.setId(patientModel.getId());
        Quote quote = new Quote();

        quote.setPrice(order.getItem().getPrice());
        Payment payment = new Payment();
        payment.setType(ConstantsUtils.PAYMENT_STATE_INIT);
        payment.setStatus(ConstantsUtils.PAYMENT_STATUS_FREE);


        order.setPayment(payment);
        List<Breakup> breakups = CreateBreakup(request.getMessage().getOrder().getItem().getPrice());

        quote.setBreakup(breakups);
        order.setQuote(quote);
        request.getMessage().setOrder(order);

        return request;
    }

    private static List<Breakup> CreateBreakup(Price price) {
        Quote quote = new Quote();
        Breakup breakupConsultation = new Breakup();
        Price priceConsultation = new Price();
        Breakup breakupCGST = new Breakup();
        Price priceCGST = new Price();
        Breakup breakupSGST = new Breakup();
        Price priceSGST = new Price();
        Breakup breakupRegistration = new Breakup();
        Price priceRegistration = new Price();

        breakupConsultation.setTitle(ConstantsUtils.CONSULTATION_DESCRIPTOR);
        priceConsultation.setCurrency(ConstantsUtils.CURRENCY);
        priceConsultation.setValue(price.getValue());
        breakupConsultation.setPrice(priceConsultation);

        breakupCGST.setTitle(ConstantsUtils.CGST_5);
        priceCGST.setCurrency(ConstantsUtils.CURRENCY);


        Double cgst = Double.parseDouble(price.getValue());
        cgst = (0.05 * cgst);

        priceCGST.setValue(cgst.toString());
        breakupCGST.setPrice(priceCGST);

        breakupSGST.setTitle(ConstantsUtils.SGST_5);
        priceSGST.setCurrency(ConstantsUtils.CURRENCY);

        double sgst = Double.parseDouble(price.getValue());
        sgst = (0.05 * sgst);


        priceSGST.setValue(Double.toString(sgst));
        breakupSGST.setPrice(priceSGST);

        breakupRegistration.setTitle("Registration");
        priceRegistration.setCurrency(ConstantsUtils.CURRENCY);
        priceRegistration.setValue("0");
        breakupRegistration.setPrice(priceRegistration);

        quote.setPrice(price);

        List<Breakup> breakup = new ArrayList<>();
        breakup.add(breakupConsultation);
        breakup.add(breakupCGST);
        breakup.add(breakupSGST);
        breakup.add(breakupRegistration);

        return breakup;
    }
}
