/**
 * mx.com.bwr.sat.utils
 */
package mx.com.bwr.sat.utils;

import org.apache.log4j.Logger;

/**
 * @author Jorge Vargas
 * Clase encargada del archivo log
 */
public class LoggerSAT {

	static Logger log;

	static {
		try {
			log = Logger.getLogger(LoggerSAT.class.getName());
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	/**
	 * Imprime un mensaje de tipo INFO
	 * @param message :Mensaje a imprimr
	 */
	public static void printLine(String message) {
		log.info(message);
	}

	/**
	 * Imprime un mensaje de tipo ERROR
	 * @param message :Mensaje a imprimir
	 */
	public static void printError(String message) {
		log.error(message);
	}
	
	/**
	 * Imprime el stack trace como un mensaje de tipo ERROR
	 * @param clase :Clase donde ocurrio el error
	 * @param ex :StackTrace
	 */
	public static void printError(Object clase, Throwable ex) {
		log.error(clase, ex);
		
	}
}
