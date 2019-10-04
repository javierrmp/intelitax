/**
 * mx.com.bwr.sat.web
 */
package mx.com.bwr.sat.web;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

import mx.com.bwr.sat.soap.SOAPClient;
import mx.com.bwr.sat.soap.SOAPDownload;
import mx.com.bwr.sat.utils.LoggerSAT;

/**
 * @author Jorge Vargas
 * Controlador encargado de recibir la peticion para la descarga del webservice del SAT
 */
@EnableWebMvc
@RestController
public class DownloadWSController {

	private static final String URL_VERIFICATION = "https://cfdidescargamasiva.clouda.sat.gob.mx/DescargaMasivaService.svc";
	private static final String URL_VERIFICATION_ACTION = "http://DescargaMasivaTerceros.sat.gob.mx/IDescargaMasivaTercerosService/Descargar";

	@Autowired
	private Environment env;
	
	/**
	 * Metodo encargado de hacer la descarga a travez del webservice del SAT. http://[HOST]:[PORT]/SATWS/descarga
	 * @param passPhrase :Password de la FIEL
	 * @param token :token para la validacion de la peticion en el webservice del SAT
	 * @param rfc :RFC del solicitante
	 * @param idPackage :Id del paquete a descargar
	 * @param passPhrase :Password de la FIEL
	 * @param period :Periodo que sera utilizado como parte de la ruta donde se guardara el archivo
	 * @param files :Array con los archivos de la FIEL (llave privada y certificado)
	 * @return Regresa un JSON con los atributos relevantes de la respuesta del webservice del sat, o con los errores del sistema
	 */
	@PostMapping(value="/descarga", produces = "application/json")
    public ResponseEntity<Map<String, Object>> download(
    		@RequestHeader("Authorization") String token,
    		@RequestParam(value = "rfc", required = true) String rfc,
    		@RequestParam(value = "idPaquete", required = true) String idPackage,
    		@RequestParam(value = "password", required = true) String passPhrase,
    		@RequestParam(value = "periodoFolder", required = true) String period,
    		@RequestParam("file") MultipartFile[] files){

		Map<String, Object> response = new HashMap<>();
		try {
			//obtenemos el path relativo donde se guardaran los archivos
			String path = env.getProperty("soap.relative.path.downloads.cfdi");
			SOAPClient soapClient = new SOAPDownload(URL_VERIFICATION, URL_VERIFICATION_ACTION, token, files, passPhrase, rfc, idPackage, path, period);
        	soapClient.validateData();
        	soapClient.createSoapEnvelope();
        	soapClient.callSoapWebService();
        	response.putAll(soapClient.result());
            
	        return new ResponseEntity<Map<String, Object>>(response, HttpStatus.OK);
		} catch(Exception e) {
			LoggerSAT.printError("mx.com.bwr.sat.web.DownloadWSController", e);
        	response.put("error", e.getMessage());
        	return new ResponseEntity<Map<String, Object>>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
	}
}
