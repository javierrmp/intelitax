/**
 * mx.com.bwr.sat.utils
 */
package mx.com.bwr.sat.utils;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author Jorge Vargas
 * Clase con varios metodos que ocupara el sistema
 */
public class Utilities {

	private static final String DATE_PATTERN = "((19|20)\\d\\d)-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01]) [0-2]\\d:[0-5]\\d:[0-5]\\d";
	private static final String RFC_PATTERN = "([A-Z,Ñ,&]{3,4}([0-9]{2})(0[1-9]|1[0-2])(0[1-9]|1[0-9]|2[0-9]|3[0-1])[A-Z|\\d]{3})";

	/**
	 * Funcion que valida una fecha
	 * @param date :Cadena de texto con la fecha a validar
	 * @return true en caso de que la fecha sea valida, false en cuaquier otro caso
	 */
	public static boolean validateStringDate(String date) {
		Pattern pattern = Pattern.compile(DATE_PATTERN);
		Matcher matcher = pattern.matcher(date);

		if (matcher.matches()) {
			matcher.reset();
			if (matcher.find()) {
				String day = matcher.group(1);
				String month = matcher.group(2);
				int year = Integer.parseInt(matcher.group(3));
				if (day.equals("31") && (month.equals("4") || month.equals("6") || month.equals("9")
						|| month.equals("11") || month.equals("04") || month.equals("06") || month.equals("09"))) {
					return false; // only 1,3,5,7,8,10,12 has 31 days
				} else if (month.equals("2") || month.equals("02")) {
					// leap year
					if (year % 4 == 0) {
						if (day.equals("30") || day.equals("31")) {
							return false;
						} else {
							return true;
						}
					} else {
						if (day.equals("29") || day.equals("30") || day.equals("31")) {
							return false;
						} else {
							return true;
						}
					}
				} else {
					return true;
				}
			} else {
				return false;
			}
		} else {
			return false;
		}
	}
	
	//  /^([A-Z,Ñ,&]{3,4}([0-9]{2})(0[1-9]|1[0-2])(0[1-9]|1[0-9]|2[0-9]|3[0-1])[A-Z|\d]{3})$/
	/**
	 * Funcion que valida un RFC
	 * @param rfc :Cadena de texto con el RFC a validar
	 * @return true en caso de que el RFC sea valido, false en cualquier otro caso
	 */
	public static boolean validateRFC(String rfc) {
		Pattern pattern = Pattern.compile(RFC_PATTERN);
		Matcher matcher = pattern.matcher(rfc);

		return matcher.matches();
	}

}
