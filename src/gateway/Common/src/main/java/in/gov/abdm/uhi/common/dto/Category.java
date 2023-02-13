package in.gov.abdm.uhi.common.dto;

import java.util.Objects;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown=true)
public class Category {
	private String id;
	private String parent_category_id;
	private Descriptor descriptor;
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Category other = (Category) obj;
		return Objects.equals(descriptor, other.descriptor)
				&& Objects.equals(parent_category_id, other.parent_category_id);
	}
	@Override
	public int hashCode() {
		return Objects.hash(descriptor, parent_category_id);
	}

	

}
