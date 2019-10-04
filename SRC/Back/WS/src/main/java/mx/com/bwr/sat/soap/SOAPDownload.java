/**
 * mx.com.bwr.sat.soap
 */
package mx.com.bwr.sat.soap;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.cert.X509Certificate;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPHeader;

import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.web.multipart.MultipartFile;
import org.w3c.dom.Node;

import mx.com.bwr.sat.utils.SOAPUtilities;
import mx.com.bwr.sat.utils.Utilities;

/**
 * @author Jorge Vargas
 * Clase encargada de realizar la peticion SOAP para el webservice de descarga del SAT y asi obtener un archivo zip que sera
 * guardado dentro del server 
 */
public class SOAPDownload extends SOAPClient {

	//campos que nos serviran como llaves para reemplazarlas en el template del XML de esta peticion
	public static String RFC = "{{RFC}}";
	public static String ID_PACKAGE = "{{ID_PACKAGE}}";
	public static String CERTIFICADO = "{{CERTIFICADO}}";
	public static String DIGEST_VALUE = "{{DIGEST_VALUE}}";
	public static String SIGNATURE_VALUE = "{{SIGNATURE_VALUE}}";
	public static String ISSUER = "{{ISSUER}}";
	public static String SERIAL_NUMBER = "{{SERIAL_NUMBER}}";
	
	private String rfc;
	private String idPackage;
	private String passPhrase;
	private String pathFile;
	private String period;
	
	/**
	 * 
	 * @param endPoint :URL a la que se le hara la peticion
	 * @param soapAction :Accion del SOAP que se debera invocar
	 * @param authorization :Solo en caso de ya tener un token, este se utilizara para la validacion de la peticion
	 * @param files :Archivos con la llave privada y el certificado de la FIEL
	 * @param passPhrase :Password de la FIEL
	 * @param rfc :RFC del solicitante 
	 * @param idPackage :id del paquete a descargar obtenido del webservice de verification {@link SOAPVerification}
	 * @param pathFile :Ruta relativa dentro del server donde se guardara el archivo solicitado [pathFile] / [period] / [idPackage].zip
	 * @param period :Periodo que sera utilizado como parte de la ruta donde se guardara el archivo [pathFile] / [period] / [idPackage].zip
	 * @throws Exception
	 */
	public SOAPDownload(String endPoint, String soapAction, String authorization, MultipartFile[] files, String passPhrase, String rfc, String idPackage, String pathFile, String period) throws Exception {
		super(endPoint, soapAction, authorization, files);
		this.rfc = rfc;
		this.idPackage = idPackage;
		this.passPhrase = passPhrase;
		this.pathFile = pathFile;
		this.period = period;
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
		idPackage = idPackage.trim();
		period = period.trim();
		pathFile = pathFile == null? "": pathFile;
		//validamos el rfc
		if(!Utilities.validateRFC(rfc)) {
			throw new Exception("RFC invalido");
		}
		if(idPackage == null || idPackage.isEmpty()) {
			throw new Exception("El parametro 'idPaquete' no esta definido");
		}
		if(period == null || period.isEmpty()) {
			throw new Exception("El parametro 'periodoFolder' no esta definido");
		}

	}

	/* (non-Javadoc)
	 * @see mx.com.bwr.sat.soap.SOAPClient#createSoapEnvelope()
	 */
	@Override
	public void createSoapEnvelope() throws Exception {
		// obtenemos el template del xml de la peticion soap para autenticar
		String text = SOAPUtilities.getXMLTemplate("SOAPDownload.xml");
		// obtenemos el base 64 del certificado
		String certificate = Base64.getEncoder().encodeToString(cert);
		// obtenemos el valor del digest
		String digest = createDigest(new String[] { idPackage, rfc });
		//obtenemos el signature
		String signature = createSignature(digest);
		//obtenemos una instancia del objeto para certificados
		X509Certificate certificateX = SOAPUtilities.generateCertificateObject(cert);
		//obtenemos el issuer
		String issuer = SOAPUtilities.getIssuer(certificateX);
		//obtenemos el serialnumber
		String serialNumber = SOAPUtilities.getSerialNumber(certificateX);
		
		text = text.replace(ID_PACKAGE, idPackage);
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
			String digest = "<des:PeticionDescargaMasivaTercerosEntrada xmlns:des=\"http://DescargaMasivaTerceros.sat.gob.mx\">"
				+ "<des:peticionDescarga IdPaquete=\"" + params[0] + "\" RfcSolicitante=\"" + params[1]
				+ "\"></des:peticionDescarga></des:PeticionDescargaMasivaTercerosEntrada>";
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
				+ "<CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\">"
				+ "</CanonicalizationMethod><SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\">"
				+ "</SignatureMethod><Reference URI=\"\"><Transforms><Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\">"
				+ "</Transform></Transforms><DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\">"
				+ "</DigestMethod><DigestValue>" + digest + "</DigestValue></Reference></SignedInfo>";
		return SOAPUtilities.sign(signature, privateKey, passPhrase);
	}

	/* (non-Javadoc)
	 * @see mx.com.bwr.sat.soap.SOAPClient#result()
	 */
	@Override
	public Map<String, Object> result() throws Exception {
		SOAPHeader header;
		Map<String, Object> response = new HashMap<String, Object>();
		try {
			SOAPBody body = soapResponse.getSOAPBody();
			header = soapResponse.getSOAPHeader();
			// verificamos la respuesta en el header, comprobando si se encuentra el nodo h:respuesta
			if (header.getElementsByTagName("h:respuesta").getLength() > 0) {
				Node node = header.getElementsByTagName("h:respuesta").item(0);
				String codEstatus = node.getAttributes().getNamedItem("CodEstatus") != null
						? node.getAttributes().getNamedItem("CodEstatus").getNodeValue()
						: "";
				// sin importar si fue exitosa o no siempre tendra dos atributos
				response.put("cod_estatus", codEstatus);
				response.put("mensaje",
						node.getAttributes().getNamedItem("Mensaje") != null
								? node.getAttributes().getNamedItem("Mensaje").getNodeValue()
								: "");
				//comprobamos si viene el paquete, esto solo ocurrira con el CodEstatus = 5000 y con la 
				//existencia del nodo Paquete
				if (codEstatus.equals("5000") && body.getElementsByTagName("Paquete").getLength() > 0) {
					String encoded = body.getElementsByTagName("Paquete").item(0).getTextContent();
					boolean success = SOAPUtilities.saveZip(pathFile + "/" + rfc + "/" + period, encoded, idPackage + ".zip");
					response.put("paquete_guardado", success);
					
				}
			} else {
				// en caso de no encontrar el nodo anterior, regresamos la respuesta tal cual
				// nos la devuelve el sat
				response.put("error", getStringRequest(soapResponse));
			}
		} catch (SOAPException e) {
			throw new Exception("Imposible leer respuesta SOAP");
		} catch (IOException e) {
			throw new Exception("El archivo no se pudo guardar");
		}
		return response;
	}

}
