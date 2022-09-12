package in.gov.abdm.uhi.hspa.models;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;

import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import lombok.Data;

@Entity
@Table(schema = ConstantsUtils.HSPA_SCHEMA_NAME, name = "Orders")
@Data
@JsonDeserialize(using = LocalDateTimeDeserializer.class)
@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
public class OrdersModel {
    @Id
    @Column(name = "order_id")
    private String orderId;

    @Column(name = "category_id")
    private String categoryId;

    @Column(name = "appointment_id")
    private String appointmentId;
    
    @Column(name = "order_date")
    private String orderDate;
    @Column(name = "healthcare_service_name")
    private String healthcareServiceName;
    @Column(name = "healthcare_service_id")
    private String healthcareServiceId;
    @Column(name = "healthcare_provider_name")
    private String healthcareProviderName;
    @Column(name = "healthcare_provider_id")
    private String healthcareProviderId;
    @Column(name = "healthcare_provider_url")
    private String healthcareProviderUrl;
    @Column(name = "healthcare_service_provider_email")
    private String healthcareServiceProviderEmail;
    @Column(name = "healthcare_service_provider_phone")
    private String healthcareServiceProviderPhone;
    @Column(name = "healthcare_professional_name")
    private String healthcareProfessionalName;
    @Column(name = "healthcare_professional_image")
    private String healthcareProfessionalImage;
    @Column(name = "healthcare_professional_email")
    private String healthcareProfessionalEmail;
    @Column(name = "healthcare_professional_phone")
    private String healthcareProfessionalPhone;
    @Column(name = "healthcare_professional_id")
    private String healthcareProfessionalId;
    @Column(name = "healthcare_professional_gender")
    private String healthcareProfessionalGender;
    @Column(name = "service_fulfillment_start_time")
    private String serviceFulfillmentStartTime;
    @Column(name = "service_fulfillment_end_time")
    private String serviceFulfillmentEndTime;
    @Column(name = "service_fulfillment_type")
    private String serviceFulfillmentType;

    private String symptoms;
    @Column(name = "languages_spoken_by_healthcare_professional")
    private String languagesSpokenByHealthcareProfessional;
    @Column(name = "healthcare_professional_experience")
    private String healthcareProfessionalExperience;
    @Column(name = "is_service_fulfilled")
    private String isServiceFulfilled;
    @Column(name = "healthcare_professional_department")
    private String healthcareProfessionalDepartment;
    @Column(name = "Message",length = 50000)
    private String message;
    @Column(name = "slot_id")
    private String slotId;

  
    @Column(name = "healthIdNumber")
    private String abhaId;
    
    @Column(name = "patientName")
    private String patientName;


    @OneToOne
    @JoinColumn(name = "transaction_id", referencedColumnName ="transaction_id")
    private PaymentsModel payment;

}
