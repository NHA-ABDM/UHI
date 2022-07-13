package in.gov.abdm.uhi.hspa.models.opemMRSModels;

import lombok.Data;

import java.util.ArrayList;

@Data
public class person {

    public String gender;
    public String age;
    public ArrayList<name> names;
    public ArrayList<address> addresses;
}

