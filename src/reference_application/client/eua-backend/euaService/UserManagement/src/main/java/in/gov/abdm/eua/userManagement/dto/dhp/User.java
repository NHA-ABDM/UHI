package in.gov.abdm.eua.userManagement.dto.dhp;

import java.security.Principal;

public class User implements Principal {
    private final String name;

    public User(String name) {
        this.name = name;
    }

    @Override
    public String getName() {
        return name;
    }
}
