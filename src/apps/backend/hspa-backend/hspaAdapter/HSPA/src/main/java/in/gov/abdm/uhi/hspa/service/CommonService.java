package in.gov.abdm.uhi.hspa.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.networknt.schema.JsonSchema;
import com.networknt.schema.JsonSchemaFactory;
import com.networknt.schema.SpecVersion;
import com.networknt.schema.ValidationMessage;
import in.gov.abdm.uhi.common.dto.Error;
import in.gov.abdm.uhi.common.dto.*;
import in.gov.abdm.uhi.hspa.exceptions.UserException;
import in.gov.abdm.uhi.hspa.utils.ClasspathLoader;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;

@Service
public abstract class CommonService {

    private static final Logger LOGGER = LogManager.getLogger(CommonService.class);

    static boolean isTestHspaProviderSearchOrDoctorSearch(Request objRequest, boolean isSecondSearch) throws UserException {
        Optional<Provider> providerOptional = Optional.ofNullable(objRequest.getMessage().getIntent().getProvider());
        Provider provider;
        if (providerOptional.isEmpty()) {
            return ifProviderNotPresentFollowThisFlow(objRequest);
        } else {
            return ifProviderPresentFollowThisFlow(objRequest, isSecondSearch, providerOptional);
        }
    }

    private static boolean ifProviderPresentFollowThisFlow(Request objRequest, boolean isSecondSearch, Optional<Provider> providerOptional) throws UserException {
        Provider provider;
        provider = providerOptional.get();
        String messageId = objRequest.getContext().getMessageId();
        String providerName = null;
        if (!isSecondSearch) {
            providerName = provider.getDescriptor().getName();
            testSchemaAndThrowExceptionIfFails(ConstantsUtils.NULL.equalsIgnoreCase(providerName), "Descriptor name cannot be empty", messageId);
        } else
            testSchemaAndThrowExceptionIfFails(null == provider.getId(), "Provider ID cannot be empty", messageId);

        if (isSecondSearch) {
            List<Fulfillment> fulfillments = objRequest.getMessage().getIntent().getProvider().getFulfillments();
            Set<Category> categories = objRequest.getMessage().getIntent().getProvider().getCategories();

            validateCategoriesAndFulfillments(true, fulfillments, categories, messageId);
            List<Fulfillment> fulfillmentsFilteredBasedOnType = fulfillments.stream().filter(f -> f.getType().equalsIgnoreCase(ConstantsUtils.PHYSICAL_CONSULTATION) || f.getType().equalsIgnoreCase(ConstantsUtils.TELECONSULTATION)).toList();
            long trueCount = fulfillments.size() > 0 ? (long) fulfillmentsFilteredBasedOnType.size() : -1L;

            boolean isRequestFulfillmentTypeInvalid = trueCount <= 0;
            if (isRequestFulfillmentTypeInvalid) {
                throw new UserException(ConstantsUtils.INVALID_FULFILLMENT_TYPE);
            }
            return true;
        }
        return null != providerName && providerName.equalsIgnoreCase(ConstantsUtils.PROVIDERNAME);
    }

    private static void validateCategoriesAndFulfillments(boolean isSecondSearch, List<Fulfillment> fulfillments, Set<Category> categories, String messageId) throws UserException {
        boolean isMoreThan1DoctorBeingSearched = fulfillments.size() > 1;
        if (isMoreThan1DoctorBeingSearched) {
            LOGGER.error(ConstantsUtils.ERROR_COMMON_SERVICE_MESSAGE_ID_IS, ConstantsUtils.INVALID_FULFILLMENTS, messageId);
            throw new UserException(ConstantsUtils.INVALID_FULFILLMENTS);
        }
        if (!isSecondSearch) {
            boolean ifCategoriesAlongWithPArentCategoryExceedsSize2 = categories.size() > 2;
            if (ifCategoriesAlongWithPArentCategoryExceedsSize2) {
                LOGGER.error(ConstantsUtils.ERROR_COMMON_SERVICE_MESSAGE_ID_IS, ConstantsUtils.INVALID_CATEGORIES, messageId);
                throw new UserException(ConstantsUtils.INVALID_CATEGORIES);
            }
            boolean isCategoriesSizeGreaterThan1InFirstSearch = !isSecondSearch && categories.size() > 1;
            if (isCategoriesSizeGreaterThan1InFirstSearch) {
                LOGGER.error(ConstantsUtils.ERROR_COMMON_SERVICE_MESSAGE_ID_IS, ConstantsUtils.INVALID_CATEGORIES, messageId);
                throw new UserException(ConstantsUtils.INVALID_CATEGORIES);
            }
        }
    }

