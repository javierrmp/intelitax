/**
 * mx.com.bwr.sat.soap
 */
package mx.com.bwr.sat.soap;

import java.io.UnsupportedEncodingException;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.soap.SOAPBody;

import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.web.multipart.MultipartFile;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import mx.com.bwr.sat.utils.SOAPUtilities;
import mx.com.bwr.sat.utils.Utilities;

/**
 * @author Jorge Vargas
 * Clase encargada de realizar la peticion SOAP para el webservice de verificacion del SAT y asi comprobar el estatus de la solicitud
 */
public class SOAPVerification extends SOAPClient {

	//campos que nos serviran como llaves para reemplazarlas en el template del XML de esta peticion
	public static String RFC = "{{RFC}}";
	public static String ID_REQUISITION = "{{ID_REQUISITION}}";
	public static String CERTIFICADO = "{{CERTIFICADO}}";
	public static String DIGEST_VALUE = "{{DIGEST_VALUE}}";
	public static String SIGNATURE_VALUE = "{{SIGNATURE_VALUE}}";
	public static String ISSUER = "{{ISSUER}}";
	public static String SERIAL_NUMBER = "{{SERIAL_NUMBER}}";
	
	private String rfc;
	private String idRequisition;
	private String passPhrase;
	
	/**
	 * 
	 * @param endPoint :URL a la que se le hara la peticion
	 * @param soapAction :Accion del SOAP que se debera invocar
	 * @param authorization :Solo en caso de ya tener un token, este se utilizara para la validacion de la peticion
	 * @param files :Archivos con la llave privada y el certificado de la FIEL
	 * @param passPhrase :Password de la FIEL
	 * @param rfc :RFC del solicitante
	 * @param idRequisition :id de la solicitud obtenido del webservice de solicitud {@link SOAPRequest}
	 * @throws Exception
	 */
	public SOAPVerification(String endPoint, String soapAction, String authorization, MultipartFile[] files, String passPhrase, String rfc, String idRequisition) throws Exception {
		super(endPoint, soapAction, authorization, files);
		this.rfc = rfc;
		this.idRequisition = idRequisition;
		this.passPhrase = passPhrase;
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
		rfc = rfc.trim().toUpperCase();
		idRequisition = idRequisition.trim();
		//validamos el rfc
		if(!Utilities.validateRFC(rfc)) {
			throw new Exception("RFC invalido");
		}
		if(idRequisition == null || idRequisition.isEmpty()) {
			throw new Exception("El parametro 'idSolicitud' no esta definido");
		}
	}

	/* (non-Javadoc)
	 * @see mx.com.bwr.sat.soap.SOAPClient#createSoapEnvelope()
	 */
	@Override
	public void createSoapEnvelope() throws Exception {
		// obtenemos el template del xml de la peticion soap para autenticar
		String text = SOAPUtilities.getXMLTemplate("SOAPVerification.xml");
		// obtenemos el base 64 del certificado
		String certificate = Base64.getEncoder().encodeToString(cert);
		// obtenemos el valor del digest
		String digest = createDigest(new String[] { idRequisition, rfc });
		//obtenemos el signature
		String signature = createSignature(digest);
		//obtenemos una instancia del objeto para certificados
		X509Certificate certificateX = SOAPUtilities.generateCertificateObject(cert);
		//obtenemos el issuer
		String issuer = SOAPUtilities.getIssuer(certificateX);
		//obtenemos el serialnumber
		String serialNumber = SOAPUtilities.getSerialNumber(certificateX);
		
		text = text.replace(ID_REQUISITION, idRequisition);
		text = text.replace(RFC, rfc);
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
	 * @see mx.com.bwr.sat.soap.SOAPClient#createDigest(java.lang.String[])
	 */
	@Override
	public String createDigest(String[] params) throws Exception {
		// obtenemos el valor del digest
		try {
			String digest = "<des:VerificaSolicitudDescarga xmlns:des=\"http://DescargaMasivaTerceros.sat.gob.mx\">"
                + "<des:solicitud IdSolicitud=\"" + params[0] + "\" RfcSolicitante=\"" + params[1] + ">"
                + "</des:solicitud></des:VerificaSolicitudDescarga>";
			return Base64.getEncoder().encodeToString(DigestUtils.sha1(digest.getBytes("UTF-8")));
		} catch (UnsupportedEncodingException e) {
			throw new Exception("Error al cifrar los datos");
		}
	}

	/* (non-Javadoc)
	 * @see mx.com.bwr.sat.soap.SOAPClient#createSignature(java.lang.String)
	 */
	@Override
	public String createSignature(String digest) throws Exception {
		String signature = "<SignedInfo xmlns=\"http://www.w3.org/2000/09/xmldsig#\">"
				+ "<CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"></CanonicalizationMethod>"
				+ "<SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"></SignatureMethod>"
				+ "<Reference URI=\"#_0\"><Transforms><Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\">"
				+ "</Transform></Transforms><DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"></DigestMethod>"
				+ "<DigestValue>" + digest + "</DigestValue></Reference></SignedInfo>";
		return SOAPUtilities.sign(signature, privateKey, passPhrase);
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
			// verificamos la respuesta, comprobando si se encuentra el nodo
			// VerificaSolicitudDescargaResult 
			if (body.getElementsByTagName("VerificaSolicitudDescargaResult").getLength() > 0) {
				Node node = body.getElementsByTagName("VerificaSolicitudDescargaResult").item(0);
				// comprobamos cada uno de los atributos para ver si los regresamos en la respuesta final
				if (node.getAttributes().getNamedItem("CodEstatus") != null) {
					response.put("cod_estatus", node.getAttributes().getNamedItem("CodEstatus").getNodeValue());
				}
				if (node.getAttributes().getNamedItem("EstadoSolicitud") != null) {
					response.put("estado_solicitud", node.getAttributes().getNamedItem("EstadoSolicitud").getNodeValue());
				}
				if (node.getAttributes().getNamedItem("CodigoEstadoSolicitud") != null) {
					response.put("codigo_estado_solicitud", node.getAttributes().getNamedItem("CodigoEstadoSolicitud").getNodeValue());
				}
				if (node.getAttributes().getNamedItem("NumeroCFDIs") != null) {
					response.put("numero_cfdis", node.getAttributes().getNamedItem("NumeroCFDIs").getNodeValue());
				}
				if (node.getAttributes().getNamedItem("Mensaje") != null) {
					response.put("mensaje", node.getAttributes().getNamedItem("Mensaje").getNodeValue());
				}
				//en caso de que la solicitud este lista comprobamos los ids de los paquetes generados
				if (body.getElementsByTagName("IdsPaquetes").getLength() > 0) {
					List<String> packages = new ArrayList<>();
					response.put("ids_paquetes", packages);
					NodeList nodeList = body.getElementsByTagName("IdsPaquetes");
					for(int i = 0; i < nodeList.getLength(); i++) {
						packages.add(nodeList.item(i).getTextContent());
					}
				}
				
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

}
