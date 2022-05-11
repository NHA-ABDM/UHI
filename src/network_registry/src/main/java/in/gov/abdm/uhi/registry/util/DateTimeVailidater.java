package in.gov.abdm.uhi.registry.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import in.gov.abdm.uhi.registry.exception.InvalidDateTimeException;

public class DateTimeVailidater {

	public static boolean isValid(String validFrom, String validTo) {

		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
		try {
			LocalDate date1 = LocalDate.parse(validFrom, formatter);
			LocalDate date2 = LocalDate.parse(validTo, formatter);
			if(!date1.isAfter(LocalDate.now().minusDays(1))) {
				throw new InvalidDateTimeException("Vlid from should be greater than from current date!");
			}
			if (date1.isBefore(date2)) {
				return true;
			}
		} catch (InvalidDateTimeException  e) {
			throw new InvalidDateTimeException("Vlid from should be greater than from current date!");
			
		}catch (Exception e) {
			e.printStackTrace();
			throw new InvalidDateTimeException("Invalid date formate!");
		}

		return false;
	}

}
