package in.gov.abdm.uhi.hspa.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import in.gov.abdm.uhi.hspa.utils.ConstantsUtils;
import lombok.Data;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(schema = ConstantsUtils.HSPA_SCHEMA_NAME, name = "Messages")
@Data
@JsonDeserialize(using = LocalDateTimeDeserializer.class)
@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
public class MessagesModel {
    @Id
    @Column(name = "content_id")
    private String contentId;
    
    @Column(name = "sender")
    private String sender;
    
    @Column(name = "receiver")
    private String receiver;
    
    @Column(name = "time")
    private LocalDateTime time;

    @Column(name = "consumer_url")
    private String consumerUrl;

    @Column(name = "provider_url")
    private String providerUrl;

    @Column(name = "content_value",length = 50000)
    private String contentValue;

    @Column(name = "content_type")
    private String contentType;

    @Column(name = "content_url",length = 50000)
    private String contentUrl;
    

}
