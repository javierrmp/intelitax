/**
 * package mx.com.bwr.sat.config;
 */
package mx.com.bwr.sat.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.web.multipart.commons.CommonsMultipartResolver;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * 
 * @author Jorge Vargas
 *	Clase encargada del registro de controladores, mapeos, validaciones, etc.
 */
@EnableWebMvc                                    // Activar MVC
@Configuration 	                                 // Indicar que la clasees de configuración
@PropertySource("classpath:config.properties")	//Archivo de propiedades
@ComponentScan({ "mx.com.bwr.sat.web" })   	// Indicar paquete de escaneo de controladores
public class SpringWebConfig implements WebMvcConfigurer {
	
	/**
	 * Se habilita el CORS para toda la aplicacion
	 */
	@Override
	public void addCorsMappings(CorsRegistry registry) {
		registry.addMapping("/**");
	}
	 
	/**
	 * Bean que permite el manejo de archivos en las peticiones
	 * @return
	 */
	@Bean(name = "multipartResolver")
	public CommonsMultipartResolver multipartResolver()
	{
	    CommonsMultipartResolver multipartResolver = new CommonsMultipartResolver();
	    multipartResolver.setMaxUploadSize(20848820);
	    return multipartResolver;
	}
	
}