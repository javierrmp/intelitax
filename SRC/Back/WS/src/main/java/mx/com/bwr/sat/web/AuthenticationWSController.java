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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

import mx.com.bwr.sat.soap.SOAPAuthenticate;
import mx.com.bwr.sat.soap.SOAPClient;
import mx.com.bwr.sat.utils.LoggerSAT;
import mx.com.bwr.sat.utils.SOAPUtilities;


/**
 * @author Jorge Vargas
 * Controlador encargado de recibir la peticion para la autenticacion del webservice del SAT
 */
@EnableWebMvc
@RestController
public class AuthenticationWSController {

	@Autowired
	private Environment env;
	
	private static final String URL_AUTH = "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/Autenticacion/Autenticacion.svc";
	private static final String URL_AUTH_ACTION = "http://DescargaMasivaTerceros.gob.mx/IAutenticacion/Autentica";
	/**
	 * Metodo encargado de obtener el token a travez del webservice del SAT. http://[HOST]:[PORT]/SATWS/autentica
	 * @param passPhrase :Password de la FIEL
	 * @param files :Array con los archivos de la FIEL (llave privada y certificado)
	 * @return Regresa un JSON con los atributos relevantes de la respuesta del webservice del sat, o con los errores del sistema
	 */
	@PostMapping(value="/autentica", produces = "application/json")
    public ResponseEntity<Map<String, Object>> authenticate(
    		@RequestParam(value = "password", required = true) String passPhrase,
    		@RequestParam("file") MultipartFile[] files){
		Map<String, Object> response = new HashMap<>();
        try {
        	//obtenemos el parametro del tiempo de session
        	long sessionTimeOut = SOAPUtilities.parseLong(env.getProperty("soap.authenticate.props.session.timeout"));
        	
        	SOAPClient soapClient = new SOAPAuthenticate(URL_AUTH, URL_AUTH_ACTION, null, files, passPhrase, sessionTimeOut);
        	soapClient.validateData();
        	soapClient.createSoapEnvelope();
        	soapClient.callSoapWebService();
        	response.putAll(soapClient.result());
            
	        return new ResponseEntity<Map<String, Object>>(response, HttpStatus.OK);
        } catch(Exception e) {
        	LoggerSAT.printError("mx.com.bwr.sat.web.AuthenticationWSController", e);
        	response.put("error", e.getMessage());
        	return new ResponseEntity<Map<String, Object>>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
	
}
