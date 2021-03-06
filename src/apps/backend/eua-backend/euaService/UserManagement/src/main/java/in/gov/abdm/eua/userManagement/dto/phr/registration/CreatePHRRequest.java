/*
 * Patient Health Record Service
 * Create your PHR ID to track your health records in one place.
 *
 *  *
 *
 * NOTE: This class is auto generated by the swagger code generator program.
 * https://github.com/swagger-api/swagger-codegen.git
 * Do not edit the class manually.
 */
package in.gov.abdm.eua.userManagement.dto.phr.registration;


import javax.validation.constraints.NotNull;

/**
 * CreatePHRRequest
 */

public class CreatePHRRequest {
    private Boolean alreadyExistedPHR;

    private Object password;

    @NotNull(message = "PhrAddress cannot be null")
    private Object phrAddress;

    @NotNull(message = "sessionId cannot be null")
    private Object sessionId;


}
