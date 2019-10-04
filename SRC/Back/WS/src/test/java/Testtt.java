import java.io.ByteArrayInputStream;
import java.nio.charset.Charset;

import javax.xml.soap.MessageFactory;
import javax.xml.soap.MimeHeaders;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPMessage;

import org.w3c.dom.Node;

public class Testtt {

	public static void main(String[] args) {
		try {
			String xml = "<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">\r\n" + 
					"    <s:Body xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">\r\n" + 
					"        <SolicitaDescargaResponse xmlns=\"http://DescargaMasivaTerceros.sat.gob.mx\">\r\n" + 
					"            <SolicitaDescargaResult IdSolicitud=\"e6e54ed5-22fb-4d17-b03b-f6d80079b68d\" CodEstatus=\"5000\" Mensaje=\"Solicitud Aceptada\"/>\r\n" + 
					"        </SolicitaDescargaResponse>\r\n" + 
					"    </s:Body>\r\n" + 
					"</s:Envelope>";
			
			MessageFactory messageFactory = MessageFactory.newInstance();
			SOAPMessage soapMessage = messageFactory.createMessage(new MimeHeaders(), new ByteArrayInputStream(xml.getBytes(Charset.forName("UTF-8"))));
			soapMessage.saveChanges();
			
			
			SOAPBody body = soapMessage.getSOAPBody();
			
			System.out.println("body.size -> " + body.getElementsByTagName("SolicitaDescargaResult").item(0).getChildNodes().getLength());
			System.out.println("body.faultcode -> " + body.getElementsByTagName("SolicitaDescargaResult").item(0));
			Node node = body.getElementsByTagName("SolicitaDescargaResult").item(0);
			
			System.out.println("body.faultstring -> " + node.getAttributes().getNamedItem("IdSolicitud").getNodeValue());
			System.out.println("body.faultstring -> " + node.getAttributes().getNamedItem("CodEstatus").getNodeValue());
			System.out.println("body.faultstring -> " + node.getAttributes().getNamedItem("Mensaje").getNodeValue());
			System.out.println("body.faultstring -> " + node.getAttributes().getNamedItem("otro").getNodeValue());
			/*
			 * String pathCert = "C:\\Users\\Jorge Vargas\\Downloads\\Datos_Prueba_CFDI_Complemento\\FIEL_Pruebas_AUAC4601138F9\\FIEL_Pruebas_AUAC4601138F9.cer";
			//String pathCert = "C:\\Users\\Jorge Vargas\\Documents\\Borrar despues\\FIEL_MOPJ781222SE1_20190904105338\\mopj781222se1.cer";
			byte[] cert = IOUtils.toByteArray(new FileInputStream(pathCert));
			//SOAPUtilities.getIssuer(cert);
			 * */
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
	}

}
