/**
 * mx.com.bwr.sat.soap
 */
package mx.com.bwr.sat.soap;

import java.security.cert.X509Certificate;
import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.xml.soap.SOAPBody;

import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.web.multipart.MultipartFile;
import org.w3c.dom.Node;

import mx.com.bwr.sat.utils.SOAPUtilities;
import mx.com.bwr.sat.utils.Utilities;

/**
 * @author Jorge Vargas
 * Clase encargada de realizar la peticion SOAP para el webservice de solicitud del SAT y asi solicitar los metadatos o el cfdi
 */
public class SOAPRequest extends SOAPClient {

	//campos que nos serviran como llaves para reemplazarlas en el template del XML de esta peticion
	public static String BEGIN_DATE = "{{BEGIN_DATE}}";
	public static String END_DATE = "{{END_DATE}}";
	public static String RFC = "{{RFC}}";
	public static String RFC_EMITTED = "{{RFC_EMITTED}}";
	public static String RFC_RECEIVED = "{{RFC_RECEIVED}}";
	public static String TYPE_REQUEST = "{{TYPE_REQUEST}}";
	public static String CERTIFICADO = "{{CERTIFICADO}}";
	public static String DIGEST_VALUE = "{{DIGEST_VALUE}}";
	public static String SIGNATURE_VALUE = "{{SIGNATURE_VALUE}}";
	public static String ISSUER = "{{ISSUER}}";
	public static String SERIAL_NUMBER = "{{SERIAL_NUMBER}}";
	
	//campos para definir el tipo de solicitud
	public static String CFDI_TYPE = "CFDI";
	public static String METADATA_TYPE = "Metadata";
	
	//campos para definir el criterio de busqueda, solo datos emitidos o solo datos recibidos
	public static int SEARCH_TYPE_EMITTED = 1;
	public static int SEARCH_TYPE_RECEIVED = 2;
	
	private String beginDate;
	private String endDate;
	private String rfc;
	private String requestType;
	private String passPhrase;
	private int searchType;
	
