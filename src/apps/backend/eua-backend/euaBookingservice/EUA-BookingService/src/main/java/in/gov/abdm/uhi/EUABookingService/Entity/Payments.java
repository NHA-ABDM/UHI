package in.gov.abdm.uhi.EUABookingService.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import lombok.Data;

@Entity
@Table(schema = "eua")
@Data
public class Payments {
    @Id
    @Column(name = "transaction_id")
    private String transactionId;
    private String method;
    private String currency;
    @Column( name = "transaction_time_stamp")
    private String transactionTimestamp;
    @Column(name = "consultation_charge")
    private String consultationCharge="0";
    @Column(name = "phr_handling_fees")
    private String phrHandlingFees="0";
    private String sgst="0";
    private String cgst="0";
    @Column(name = "transaction_state")
    private String transactionState;

    @Column(name = "healthIdNumber")
    private String UserAbhaId;

    @ManyToOne
    @JoinColumn(name = "user_id", referencedColumnName ="id")
    private User user;

}
