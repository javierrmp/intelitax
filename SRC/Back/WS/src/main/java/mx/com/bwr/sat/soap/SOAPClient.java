/**
 * mx.com.bwr.sat.soap
 */
package mx.com.bwr.sat.soap;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.Charset;
import java.security.GeneralSecurityException;
import java.util.Map;

import javax.xml.soap.MessageFactory;
import javax.xml.soap.MimeHeaders;
import javax.xml.soap.SOAPConnection;
import javax.xml.soap.SOAPConnectionFactory;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPMessage;

import org.apache.commons.io.FilenameUtils;
import org.springframework.web.multipart.MultipartFile;

import mx.com.bwr.sat.utils.LoggerSAT;

/**
 * @author Jorge Vargas
 * Clase abstracta que contiene la estructura basica de los SOAP que ocupara la aplicacion para las peticiones
 * a los webservice del SAT
 */
public abstract class SOAPClient {

	
	private String endPoint;
	private String soapAction;
	protected String authorization;
	private MultipartFile[] files;
	
	protected SOAPMessage soapMessage;
	protected SOAPMessage soapResponse;
	
	protected byte[] privateKey;
	protected byte[] cert;
	
	/**
	 * Constructor que recibe los parametros para la inicializacion del SOAP y ademas valida los archivos 
	 * que deberan contener la llave privada y el certificado
	 * @param endPoint :URL a la que se le hara la peticion
	 * @param soapAction :Accion del SOAP que se debera invocar
	 * @param authorization :Solo en caso de ya tener un token, este se utilizara para la validacion de la peticion
	 * @param files :Archivos con la llave privada y el certificado de la FIEL
	 * @throws Exception :Excepcion que se lanzara en caso de ocurrir algun error durante la validacion de los archvos
	 */
	public SOAPClient(String endPoint, String soapAction, String authorization, MultipartFile[] files) throws Exception{
		this.endPoint = endPoint;
		this.soapAction = soapAction;
		this.authorization = authorization;
		this.files = files;
		//validamos los archivos
		validateFiles();
	}
	
	/**
	 * Metodo encargado de inicializar los headers de la peticion SOAP, ademas de convertir el texto recibido en formato XML
	 * a una instancia del tipo SOAPMessage
	 * @param xml :Cadena de texto en formato xml, que se parseara a una instancia del tipo SOAPMessage 
	 * @throws Exception
	 */
	public void initHeadersSOAPRequest(String xml) throws Exception {
		MessageFactory messageFactory;
		try {
			messageFactory = MessageFactory.newInstance();
			soapMessage = messageFactory.createMessage(new MimeHeaders(),
					new ByteArrayInputStream(xml.getBytes(Charset.forName("UTF-8"))));

			MimeHeaders headers = soapMessage.getMimeHeaders();
			headers.addHeader("Method", "POST");
			headers.addHeader("Content-Type", "text/xml; charset=utf-8");
			headers.addHeader("SOAPAction", soapAction);
			if (authorization != null && !authorization.isEmpty()) {
				headers.addHeader("Authorization", String.format("WRAP access_token=\"%s\"", authorization));
			}
		} catch (Exception e) {
			throw new Exception("Error al inicializar peticion SOAP");
		} 

	}
	
	/**
	 * Funcion que valida los archivos recibidos que deberian ser el key y el cert,
	 * a partir de estos, obtiene sus bytes que seran ocupados en la generacion del XML de peticion
	 * @throws Exception 
	 */
	private void validateFiles() throws Exception {
		//validamos que solo halla dos archivos
        if (files != null && files.length == 2) {
        	//recorrems los dos archivos
        	for (MultipartFile multipartFile : files) {
            	String fileName = multipartFile.getOriginalFilename();
            	String extention = FilenameUtils.getExtension(fileName);
                //obtenemos los bytes por la extension
                if(extention.equalsIgnoreCase("key")) {
                	privateKey = multipartFile.getBytes();
                } else {
                	cert = multipartFile.getBytes();
                }
        	}
        	//si el key no se encontro mandamos error
            if(privateKey == null) {
            	throw new Exception("No se recibio la llave privada");
            }
        } else {
        	throw new Exception("No se recibieron los archivos necesarios");
        }
	}
	
