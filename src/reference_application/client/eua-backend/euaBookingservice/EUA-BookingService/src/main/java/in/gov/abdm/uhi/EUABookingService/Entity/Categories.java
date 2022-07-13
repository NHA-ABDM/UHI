package in.gov.abdm.uhi.EUABookingService.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.Data;

@Entity
@Table(schema = "eua")
@Data
public class Categories {
	@Id
    @Column(name = "category_id")
    private Long categoryId;

    private String descriptor;

   
}