	/**
	 * @param endPoint :URL a la que se le hara la peticion
	 * @param soapAction :Accion del SOAP que se debera invocar
	 * @param authorization :Solo en caso de ya tener un token, este se utilizara para la validacion de la peticion
	 * @param files :Archivos con la llave privada y el certificado de la FIEL
	 * @param passPhrase :Password de la FIEL
	 * @param beginDate :Fecha de inicio a partir del cual se hara la solicitud de los datos
	 * @param endDate :Fecha final a partir del cual se hara la solicitud de los datos
	 * @param rfc :RFC a partir del cual se hara la solicitud de los datos y que tambien se ocupara como dato 
	 * para filtrar solo Metadata o CFDI emitido o reibido, de acuerdo al tipo de busqueda definido en searchType
	 * @param requestType :Tipo de solicitud que se realizara al SAT, CFDI o Metadata
	 * @param searchType :Tipo de filtro para obtener solo CFDI o Metadata recibido [SEARCH_TYPE_EMITTED] o emitido [SEARCH_TYPE_RECEIVED]
	 * @throws Exception
	 */
	public SOAPRequest(String endPoint, String soapAction, String authorization, MultipartFile[] files,
			String passPhrase, String beginDate, String endDate, String rfc, String requestType, int searchType)
			throws Exception {
		super(endPoint, soapAction, authorization, files);
		this.beginDate = beginDate;
		this.endDate = endDate;
		this.rfc = rfc;
		this.requestType = requestType;
		this.passPhrase = passPhrase;
		this.searchType = searchType;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see mx.com.bwr.sat.soap.SOAPClient#createSoapEnvelope()
	 */
	@Override
	public void createSoapEnvelope() throws Exception {
		//obtenemos los valores para el rfc emisor y receptor
		String rfcEmit = "";
		String rfcRece = "";
		if(searchType == SEARCH_TYPE_EMITTED) {
			rfcEmit = rfc;
		} else {
			rfcRece = rfc;
		}
		// obtenemos el template del xml de la peticion soap para autenticar
		String text = SOAPUtilities.getXMLTemplate("SOAPRequest.xml");
		// obtenemos el base 64 del certificado
		String certificate = Base64.getEncoder().encodeToString(cert);
		// obtenemos el valor del digest
		String digest = createDigest(new String[] { rfcEmit, rfcRece, rfc, beginDate, endDate, requestType });
		//obtenemos el signature
		String signature = createSignature(digest);
		//obtenemos una instancia del objeto para certificados
		X509Certificate certificateX = SOAPUtilities.generateCertificateObject(cert);
		//obtenemos el issuer
		String issuer = SOAPUtilities.getIssuer(certificateX);
		//obtenemos el serialnumber
		String serialNumber = SOAPUtilities.getSerialNumber(certificateX);
		
		// reemplazamos las cadenas
		text = text.replace(BEGIN_DATE, beginDate);
		text = text.replace(END_DATE, endDate);
		text = text.replace(RFC, rfc);
		text = text.replace(RFC_EMITTED, rfcEmit);
		text = text.replace(RFC_RECEIVED, rfcRece);
		text = text.replace(TYPE_REQUEST, requestType);
		text = text.replace(CERTIFICADO, certificate);
		text = text.replace(DIGEST_VALUE, digest);
		text = text.replace(SIGNATURE_VALUE, signature);
		text = text.replace(ISSUER, issuer);
		text = text.replace(SERIAL_NUMBER, serialNumber);

		//quitamos todas las identaciones, para pasar todo el xml a una linea
		text = text.replaceAll("[\\r\\n\\t]", "").trim();
		//pasamos nuestra cadena de texto a un objeto valido SOAP e inicializamos los headers de la peticion
		initHeadersSOAPRequest(text);
	}

	/* (non-Javadoc)
	 * @see mx.com.bwr.sat.soap.SOAPClient#result()
	 */
	@Override
	public Map<String, Object> result() throws Exception  {
		SOAPBody body;
		Map<String, Object> response = new HashMap<String, Object>();
		try {
			body = soapResponse.getSOAPBody();
			// verificamos si la respuesta fue exitosa, comprobando si se encuentra el nodo
			// SolicitaDescargaResult
			if (body.getElementsByTagName("SolicitaDescargaResult").getLength() > 0) {
				Node node = body.getElementsByTagName("SolicitaDescargaResult").item(0);
				// en caso de que la peticion halla sido exitosa se tendra que tener el id de la
				// solicitud
				if (node.getAttributes().getNamedItem("IdSolicitud") != null) {
					response.put("id_solicitud", node.getAttributes().getNamedItem("IdSolicitud").getNodeValue());
				}
				// en caso de error o succes siempre se regresa el mensaje y el cod(no en todos)
				response.put("cod_estatus",
						node.getAttributes().getNamedItem("CodEstatus") != null
								? node.getAttributes().getNamedItem("CodEstatus").getNodeValue()
								: "");
				response.put("mensaje",
						node.getAttributes().getNamedItem("Mensaje") != null
								? node.getAttributes().getNamedItem("Mensaje").getNodeValue()
								: "");
			} else {
				// en caso de no encontrar el nodo anterior, regresamos la respuesta tal cual
				// nos la devuelve el sat
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
		//validamos el password
		if(passPhrase == null || passPhrase.isEmpty()) {
			throw new Exception("El parametro 'password' no esta definido");
		}
		if(authorization == null || authorization.isEmpty()) {
			throw new Exception("El header 'Authorization' no esta definido");
		}
		
		String format = "yyyy-MM-dd HH:mm:ss";
		//hacemos los trims en todos los campos
		beginDate = beginDate.trim();
		endDate = endDate.trim();
		rfc = rfc.trim().toUpperCase();
		requestType = requestType.trim();
		//validamos las fechas
		if(!Utilities.validateStringDate(beginDate) || !Utilities.validateStringDate(endDate)) {
			throw new Exception("Las fechas tienen un formato incorrecto. Formato valido: " + format);
		} else {
			SimpleDateFormat formatter = new SimpleDateFormat(format);
			//convertimos las fechas a un objeto date, para validar el periodo
			Date begin = formatter.parse(beginDate);
			Date end = formatter.parse(endDate);
			if(begin.after(end)) {
				throw new Exception("El periodo es invalido");
			}
			beginDate = beginDate.replace(" ", "T");
			endDate = endDate.replace(" ", "T");
		}
		//validamos el rfc
		if(!Utilities.validateRFC(rfc)) {
			throw new Exception("RFC invalido");
		}
		//validamos el tipo de solicitud CFDI o Metadata
		if(!requestType.equalsIgnoreCase(CFDI_TYPE) && !requestType.equalsIgnoreCase(METADATA_TYPE)) {
			throw new Exception("El tipo de solicitud es invalido");
		} else {
			//ya que el tipo de solicitud no es case sensitive en nuestra peticion, seteamso el valor correcto
			if(requestType.equalsIgnoreCase(CFDI_TYPE)) {
				requestType = CFDI_TYPE;
			} else {
				requestType = METADATA_TYPE;
			}
		}
		//validamos el tipo de busqueda
		if(!(searchType == SEARCH_TYPE_EMITTED || searchType == SEARCH_TYPE_RECEIVED)) {
			throw new Exception("El tipo de busqueda es invalido. (Por RFC emisor: 1; Por RFC receptor: 2)");
		}
	}

	/* (non-Javadoc)
	 * @see mx.com.bwr.sat.soap.SOAPClient#createDigest()
	 */
	@Override
	public String createDigest(String[] params) throws Exception {
		// obtenemos el valor del digest
		try {
			String digest = "<des:SolicitaDescarga xmlns:des=\"http://DescargaMasivaTerceros.sat.gob.mx\"><des:solicitud RfcEmisor=\""
				+ params[0] + "\" RfcReceptor=\"" + params[1] + "\" RfcSolicitante=\"" + params[2] + "\" FechaInicial=\"" + params[3]
				+ "\" FechaFinal=\"" + params[4] + "\" TipoSolicitud=\"" + params[5]
				+ "\"></des:solicitud></des:SolicitaDescarga>";
			return Base64.getEncoder().encodeToString(DigestUtils.sha1(digest.getBytes("UTF-8")));
		} catch (Exception e) {
			throw new Exception("Error al cifrar los datos");
		}
	}

	/* (non-Javadoc)
	 * @see mx.com.bwr.sat.soap.SOAPClient#createSignature()
	 */
	@Override
	public String createSignature(String digest) throws Exception {
		String signature = "<SignedInfo xmlns=\"http://www.w3.org/2000/09/xmldsig#\">"
				+ "<CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\">"
				+ "</CanonicalizationMethod><SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\">"
				+ "</SignatureMethod><Reference URI=\"\"><Transforms>"
				+ "<Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"></Transform></Transforms>"
				+ "<DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"></DigestMethod><DigestValue>" + digest
				+ "</DigestValue></Reference></SignedInfo>";
		return SOAPUtilities.sign(signature, privateKey, passPhrase);
	}

}
