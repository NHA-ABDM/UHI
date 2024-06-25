package in.gov.abdm.uhi.hspa.models.opemMRSModels;

import lombok.Data;

import java.util.ArrayList;
import java.util.LinkedList;

@Data
public class person {

    public String gender;
    public String age;
    public LinkedList<name> names;
    public LinkedList<address> addresses;
}

