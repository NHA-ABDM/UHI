package in.gov.abdm.uhi.hspa.models.opemMRSModels;

import lombok.Data;

import java.util.ArrayList;

@Data
public class patient {

    public ArrayList<identifier> identifiers;
    public person person;

}
