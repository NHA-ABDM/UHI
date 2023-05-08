package in.gov.abdm.uhi.registry.util;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Locale;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import in.gov.abdm.uhi.registry.exception.InvalidDateTimeException;

public class DateTimeVailidater {
	private static final Logger logger = LogManager.getLogger(DateTimeVailidater.class);

	public static boolean isValid(String validFrom, String validTo) {

		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.ENGLISH);
		DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd", Locale.ENGLISH);

		try {
			LocalDate localDate = LocalDate.parse(validFrom, formatter);
			outputFormatter.format(localDate);
			LocalDate validDate = LocalDate.parse(validTo, formatter);
			logger.info("DateTimeVailidater::isValid()");
			outputFormatter.format(validDate);
			if (!localDate.isAfter(LocalDate.now().minusDays(1))) {
				logger.info("DateTimeVailidater::isValid()");
				throw new InvalidDateTimeException("Vlid from should be greater than or equal from current date!");
			}
			if (localDate.isBefore(validDate)) {
				return true;
			}
		} catch (InvalidDateTimeException e) {
			logger.info("DateTimeVailidater::isValid()" + e);
			throw new InvalidDateTimeException("Vlid from should be greater than  or equal from current date!");

		} catch (DateTimeParseException e) {
			logger.info("DateTimeVailidater::isValid()" + e);
			throw new InvalidDateTimeException("Invalid date formate!");
		}catch (Exception e) {
			logger.info("DateTimeVailidater::isValid()" + e);
		}

		return false;
	}

}
