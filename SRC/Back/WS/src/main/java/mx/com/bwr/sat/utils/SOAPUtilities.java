/**
 * package mx.com.bwr.sat.utils;
 */
package mx.com.bwr.sat.utils;

import java.io.BufferedOutputStream;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.PrivateKey;
import java.security.Signature;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.Base64;

import javax.security.auth.x500.X500Principal;

import org.apache.commons.io.IOUtils;
import org.apache.commons.ssl.PKCS8Key;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;


/**
 * @author Jorge Vargas
 * Clase con varios metodos que se ocuparan en la elaboracion de las peticiones SOAP 
 */
public class SOAPUtilities {

	/**
	 * Calcula el SHA1 en formato binario del texto recibido y lo codifica a base64
	 * @param input :texto a codificar
	 * @param privateKeyByte :Llave privada de la FIEL
	 * @param passPahrase :Password de la FIEL
	 * @return SHA1 en formato binario del texto recibido y codificado a base64
	 * @throws Exception 
	 * @throws IOException
	 * @throws GeneralSecurityException
	 */
	public static String sign(String input, byte[] privateKeyByte, String passPahrase) throws Exception {
		PrivateKey privateKey;
		try {
			privateKey = new PKCS8Key(privateKeyByte, passPahrase.toCharArray()).getPrivateKey();
			Signature instance = Signature.getInstance("SHA1withRSA");
			instance.initSign(privateKey);
			
			instance.update((input).getBytes("UTF-8"));
			byte[] signature = instance.sign();
			
			return Base64.getEncoder().encodeToString( signature );
		} catch (Exception e) {
			throw new Exception("El password o la llave privada no son validos");
		}
		
	}
	
	/**
	 * Genera una instancia X509Certificate de los bytes recibidos
	 * @param certficate :arreglo de bytes del certificado
	 * @return Instancia X509Certificate
	 * @throws Exception 
	 */
	public static X509Certificate generateCertificateObject(byte[] certficate) throws Exception {
		InputStream in = null;
		try {
			in = new ByteArrayInputStream(certficate);
			CertificateFactory cf = CertificateFactory.getInstance("X.509");
			return (X509Certificate)cf.generateCertificate(in);
			
		} catch (Exception e) {
			throw new Exception("El certificado es invalido");
		} finally {
			if(in != null) {
				try { in.close(); } catch(Exception e) {}
			}
		}
	}
	
	/**
	 * Retorna el valor del campo 'issuer' del certificado en formato RFC1779
	 * @param certficate :Cadena con el valor del campo 'issuer'
	 * @return
	 */
	public static String getIssuer(X509Certificate certficate) {
		return certficate.getIssuerX500Principal().getName(X500Principal.RFC1779);
	}
	
	/**
	 * Retorna el valor del campo 'serialNumber' del certificado 
	 * @param certficate :Cadena con el numero de serie del certificado
	 * @return
	 */
	public static String getSerialNumber(X509Certificate certficate) {
		return certficate.getSerialNumber().toString();
	}
	
	/**
	 * Funcion que obtiene el contenido de un archivo ubicado en la carpeta de Resources
	 * @param name :Nombre del archivo
	 * @return :Cadena con  el contenido del archivo
	 * @throws Exception 
	 * @throws IOException
	 */
	public static String getXMLTemplate(String name) throws Exception {
		InputStream input = null;
		try {
			Resource resource = new ClassPathResource(name);
			input = resource.getInputStream();
			return IOUtils.toString(input, StandardCharsets.UTF_8.name());
		} catch (IOException e) {
			throw new Exception("Error al obtener template de la peticion SOAP");
		} finally {
			try {
				if(input != null) input.close();
			} catch(Exception e) {}
		}
	}
	
	/**
	 * Funcion que convierte un string a un long
	 * @param value :Valor a convertir
	 * @return :El valor convertido a long, en caso de error regresa cero
	 */
	public static long parseLong(String value) {
		
		long valueParsed = 0;
		try {
			valueParsed = Long.parseLong(value);
		} catch (NumberFormatException e) { }
		
		return valueParsed;
	}

	/**
	 * Guarda un archivo dentro de la ruta especificada
	 * @param pathFile :Ruta relativa donde se guardara el archivo
	 * @param encoded :Contenido del archivo en base64
	 * @param nameZip :Nombre del archivo con el que se guardara
	 * @return true en caso de exito, false en cualquier otro caso
	 * @throws IOException
	 */
	public static boolean saveZip(String pathFile, String encoded, String nameZip) throws IOException {
		
		String directoryStr = new ClassPathResource(".").getFile().getParentFile().getAbsolutePath() + "/" + pathFile;
		
		File directory = new File(directoryStr);
		if(!directory.exists()) {
			directory.mkdirs();
		}
		
		byte[] compressed = Base64.getDecoder().decode(encoded);
		BufferedOutputStream out = null;
		boolean success = false;
		try {
		    out = new BufferedOutputStream(new FileOutputStream(directory.getAbsolutePath() + "/" + nameZip));
		    out.write(compressed);
		    success = true;
		} finally {
		    if (out != null) {
		        try { out.close(); } catch(Exception e) {}
		    }
		}
		return success;
	}
}
