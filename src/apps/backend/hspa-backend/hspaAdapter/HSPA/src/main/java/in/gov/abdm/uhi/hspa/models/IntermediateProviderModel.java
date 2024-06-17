package in.gov.abdm.uhi.hspa.models;

import lombok.Data;

@Data
public class IntermediateProviderModel {

    public String id;
    public String uuid;
    public String name;
    public String education;
    public String speciality;
    public String category_id;
    public String parent_category;
    public String parent_category_id;
    public String hpr_id;
    public String languages;
    public String expr;
    public String first_consultation;
    public String follow_up;
    public String lab_consultation;
    public String upi_id;
    public String signature_uri;
    public String receive_payment;
    public String gender;
    public String age;
    public String is_teleconsultation;
    public String is_physical_consultation;
    public String profile_photo;
    public String appointmentType;
    public String countOfAppointment;


}
