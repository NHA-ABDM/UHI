package in.gov.abdm.uhi.EUABookingService.entity;


import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import in.gov.abdm.uhi.EUABookingService.dto.ServiceResponseDTO;
import lombok.Data;

@Entity
@Table(schema = "eua")
@Data
public class Orders extends ServiceResponseDTO {
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

    @Column(name = "patient_gender")
    private String patientGender;
    @Column(name = "patient_name")
    private String patientName;
    @Column(name = "patient_consumer_url")
    private String patientConsumerUrl;


    @Column(name = "transId")
    private String transId;

    @Column(name = "primary_doctor_name")
    private String primaryDoctorName;

    @Column(name = "primary_doctor_hpr_address")
    private String primaryDoctorHprAddress;

    @Column(name = "primary_doctor_gender")
    private String PrimaryDoctorGender;

    @Column(name = "primary_doctor_provider_url")
    private String PrimaryDoctorProviderURI;

    @Column(name = "secondary_doctor_name")
    private String secondaryDoctorName;

    @Column(name = "secondary_doctor_hpr_address")
    private String secondaryDoctorHprAddress;

    @Column(name = "secondary_doctor_gender")
    private String SecondaryDoctorGender;

    @Column(name = "secondary_doctor_provider_url")
    private String SecondaryDoctorProviderURI;

    @Column(name = "teleconUrl",length = 50000)
    private String teleconUrl; 
    
    @Column(name = "groupConsultStatus")
    private String groupConsultStatus;

    @Column(name = "healthIdNumber")
    private String abhaId;

    @CreationTimestamp
    @Column(name= "creation_date", updatable = false)
    private LocalDateTime createDate;

    @UpdateTimestamp
    @Column(name = "modify_date")
    private LocalDateTime modifyDate;

    @ManyToOne
    @JoinColumn(name = "user_id",  referencedColumnName ="id")
    private User user;



    @OneToOne
    @JoinColumn(name = "transaction_id", referencedColumnName ="transaction_id")
    private Payments payment;

}