	/**
	 * Funcion encarga de realizar la peticion y de almacenar la respuesta en la variable soapResponse
	 * @throws Exception
	 */
	public void callSoapWebService() throws Exception {
		SOAPConnection soapConnection = null;
		soapResponse = null;
		try {
			// Create SOAP Connection
	        SOAPConnectionFactory soapConnectionFactory = SOAPConnectionFactory.newInstance();
	        soapConnection = soapConnectionFactory.createConnection();
	        soapMessage.saveChanges();
	        //printRequests(soapMessage);
	        // Send SOAP Message to SOAP Server
	        soapResponse = soapConnection.call(soapMessage, endPoint);
	        //printRequests(soapResponse);
		} catch (Exception e) {
			throw new Exception("Fallo al enviar peticion SOAP al webservice del SAT");
		}  finally {
			if(soapConnection != null) {
				try { soapConnection.close(); } catch(Exception e) { }
			}
		}
	}
	
	/**
	 * Funcion que validara los datos recibidos en el constructor, ya que estos se ocuparan en la generacion
	 * del XML de la peticion
	 * @throws Exception
	 */
	public abstract void validateData() throws Exception;
	
	/**
	 * Funcion que creara el XML de la peticion reemplazando los datos reibidos en el template del XML definido para esta 
	 * instancia
	 * @throws SOAPException
	 * @throws IOException
	 * @throws Exception
	 */
	public abstract void createSoapEnvelope() throws Exception;
	
	/**
	 * Crea el Digest calculando el SHA1 en formato binario a partir de una cadena definida junto con los parametros que recibe
	 * y sera ocupadao en el nodo DigestValue del xml
	 * @param params : Parametros que contienen los datos reales a ser reemplazados para la creacion del Dsigest
	 * @return :Regresa una cadena en formato base64
	 * @throws UnsupportedEncodingException
	 */
	public abstract String createDigest(String[] params) throws Exception;
	
	/**
	 * Metodo que calcula un algoritmo de digestión SHA1 utilizando la llave privada de la FIEL una cadena definida junto con el digest recibido
	 * y sera ocupada en el nodo SignatureValue del xml 
	 * @param digest :Cadena con el digest en formato base64
	 * @return :Regresa una cadena en formato base64
	 * @throws IOException
	 * @throws GeneralSecurityException
	 */
	public abstract String createSignature(String digest) throws Exception;
	
	/**
	 * Metodo que parsea la respuesta recibida por el webservice del SAT a un formato llave: valor en un mapa,
	 * solo con los atributos relevantes para cada tipo de respuesta
	 * @return : Mapa con los valores relevantes de la respuesta del webservice del SAT
	 * @throws SOAPException
	 * @throws Exception
	 */
	public abstract Map<String, Object> result() throws Exception;
	
	/**
	 * Metodo que imprime en el log el xml contenido en una instancia de tipo SOAPMessage 
	 * @param soapMessage :Instancia SOAPMessage que contiene el XML a imprimir
	 */
	protected void printRequests(SOAPMessage soapMessage) {
		LoggerSAT.printLine(getStringRequest(soapMessage));
        
	}
	
	/**
	 * Metodo que genera una cadena texto con formato XML, con el contenido de la instancia SOAPMessage recibida
	 * @param soapMessage :Instancia SOAPMessage que contiene el XML
	 * @return
	 */
	public String getStringRequest(SOAPMessage soapMessage) {
		String soapStr = "";
        ByteArrayOutputStream baot = new ByteArrayOutputStream();
        try {
			soapMessage.writeTo(baot);
			soapStr = baot.toString("UTF-8");
		} catch (Exception e) {
			LoggerSAT.printError("mx.com.bwr.sat.soap.SOAPClient", e);
		}
        return soapStr;
	}

}
