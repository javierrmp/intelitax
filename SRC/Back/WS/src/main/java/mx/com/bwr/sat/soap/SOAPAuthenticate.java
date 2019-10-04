/**
 * mx.com.bwr.sat.soap
 */
package mx.com.bwr.sat.soap;

import java.io.UnsupportedEncodingException;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import javax.xml.soap.SOAPBody;

import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.web.multipart.MultipartFile;

import mx.com.bwr.sat.utils.SOAPUtilities;

/**
 * @author Jorge Vargas
 * Clase encargada de realizar la peticion SOAP para el webservice de autenticacion del SAT y asi obtener un token 
 */
public class SOAPAuthenticate extends SOAPClient {

	//campos que nos serviran como llaves para reemplazarlas en el template del XML de esta peticion
	public static String BEGIN_DATE = "{{BEGIN_DATE}}";
	public static String END_DATE = "{{END_DATE}}";
	public static String CERTIFICADO = "{{CERTIFICADO}}";
	public static String DIGEST_VALUE = "{{DIGEST_VALUE}}";
	public static String SIGNATURE_VALUE = "{{SIGNATURE_VALUE}}";
	public static String UUID_STR = "\\{\\{UUID\\}\\}";
	
	
	private String passPhrase;
	private long sessionTimeOut;
	
	/**
	 * 
	 * @param endPoint :URL a la que se le hara la peticion
	 * @param soapAction :Accion del SOAP que se debera invocar
	 * @param authorization :Solo en caso de ya tener un token, este se utilizara para la validacion de la peticion
	 * @param files :Archivos con la llave privada y el certificado de la FIEL
	 * @param passPhrase :Password de la FIEL
	 * @param sessionTimeOut :Tiempo maximo en segundos que durara el token (Valor maximo aceptado 5min)
	 * @throws Exception
	 */
	public SOAPAuthenticate(String endPoint, String soapAction, String authorization, MultipartFile[] files, String passPhrase, long sessionTimeOut) throws Exception {
		super(endPoint, soapAction, authorization, files);
		this.passPhrase = passPhrase;
		this.sessionTimeOut = sessionTimeOut;
	}

	/* (non-Javadoc)
	 * @see mx.com.bwr.sat.soap.SOAPClient#createSoapEnvelope()
	 */
	@Override
	public void createSoapEnvelope() throws Exception {
		// obtenemos todos los parametros que debera de ir en la peticion
		ZonedDateTime utcBegin = ZonedDateTime.now(ZoneOffset.UTC);
		ZonedDateTime utcEnd = utcBegin.plusSeconds(sessionTimeOut);
		//fechas para el tiempo de sesion
		String beginDate = utcBegin.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"));
		String endDate = utcEnd.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"));

		String uuid = "uuid-" + UUID.randomUUID().toString() + "-1";
		
		String certificate = Base64.getEncoder().encodeToString(cert);

		// obtenemos el template del xml de la peticion soap para autenticar
		String text = SOAPUtilities.getXMLTemplate("SOAPAuthenticate.xml");
		// reemplazamos las cadenas
		text = text.replaceAll(UUID_STR, uuid);
		text = text.replace(BEGIN_DATE, beginDate);
		text = text.replace(END_DATE, endDate);
		text = text.replace(CERTIFICADO, certificate);
		// obtenmos la parte del digest value
		String digest = createDigest(new String[]{beginDate, endDate});
		text = text.replace(DIGEST_VALUE, digest);

		// obtenemos el signature
		String signature = createSignature(digest);
		text = text.replace(SIGNATURE_VALUE, signature);
		text = text.replaceAll("[\\r\\n\\t]", "").trim();
		
		initHeadersSOAPRequest(text);
	}

	/* (non-Javadoc)
	 * @see mx.com.bwr.sat.soap.SOAPClient#result()
	 */
	@Override
	public Map<String, Object> result() throws Exception {
		SOAPBody body;
		Map<String, Object> response = new HashMap<String, Object>();
		try {
			body = soapResponse.getSOAPBody();
			//verificamos si la respuesta fue exitosa, comprobando si se encuentra el nodo Autentica result
			if(body.getElementsByTagName("AutenticaResult").getLength() > 0) {
				 response.put("token", body.getElementsByTagName("AutenticaResult").item(0).getTextContent());
			} else if(body.getElementsByTagName("faultcode").getLength() > 0 && body.getElementsByTagName("faultstring").getLength() > 0) {
				//en caso de error regresamos los valores de los nodos que describen el error
				response.put("fault_code", body.getElementsByTagName("faultcode").item(0).getTextContent());
				response.put("fault_string", body.getElementsByTagName("faultstring").item(0).getTextContent());
			} else {
				//en caso de no encontrar ninguno de los nodos anteriores, regresamos la respuesta tal cual nos la devuelve el sat
				response.put("error", getStringRequest(soapResponse));
			}
		} catch (Exception e) {
			throw new Exception("Imposible leer respuesta SOAP");
		}
		return response;
	}

	/* (non-Javadoc)
	 * @see mx.com.bwr.sat.soap.SOAPClient#validateData()
	 */
	@Override
	public void validateData() throws Exception {
		if(passPhrase == null || passPhrase.isEmpty()) {
			throw new Exception("El parametro 'password' no esta definido");
		}
		sessionTimeOut = sessionTimeOut <= 0 ? 300 : sessionTimeOut;
	}

	/* (non-Javadoc)
	 * @see mx.com.bwr.sat.soap.SOAPClient#createDigest()
	 */
	@Override
	public String createDigest(String[] params) throws Exception  {
		try {
			String digest = "<u:Timestamp "
				+ "xmlns:u=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\""
				+ " u:Id=\"_0\"><u:Created>" + params[0] + "</u:Created><u:Expires>" + params[1] + "</u:Expires></u:Timestamp>";
			return Base64.getEncoder().encodeToString(DigestUtils.sha1(digest.getBytes("UTF-8")));
		} catch (UnsupportedEncodingException e) {
			throw new Exception("Error al cifrar los datos");
		}
	}

	/* (non-Javadoc)
	 * @see mx.com.bwr.sat.soap.SOAPClient#createSignature()
	 */
	@Override
	public String createSignature(String digest) throws Exception {
		String signature = "<SignedInfo xmlns=\"http://www.w3.org/2000/09/xmldsig#\">"
				+ "<CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\">"
				+ "</CanonicalizationMethod><SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\">"
				+ "</SignatureMethod><Reference URI=\"#_0\"><Transforms><Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\">"
				+ "</Transform></Transforms><DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\">"
				+ "</DigestMethod><DigestValue>" + digest + "</DigestValue></Reference></SignedInfo>";
		return SOAPUtilities.sign(signature, privateKey, passPhrase);
	}

}