    private static boolean ifProviderNotPresentFollowThisFlow(Request objRequest) throws UserException {
        String typeFulfillment = objRequest.getMessage().getIntent().getFulfillment().getType();
        boolean ifFullfillmentTypeValid = typeFulfillment.equalsIgnoreCase(ConstantsUtils.TELECONSULTATION)
                || typeFulfillment.equalsIgnoreCase(ConstantsUtils.PHYSICAL_CONSULTATION);

        if (!ifFullfillmentTypeValid) {
            LOGGER.error(ConstantsUtils.ERROR_COMMON_SERVICE_MESSAGE_ID_IS, ConstantsUtils.INVALID_FULFILLMENT_TYPE, objRequest.getContext().getMessageId());
            throw new UserException(ConstantsUtils.INVALID_FULFILLMENT_TYPE);
        }
        return true;
    }

    private static void testSchemaAndThrowExceptionIfFails(boolean typeFulfillment, String Invalid_Fulfillment_type, String messageId) throws UserException {
        if (typeFulfillment) {
            LOGGER.error(ConstantsUtils.ERROR_COMMON_SERVICE_MESSAGE_ID_IS, Invalid_Fulfillment_type, messageId);
            throw new UserException(Invalid_Fulfillment_type);
        }
    }

    static String getMessageId(Request objRequest) {
        String messageId = objRequest.getContext().getMessageId();
        return messageId == null ? " " : messageId;
    }

    public static boolean isFulfillmentTypeOrPaymentStatusCorrect(String typeFulfillment, String string1, String string2) {
        return typeFulfillment.equalsIgnoreCase(string1) || typeFulfillment.equalsIgnoreCase(string2);
    }

    public static Response generateNack(Exception js, String messageId, String transactionId) {

        MessageAck msz = new MessageAck();
        Response res = new Response();
        Ack ack = new Ack();
        ack.setStatus("NACK");
        msz.setAck(ack);
        in.gov.abdm.uhi.common.dto.Error err = new Error();
        err.setMessage(js.getMessage());
        err.setType("Search");
        err.setMessage(js.getMessage() + " Message id is :" + messageId + " and Transaction id is :" + transactionId);
        res.setError(err);
        res.setMessage(msz);
        return res;
    }

    public static Response setMessageidAndTxnIdInNack(Request objRequest, Exception ex) {
        Response ack = null;
        if (null != objRequest && null != objRequest.getContext() && null != objRequest.getContext().getMessageId() && null != objRequest.getContext().getTransactionId()) {
            ack = CommonService.generateNack(ex, objRequest.getContext().getMessageId(), objRequest.getContext().getTransactionId());
        } else {
            LOGGER.error("Invalid request");
        }
        return ack;
    }

    public static Mono<Response> validateJson(String request, String schemaName) throws UserException {

        ObjectMapper objectMapper = new ObjectMapper();
        JsonSchemaFactory schemaFactory = JsonSchemaFactory.getInstance(SpecVersion.VersionFlag.V4);
        InputStream schemaStream = ClasspathLoader.inputStreamFromClasspath(schemaName);
        {
            JsonNode json = null;
            try {
                json = objectMapper.readTree(request);
            } catch (IOException ex) {
                LOGGER.error(ex.getMessage(), ex);
            }

            JsonSchema schema = schemaFactory.getSchema(schemaStream);
            Set<ValidationMessage> validationResult;
            try {
                validationResult = schema.validate(json);
            } catch (Exception e) {
                throw new UserException(ConstantsUtils.INVALID_JSON_REQUEST);
            }
            List<String> erroList = new ArrayList<>();
            if (!validationResult.isEmpty()) {
                Error error = new Error();
                for (ValidationMessage validationMessage : validationResult) {
                    erroList.add(validationMessage.getMessage().replace("$.context.", ""));
                }
                error.setMessage(erroList.toString());
                Response response = new Response();
                MessageAck message = new MessageAck();
                error.setCode(HttpStatus.BAD_REQUEST.value() + "");
                error.setType(HttpStatus.BAD_REQUEST.name());
                Ack ack = new Ack();
                ack.setStatus("NACK");
                message.setAck(ack);
                response.setError(error);
                response.setMessage(message);
                return Mono.just(response);
            }

            return null;
        }
    }
}
