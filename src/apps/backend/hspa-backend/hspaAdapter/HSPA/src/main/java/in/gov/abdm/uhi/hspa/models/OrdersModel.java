package in.gov.abdm.uhi.hspa.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
import in.gov.abdm.uhi.hspa.dto.ServiceResponseDTO;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(schema = ConstantsUtils.HSPA_SCHEMA_NAME, name = "Orders")
@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class OrdersModel extends ServiceResponseDTO {
    @Id
    @Column(name = "order_id")
    private String orderId;

    @Column(name = "category_id")
    private String categoryId;

    @Column(name = "appointment_id")
    private String appointmentId;

    @Column(name = "order_date", length = 1000)
    private String orderDate;
    @Column(name = "healthcare_service_name", length = 1000)
    private String healthcareServiceName;
    @Column(name = "healthcare_service_id", length = 1000)
    private String healthcareServiceId;
    @Column(name = "healthcare_provider_name", length = 1000)
    private String healthcareProviderName;
    @Column(name = "healthcare_provider_id", length = 1000)
    private String healthcareProviderId;
    @Column(name = "healthcare_provider_url", length = 1000)
    private String healthcareProviderUrl;
    @Column(name = "healthcare_service_provider_email", length = 1000)
    private String healthcareServiceProviderEmail;
    @Column(name = "healthcare_service_provider_phone", length = 1000)
    private String healthcareServiceProviderPhone;
    @Column(name = "healthcare_professional_name", length = 1000)
    private String healthcareProfessionalName;
    @Column(name = "healthcare_professional_image", length = 20000)
    private String healthcareProfessionalImage;
    @Column(name = "healthcare_professional_email", length = 1000)
    private String healthcareProfessionalEmail;
    @Column(name = "healthcare_professional_phone", length = 1000)
    private String healthcareProfessionalPhone;
    @Column(name = "healthcare_professional_id", length = 1000)
    private String healthcareProfessionalId;
    @Column(name = "healthcare_professional_gender", length = 1000)
    private String healthcareProfessionalGender;


    @Column(name = "service_fulfillment_start_time", length = 1000)
    private String serviceFulfillmentStartTime;
    @Column(name = "service_fulfillment_end_time", length = 1000)
    private String serviceFulfillmentEndTime;
    @Column(name = "service_fulfillment_type", length = 1000)
    private String serviceFulfillmentType;

    private String symptoms;
    @Column(name = "languages_spoken_by_healthcare_professional", length = 1000)
    private String languagesSpokenByHealthcareProfessional;
    @Column(name = "healthcare_professional_experience", length = 1000)
    private String healthcareProfessionalExperience;
    @Column(name = "is_service_fulfilled", length = 1000)
    private String isServiceFulfilled;
    @Column(name = "healthcare_professional_department", length = 1000)
    private String healthcareProfessionalDepartment;
    @Column(name = "Message", length = 50000)
    private String message;
    @Column(name = "slot_id", length = 1000)
    private String slotId;

    @Column(name = "patient_gender", length = 1000)
    private String patientGender;
    @Column(name = "patient_name", length = 1000)
    private String patientName;
    @Column(name = "patient_consumer_url", length = 1000)
    private String patientConsumerUrl;


    @Column(name = "transId", length = 1000)
    private String transId;

    @Column(name = "primary_doctor_name", length = 1000)
    private String primaryDoctorName;

    @Column(name = "primary_doctor_hpr_address", length = 1000)
    private String primaryDoctorHprAddress;

    @Column(name = "primary_doctor_gender", length = 1000)
    private String PrimaryDoctorGender;

    @Column(name = "primary_doctor_provider_url", length = 1000)
    private String PrimaryDoctorProviderURI;

    @Column(name = "secondary_doctor_name", length = 1000)
    private String secondaryDoctorName;

    @Column(name = "secondary_doctor_hpr_address", length = 1000)
    private String secondaryDoctorHprAddress;

    @Column(name = "secondary_doctor_gender", length = 1000)
    private String SecondaryDoctorGender;

    @Column(name = "secondary_doctor_provider_url", length = 1000)
    private String SecondaryDoctorProviderURI;

    @Column(name = "teleconsultation_uri", length = 1000)
    private String teleconsultationUri;

    @Column(name = "patient_teleconsultation_uri", length = 1000)
    private String patientTeleconsultationUri;

    @Column(name = "groupConsultStatus", length = 1000)
    private String groupConsultStatus;

    @Column(name = "healthIdNumber", length = 1000)
    private String abhaId;


    @CreationTimestamp
    @JsonIgnore
    @Column(name = "creation_date", updatable = false)
    private LocalDateTime createDate;

    @UpdateTimestamp
    @JsonIgnore
    @Column(name = "modify_date")
    private LocalDateTime modifyDate;

    @OneToOne
    @JoinColumn(name = "transaction_id", referencedColumnName = "transaction_id")
    private PaymentsModel payment;

}
