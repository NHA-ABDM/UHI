package in.gov.abdm.uhi.common.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.ArrayList;
import java.util.List;

import lombok.Data;

@Data
public class Items {
	public List<Item> Items;
}
