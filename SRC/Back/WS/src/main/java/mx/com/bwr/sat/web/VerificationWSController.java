/**
 * mx.com.bwr.sat.web
 */
package mx.com.bwr.sat.web;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

import mx.com.bwr.sat.soap.SOAPClient;
import mx.com.bwr.sat.soap.SOAPVerification;
import mx.com.bwr.sat.utils.LoggerSAT;

/**
 * @author Jorge Vargas
 * Controlador encargado de recibir la peticion para la verificacion de una solicitud de CFDI o Metadata del webservice del SAT
 */
@EnableWebMvc
@RestController
public class VerificationWSController {

	private static final String URL_VERIFICATION = "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/VerificaSolicitudDescargaService.svc";
	private static final String URL_VERIFICATION_ACTION = "http://DescargaMasivaTerceros.sat.gob.mx/IVerificaSolicitudDescargaService/VerificaSolicitudDescarga";
	
	/**
	 * Metodo encargado de hacer la verificacion de una solicitud de CFDI o Metadata webservice del SAT. http://[HOST]:[PORT]/SATWS//verifica 
	 * @param token :token para la validacion de la peticion en el webservice del SAT
	 * @param rfc :RFC del solicitante
	 * @param idRequisition :id de la solicitud a verificar
	 * @param passPhrase :Password de la FIEL
	 * @param files :Array con los archivos de la FIEL (llave privada y certificado)
	 * @return Regresa un JSON con los atributos relevantes de la respuesta del webservice del sat, o con los errores del sistema
	 */
	@PostMapping(value="/verifica", produces = "application/json")
    public ResponseEntity<Map<String, Object>> verify(
    		@RequestHeader("Authorization") String token,
    		@RequestParam(value = "rfc", required = true) String rfc,
    		@RequestParam(value = "idSolicitud", required = true) String idRequisition,
    		@RequestParam(value = "password", required = true) String passPhrase,
    		@RequestParam("file") MultipartFile[] files){

		Map<String, Object> response = new HashMap<>();
		try {
			SOAPClient soapClient = new SOAPVerification(URL_VERIFICATION, URL_VERIFICATION_ACTION, token, files, passPhrase, rfc, idRequisition);
        	soapClient.validateData();
        	soapClient.createSoapEnvelope();
        	soapClient.callSoapWebService();
        	response.putAll(soapClient.result());
            
	        return new ResponseEntity<Map<String, Object>>(response, HttpStatus.OK);
		} catch(Exception e) {
			LoggerSAT.printError("mx.com.bwr.sat.web.VerificationWSController", e);
        	response.put("error", e.getMessage());
        	return new ResponseEntity<Map<String, Object>>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
	}
}
