package in.gov.abdm.uhi.EUABookingService.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import lombok.Data;

@Entity
@Table(schema = "eua")
@Data
public class Message {

    @Id
    @GeneratedValue(strategy=GenerationType.AUTO)
    private Long id;

    @Column(nullable = false, columnDefinition = "text")
    private String messageId;

    @Column(nullable = false, columnDefinition = "text")
    private String consumerId;

    @Column(columnDefinition = "text")
    private String response;


    @Column(nullable = false)
    private String dhpQueryType;

    @Column(nullable = false)
    private String createdAt;

    @ManyToOne
    @JoinColumn(name = "user_id", referencedColumnName = "id")
    private User user;

    @ManyToOne
    @JoinColumn(name = "mac_id", referencedColumnName = "mac_id")
    private UserDevice userDevice;

}
