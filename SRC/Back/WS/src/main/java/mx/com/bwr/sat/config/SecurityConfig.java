/**
 * package mx.com.bwr.sat.config; 
 */
package mx.com.bwr.sat.config;

import org.springframework.context.annotation.Bean;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;


import java.util.Arrays;

/**
 * Clase encargada de la configuracion de seguridad
 * @author Jorge Vargas
 *
 */
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {
 
	/**
	 * Habilitamos todas las peticiones REST(GET, POST, PUT, DELETE, etc), para cualquier usuario
	 */
    @Override
    protected void configure(HttpSecurity httpSecurity) throws Exception {
    	httpSecurity.csrf().disable().authorizeRequests().antMatchers("/").permitAll();
    }
    
    /**
     * Este Bean permite configurar un filtro para el bloqueo de las peticiones por el CORS
     * @return
     */
	@Bean
    CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
       	configuration.setAllowedOrigins(Arrays.asList("*"));
     	configuration.setAllowedMethods(Arrays.asList("GET","POST"));
     	configuration.setAllowedHeaders(Arrays.asList("*"));
     	configuration.setAllowCredentials(false);
     	       
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
	
    
}