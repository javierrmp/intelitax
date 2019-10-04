/**
 * package mx.com.bwr.sat.web; 
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

import mx.com.bwr.sat.soap.SOAPRequest;
import mx.com.bwr.sat.utils.LoggerSAT;
import mx.com.bwr.sat.soap.SOAPClient;

/**
 * 
 * @author Jorge Vargas
 * Controlador encargado de recibir la peticion para la solicitud de CFDI o Metadata del webservice del SAT
 */
@EnableWebMvc
@RestController
public class RequestWSController {

	private static final String URL_REQUEST = "https://cfdidescargamasivasolicitud.clouda.sat.gob.mx/SolicitaDescargaService.svc";
	private static final String URL_REQUEST_ACTION = "http://DescargaMasivaTerceros.sat.gob.mx/ISolicitaDescargaService/SolicitaDescarga";
	
	/**
	 * Metodo encargado de hacer la solicitud a traves del webservice del SAT. http://[HOST]:[PORT]/SATWS/solicita
	 * @param token :token para la validacion de la peticion en el webservice del SAT
	 * @param beginDate :Fecha de inicio a partir del cual se hara la solicitud de los datos
	 * @param endDate :Fecha final a partir del cual se hara la solicitud de los datos
	 * @param rfc :RFC del solicitante
	 * @param searchType :Tipo de filtro para obtener solo CFDI o Metadata recibido [SEARCH_TYPE_RECEIVED] o emitido [SEARCH_TYPE_EMITTED]
	 * @param requestType :Tipo de solicitud que se realizara al SAT, CFDI o Metadata
	 * @param passPhrase :Password de la FIEL
	 * @param files :Array con los archivos de la FIEL (llave privada y certificado)
	 * @return Regresa un JSON con los atributos relevantes de la respuesta del webservice del sat, o con los errores del sistema
	 */
	@PostMapping(value="/solicita", produces = "application/json")
    public ResponseEntity<Map<String, Object>> solicita(
    		@RequestHeader("Authorization") String token,
    		@RequestParam(value = "fechaInicio", required = true) String beginDate,
    		@RequestParam(value = "fechaFin", required = true) String endDate,
    		@RequestParam(value = "rfc", required = true) String rfc,
    		@RequestParam(value = "tipoBusqueda", required = true) int searchType,
    		@RequestParam(value = "tipoSolicitud", required = true) String requestType,
    		@RequestParam(value = "password", required = true) String passPhrase,
    		@RequestParam("file") MultipartFile[] files){

		Map<String, Object> response = new HashMap<>();
		try {
			SOAPClient soapClient = new SOAPRequest(URL_REQUEST, URL_REQUEST_ACTION, token, files, passPhrase, beginDate, endDate, rfc, requestType, searchType);
        	soapClient.validateData();
        	soapClient.createSoapEnvelope();
        	soapClient.callSoapWebService();
        	response.putAll(soapClient.result());
            
	        return new ResponseEntity<Map<String, Object>>(response, HttpStatus.OK);
		} catch(Exception e) {
			LoggerSAT.printError("mx.com.bwr.sat.web.RequestWSController", e);
        	response.put("error", e.getMessage());
        	return new ResponseEntity<Map<String, Object>>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
	}
}
