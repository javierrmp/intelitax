/**
 * package mx.com.bwr.sat.servlet;
 */
package mx.com.bwr.sat.servlet;

import org.springframework.web.servlet.support.AbstractAnnotationConfigDispatcherServletInitializer;

import mx.com.bwr.sat.config.SecurityConfig;
import mx.com.bwr.sat.config.SpringWebConfig;

/**
 * 
 * @author Jorge Vargas
 * Clase que permite agregar clases de configuraci�n para aplicar filtros al DispatcherServlet y proporcionar la asignaci�n del servlet.
 */
public class MyWebInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {
	

	@Override
	protected Class<?>[] getServletConfigClasses() {
		return new Class[] { SpringWebConfig.class };
	}
	
	@Override
	protected Class<?>[] getRootConfigClasses() {
		return new Class[]{ SecurityConfig.class };
	}


	@Override
	protected String[] getServletMappings() {
		return new String[] { "/" };
	}

	
	
}