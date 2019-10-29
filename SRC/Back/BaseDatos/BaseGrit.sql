--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5 (Ubuntu 11.5-3.pgdg19.04+1)
-- Dumped by pg_dump version 11.5 (Ubuntu 11.5-3.pgdg19.04+1)

-- Started on 2019-10-29 15:51:07 CST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE "BaseGrit";
--
-- TOC entry 3709 (class 1262 OID 60914)
-- Name: BaseGrit; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "BaseGrit" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'es_MX.UTF-8' LC_CTYPE = 'es_MX.UTF-8';


ALTER DATABASE "BaseGrit" OWNER TO postgres;

\connect "BaseGrit"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 60915)
-- Name: BaseSistema; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "BaseSistema";


ALTER SCHEMA "BaseSistema" OWNER TO postgres;

--
-- TOC entry 15 (class 2615 OID 60916)
-- Name: BaseSistemaHistorico; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "BaseSistemaHistorico";


ALTER SCHEMA "BaseSistemaHistorico" OWNER TO postgres;

--
-- TOC entry 14 (class 2615 OID 60917)
-- Name: InfHistorica; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "InfHistorica";


ALTER SCHEMA "InfHistorica" OWNER TO postgres;

--
-- TOC entry 10 (class 2615 OID 60918)
-- Name: InfUsuario; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "InfUsuario";


ALTER SCHEMA "InfUsuario" OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 60919)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 3710 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 388 (class 1255 OID 60956)
-- Name: AltaAsociado(character, character, bigint, bigint); Type: FUNCTION; Schema: BaseSistema; Owner: postgres
--

CREATE FUNCTION "BaseSistema"."AltaAsociado"(razon_soc character DEFAULT ''::bpchar, rfc character DEFAULT ''::bpchar, idclte bigint DEFAULT 0, idusuario bigint DEFAULT 0) RETURNS TABLE(status character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE HayDatos int;
begin
	IF rfc = '' THEN
		RETURN QUERY SELECT 'DIGITE UN RFC'::varchar AS "STATUS";
	ELSE
		IF LENGTH(rfc) < 12 OR LENGTH(rfc) > 13 THEN
			RETURN QUERY SELECT 'DIGITE UN RFC VALIDO'::varchar AS "STATUS";
		ELSE
			SELECT COUNT(1) INTO HayDatos FROM "BaseSistema"."CFGCLTESRFC"
			WHERE "RFC" = rfc AND "STATUS" = 5 AND "ID_CLTE" = idclte;

			IF HayDatos > 0 THEN
				RETURN QUERY SELECT 'YA EXISTE EL RFC'::varchar AS "STATUS";
			ELSE
				INSERT INTO "BaseSistema"."CFGCLTESRFC"
					("RFC", "RAZON_SOC", "ID_CLTE", "FH_ALTA", "ID_USR_ALTA", "STATUS")
				VALUES (rfc, razon_soc, idclte, NOW(), idusuario, 5);

				SELECT COUNT(1) INTO HayDatos
				FROM "BaseSistema"."CFGCLTESRFC"
				WHERE "RFC" = rfc::varchar AND
					"RAZON_SOC" = razon_soc::varchar AND
					"STATUS" = 5;
					
				IF HayDatos > 0 THEN
					RETURN QUERY SELECT "ID_RFC"::varchar AS "STATUS"
					FROM "BaseSistema"."CFGCLTESRFC"
					WHERE "RFC" = rfc::varchar AND
						"RAZON_SOC" = razon_soc::varchar AND
						"STATUS" = 5;
				ELSE
					RETURN QUERY SELECT 'ERROR EN LA ALTA DEL ASOCIADO'::varchar AS "STATUS";
				END IF;
			END IF;
		END IF;
	END IF;
end;
$$;


ALTER FUNCTION "BaseSistema"."AltaAsociado"(razon_soc character, rfc character, idclte bigint, idusuario bigint) OWNER TO postgres;

--
-- TOC entry 378 (class 1255 OID 60957)
-- Name: AltaCliente(character, character, character, character, character, character, character, character, bigint); Type: FUNCTION; Schema: BaseSistema; Owner: postgres
--

CREATE FUNCTION "BaseSistema"."AltaCliente"(nombre character DEFAULT ''::bpchar, rfc character DEFAULT ''::bpchar, pais character DEFAULT ''::bpchar, estado character DEFAULT ''::bpchar, ciudad character DEFAULT ''::bpchar, mpio_del character DEFAULT ''::bpchar, colonia character DEFAULT ''::bpchar, cp character DEFAULT ''::bpchar, idusuario bigint DEFAULT 0) RETURNS TABLE(status character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE HayDatos int;
begin
	IF rfc = '' THEN
		RETURN QUERY SELECT 'DIGITE UN RFC'::varchar AS "STATUS";
	ELSE
		IF LENGTH(rfc) < 12 THEN
			RETURN QUERY SELECT 'DIGITE UN RFC VALIDO'::varchar AS "STATUS";
		ELSE
			IF LENGTH(rfc) > 13 THEN
				RETURN QUERY SELECT 'DIGITE UN RFC VALIDO'::varchar AS "STATUS";
			ELSE
				SELECT COUNT(1) INTO HayDatos FROM "BaseSistema"."CFGCLTES"
				WHERE "RFC" = rfc;

				IF HayDatos > 0 THEN
					RETURN QUERY SELECT 'YA EXISTE EL RFC'::varchar AS "STATUS";
				ELSE
					INSERT INTO "BaseSistema"."CFGCLTES"
						("NAME_CLTE", "RFC", "PAIS", "ESTADO", "CIUDAD", "MPIO_DEL", 
						 "COLONIA", "CP", "ID_REPOSITORIO", "FH_ALTA",  
						 "ID_USR_ALTA", "STATUS")
					VALUES (nombre, rfc, pais, estado, ciudad, mpio_del, 
							colonia, cp, 2, now(), idusuario, 3);

					SELECT COUNT(1) INTO HayDatos
					FROM "BaseSistema"."CFGCLTES"
					WHERE "RFC" = rfc::varchar and
						"STATUS" = 3;

					IF HayDatos > 0 THEN
						RETURN QUERY SELECT "ID_CLTE"::varchar AS "STATUS"
						FROM "BaseSistema"."CFGCLTES"
						WHERE "RFC" = rfc::varchar and
							"STATUS" = 3;
					ELSE
						RETURN QUERY SELECT 'ERROR EN LA ALTA DEL CLIENTE'::varchar AS "STATUS";
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;
end;
$$;


ALTER FUNCTION "BaseSistema"."AltaCliente"(nombre character, rfc character, pais character, estado character, ciudad character, mpio_del character, colonia character, cp character, idusuario bigint) OWNER TO postgres;

--
-- TOC entry 379 (class 1255 OID 60958)
-- Name: CargaCredenciales(character, text, character, character, character, character); Type: PROCEDURE; Schema: BaseSistema; Owner: postgres
--

CREATE PROCEDURE "BaseSistema"."CargaCredenciales"(idrfc character, paswd text, ruta character, nomllave character, nomcert character, estatus character)
    LANGUAGE plpgsql
    AS $$
	DECLARE carpetaLlave character(500);
	DECLARE carpetaCert character(500);
	DECLARE paswdencrypt text;
	DECLARE fileLlave bytea;
	DECLARE fileCert bytea;
	DECLARE fileLlaveEncrypt bytea;
	DECLARE fileCertEncrypt bytea;
begin
	carpetaLlave:= ruta || '/' || nomLlave;
	carpetaCert:= ruta || '/' || nomCert;
	
	--paswd:= encode(digest(paswd, 'sha256'), 'hex');
	/*paswdencrypt:= crypt(paswd::text, gen_salt('md5')::text);
	fileLlave:=pg_read_binary_file(carpetaLlave)::bytea;
	fileCert:=pg_read_binary_file(carpetaCert)::bytea;
	fileLlaveEncrypt:=pgp_sym_encrypt(fileLlave::text, paswdencrypt::text)::bytea;
	fileCertEncrypt:=pgp_sym_encrypt(fileCert::text, paswdencrypt::text)::bytea;*/
	
	paswdencrypt = paswd;
	fileLlave:=pg_read_binary_file(carpetaLlave)::bytea;
	fileCert:=pg_read_binary_file(carpetaCert)::bytea;
	fileLlaveEncrypt = fileLlave;
	fileCertEncrypt = fileCert;
	--fileLlaveEncrypt:=pgp_sym_encrypt(fileLlave::text, paswdencrypt::text)::bytea;
	--fileCertEncrypt:=pgp_sym_encrypt(fileCert::text, paswdencrypt::text)::bytea;
	
	INSERT INTO "BaseSistema"."CFGCLTESCREDENCIALES"(
	"ID_RFC", "PASS", "LLAVE", "CERTIF", "FH_ALTA", "STATUS")
	VALUES (idrfc::bigint, 
			paswdencrypt::text, 
			fileLlaveEncrypt::bytea, 
			fileCertEncrypt::bytea, 
			now(), 
			estatus::bigint);
end;
$$;


ALTER PROCEDURE "BaseSistema"."CargaCredenciales"(idrfc character, paswd text, ruta character, nomllave character, nomcert character, estatus character) OWNER TO postgres;

--
-- TOC entry 380 (class 1255 OID 60959)
-- Name: CargaINFOMETA(character, character, character, character); Type: PROCEDURE; Schema: BaseSistema; Owner: postgres
--

CREATE PROCEDURE "BaseSistema"."CargaINFOMETA"(cve_descarga character, file_name character, temporal character, ruta character)
    LANGUAGE plpgsql
    AS $$
--DECLARE ruta character(500);
begin

--ruta := '/home/master/Documentos/Google Drive/Proyectos Personales/Grit/SUKARNE/META/' || FILE_NAME;
ruta:= ruta || file_name;

CREATE TEMP TABLE IF NOT EXISTS TemporalINFOMETA_1
(
    "UUID" character(40) COLLATE pg_catalog."default",
    "RFC_EMISOR" character(13) COLLATE pg_catalog."default",
    "NAME_EMISOR" character(155) COLLATE pg_catalog."default",
    "RFC_RECEPTOR" character(13) COLLATE pg_catalog."default",
    "NAME_RECEPTOR" character(155) COLLATE pg_catalog."default",
    "RFC_PAC" character(13) COLLATE pg_catalog."default",
    "FH_EMISION" character(100) COLLATE pg_catalog."default",
    "FH_CERT_SAT" character(100) COLLATE pg_catalog."default",
    "MNTO" character(100) COLLATE pg_catalog."default",
    "EFECTO_COMP" character(1) COLLATE pg_catalog."default",
    "STATUS" character(100) COLLATE pg_catalog."default",
    "FH_CANC" character(100) COLLATE pg_catalog."default"
); 

IF TEMPORAL = 'TemporalINFOMETA_1' THEN
	EXECUTE 'COPY TemporalINFOMETA_1 from ''' || ruta || ''' delimiter ''~'' csv header';

	INSERT INTO "InfHistorica"."INFMETA"(
		"UUID", "RFC_EMISOR", "NAME_EMISOR", "RFC_RECEPTOR", "NAME_RECEPTOR", 
		"RFC_PAC", "FH_EMISION", "FH_CERT_SAT", "MNTO", "EFECTO_COMP", "STATUS", "FH_CANC", 
		"CVE_DESCARGA", "FH_PERIODO"
		)
	SELECT 
		"UUID", "RFC_EMISOR", "NAME_EMISOR", "RFC_RECEPTOR", "NAME_RECEPTOR", 
		"RFC_PAC", 
		to_date("FH_EMISION",'YYYY-MM-DD HH24:MI:SS') AS "FH_EMISION",
		to_date("FH_CERT_SAT",'YYYY-MM-DD HH24:MI:SS') AS "FH_CERT_SAT",
		to_number("MNTO",'999999999.99') AS "MONTO", 
		"EFECTO_COMP", 
		to_number("STATUS",'999') AS "STATUS", 
		to_date("FH_CANC",'YYYY-MM-DD HH24:MI:SS') AS "FH_CANC",
		CVE_DESCARGA AS "CVE_DESCARGA",
		NOW() AS "FH_PERIODO" 
	FROM TemporalINFOMETA_1;
END IF;

DROP TABLE IF EXISTS TemporalINFOMETA_1;

end;
$$;


ALTER PROCEDURE "BaseSistema"."CargaINFOMETA"(cve_descarga character, file_name character, temporal character, ruta character) OWNER TO postgres;

--
-- TOC entry 381 (class 1255 OID 60960)
-- Name: CargaXML(); Type: PROCEDURE; Schema: BaseSistema; Owner: postgres
--

CREATE PROCEDURE "BaseSistema"."CargaXML"()
    LANGUAGE plpgsql
    AS $$
DECLARE myxml xml;
begin
myxml := XMLPARSE(DOCUMENT convert_from(pg_read_binary_file('/home/master/Documentos/Google Drive/Proyectos Personales/Grit/SUKARNE/EjemploXML.xml'), 'UTF8'));

INSERT INTO "InfUsuario"."CFDITOTAL"(
	"TEXTOCFDI", "CVE_DESCARGA")
	VALUES (myxml, '201909101809');

end;
$$;


ALTER PROCEDURE "BaseSistema"."CargaXML"() OWNER TO postgres;

--
-- TOC entry 382 (class 1255 OID 60961)
-- Name: CopiaINFO69y69B(character); Type: PROCEDURE; Schema: BaseSistema; Owner: postgres
--

CREATE PROCEDURE "BaseSistema"."CopiaINFO69y69B"(cve_descarga character)
    LANGUAGE plpgsql
    AS $$
DECLARE HayDatos int;
begin

	SELECT COUNT(1) INTO HayDatos FROM "BaseSistemaHistorico"."INF69" WHERE "CVE_DESCARGA" = cve_descarga;
	
	RAISE NOTICE 'Hay datos INF69(%)',HayDatos;
	
	IF HayDatos = 0 THEN
		SELECT COUNT(1) INTO HayDatos FROM "BaseSistemaHistorico"."INF69B" WHERE "CVE_DESCARGA" = cve_descarga;
		
		RAISE NOTICE 'Hay datos INF69B(%)',HayDatos;
	END IF;

	IF HayDatos > 0 THEN
		TRUNCATE TABLE "BaseSistema"."INF69";
		TRUNCATE TABLE "BaseSistema"."INF69B";
		
		INSERT INTO "BaseSistema"."INF69"
			("ID_INF", "RFC", "RAZON_SOC", "TPO_PERS", "SUPUESTO", 
			"FH_PRIM_PUB", "MNTO", "FH_PUB", "AGRUPACION", "SELECCION")
		SELECT 
			"ID_INF", "RFC", "RAZON_SOC", "TPO_PERS", "SUPUESTO", 
			"FH_PRIM_PUB", "MNTO", "FH_PUB", "AGRUPACION", "SELECCION"
		FROM "BaseSistemaHistorico"."INF69"
		WHERE "CVE_DESCARGA" = cve_descarga;

		INSERT INTO "BaseSistema"."INF69B"
			("ID_INF", "NO", "RFC", "NAME_CONTR", "SITUACION_CONTR", 
			"FH_OFIC_GLO_PRESUN_SAT", "FH_PUB_PRESUN_SAT", "FH_OFIC_GLO_PRESUN_DOF", 
			"FH_PUB_PRESUN_DOF", "FH_PUB_DESV_SAT", "FH_OFIC_GLO_DESV_SAT", 
			"FH_PUB_DESV_DOF", "FH_OFIC_GLO_DESV_DOF", "FH_PUB_SAT_DEF", 
			"FH_PUB_DOF_DEF", "FH_OFIC_GLO_SENT_FAV", "FH_PUB_SENT_FAV_SAT", 
			"FH_OFIC_GLO_SENT_FAV_SAT", "FH_PUB_SENT_FAV_DOF", "FH_PUB_69B")
		SELECT 
			"ID_INF", "NO", "RFC", "NAME_CONTR", "SITUACION_CONTR", 
			"FH_OFIC_GLO_PRESUN_SAT", "FH_PUB_PRESUN_SAT", "FH_OFIC_GLO_PRESUN_DOF", 
			"FH_PUB_PRESUN_DOF", "FH_PUB_DESV_SAT", "FH_OFIC_GLO_DESV_SAT", 
			"FH_PUB_DESV_DOF", "FH_OFIC_GLO_DESV_DOF", "FH_PUB_SAT_DEF", 
			"FH_PUB_DOF_DEF", "FH_OFIC_GLO_SENT_FAV", "FH_PUB_SENT_FAV_SAT", 
			"FH_OFIC_GLO_SENT_FAV_SAT", "FH_PUB_SENT_FAV_DOF", "FH_PUB_69B"
		FROM "BaseSistemaHistorico"."INF69B"
		WHERE "CVE_DESCARGA" = cve_descarga;

		REFRESH MATERIALIZED VIEW "BaseSistema"."PROVEEDORES69" WITH DATA;
		REFRESH MATERIALIZED VIEW "BaseSistema"."PROVEEDORES69B" WITH DATA;
		
	END IF;
	
end;
$$;


ALTER PROCEDURE "BaseSistema"."CopiaINFO69y69B"(cve_descarga character) OWNER TO postgres;

--
-- TOC entry 389 (class 1255 OID 60962)
-- Name: CopiaINFOMETA(character); Type: PROCEDURE; Schema: BaseSistema; Owner: postgres
--

CREATE PROCEDURE "BaseSistema"."CopiaINFOMETA"(cve_descarga character)
    LANGUAGE plpgsql
    AS $$
DECLARE HayDatos int;
begin

	SELECT COUNT(1) INTO HayDatos FROM "InfHistorica"."INFMETA" WHERE "CVE_DESCARGA" = cve_descarga;
	
	RAISE NOTICE 'Hay datos INFMETA(%)',HayDatos;
	
	IF HayDatos > 0 THEN
		--TRUNCATE TABLE "InfUsuario"."INFMETA";

		INSERT INTO "InfUsuario"."INFMETA"
		SELECT 
			"ID_INF", "UUID", "RFC_EMISOR", "NAME_EMISOR", "RFC_RECEPTOR", 
			"NAME_RECEPTOR", "RFC_PAC", "FH_EMISION", "FH_CERT_SAT", "MNTO", 
			"EFECTO_COMP", "STATUS", "FH_CANC", "CVE_DESCARGA"
		FROM "InfHistorica"."INFMETA"
		WHERE "CVE_DESCARGA" = cve_descarga;

		REFRESH MATERIALIZED VIEW "InfUsuario"."CATALOGOPROVEEDORES" WITH DATA;
	END IF;
	
end;
$$;


ALTER PROCEDURE "BaseSistema"."CopiaINFOMETA"(cve_descarga character) OWNER TO postgres;

--
-- TOC entry 383 (class 1255 OID 60963)
-- Name: DescargaCredenciales(character); Type: FUNCTION; Schema: BaseSistema; Owner: postgres
--

CREATE FUNCTION "BaseSistema"."DescargaCredenciales"(idrfc character) RETURNS TABLE(pwd text, llave text, cert text)
    LANGUAGE plpgsql
    AS $$
begin
	RETURN QUERY SELECT 
		"PASS"::text,
		"LLAVE"::text AS "Llave",
		"CERTIF" ::text AS "Cert"
	FROM "BaseSistema"."CFGCLTESCREDENCIALES"
	WHERE "ID_RFC" = idrfc::bigint and
		"STATUS" = 7;
end;
$$;


ALTER FUNCTION "BaseSistema"."DescargaCredenciales"(idrfc character) OWNER TO postgres;

--
-- TOC entry 401 (class 1255 OID 69647)
-- Name: FinalizaReporte(character, character, bigint, character); Type: FUNCTION; Schema: BaseSistema; Owner: postgres
--

CREATE FUNCTION "BaseSistema"."FinalizaReporte"(cve_consulta character DEFAULT ''::bpchar, periodo character DEFAULT ''::bpchar, idusuario bigint DEFAULT 0, rfc character DEFAULT ''::bpchar) RETURNS TABLE(status character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE HayDatos int;
begin
	IF cve_consulta = '' THEN
		RETURN QUERY SELECT 'DIGITE UN CLAVE DE CONSULTA'::varchar AS "STATUS";
	ELSE
		IF periodo = '' THEN
			RETURN QUERY SELECT 'DIGITE EL PERIODO'::varchar AS "STATUS";
		ELSE
			IF idusuario = 0 THEN
				RETURN QUERY SELECT 'DIGITE EL ID DE USUARIO QUE SOLICITA EL REPORTE'::varchar AS "STATUS";
			ELSE
				IF rfc = '' THEN
					RETURN QUERY SELECT 'DIGITE EL RFC QUE SOLICITA PARA EL REPORTE'::varchar AS "STATUS";
				ELSE
					UPDATE "BaseSistema"."SOLCONSULPER"
					SET "STATUS"=41
					WHERE "CVE_CONSULTA" = cve_consulta AND
						"PERIODO" = periodo AND
						"ID_USR_ALTA" = idusuario AND
						"RFC" = rfc;

					SELECT "ID_CONSULTA"
					INTO HayDatos
					FROM "BaseSistema"."SOLCONSULPER"
					WHERE "CVE_CONSULTA" = cve_consulta AND
						"PERIODO" = periodo AND
						"ID_USR_ALTA" = idusuario AND
						"STATUS"=41 AND
						"RFC" = rfc;

					IF HayDatos > 0 THEN
						RETURN QUERY SELECT 'EXITO'::varchar AS "STATUS";
					ELSE
						RETURN QUERY SELECT 'ERROR'::varchar AS "STATUS";
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;
end;
$$;


ALTER FUNCTION "BaseSistema"."FinalizaReporte"(cve_consulta character, periodo character, idusuario bigint, rfc character) OWNER TO postgres;

--
-- TOC entry 384 (class 1255 OID 60965)
-- Name: MarcaPagosInValidosXdocu(); Type: PROCEDURE; Schema: BaseSistema; Owner: postgres
--

CREATE PROCEDURE "BaseSistema"."MarcaPagosInValidosXdocu"()
    LANGUAGE plpgsql
    AS $$
begin
	UPDATE "BaseSistema"."LOGCARGAXML" T1
	SET "USAPAGO" = 0, "MSGERROR" = 'EL DOCUMENTO RELACIONADO NO SE ENCUENTRA'
	FROM (
		SELECT 
			t9."CVE_DESCARGA"
		FROM "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOS" t10
		INNER JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOSDOCS" t11 ON 
			t11."ID_PAGO" = t10."ID_PAGO"
		LEFT JOIN "InfUsuario"."CFDICOMPROBANTE" t9 ON
			t9."ID_COMPROBANTE" = t10."ID_COMPROBANTE"
		LEFT JOIN "BaseSistema"."LOGCARGAXML" t8 ON
			t8."ID_CARGAXML"::character varying = t9."CVE_DESCARGA" AND
			REPLACE(t8."ARCHIVOXML",'.xml', '') = t11."IDDOCUMENTO" AND
			t8."STATUS" = 36 AND t8."STATUSPERIODO" = 38 AND t8."USAPAGO" = 1
		) t2
	WHERE T1."ID_CARGAXML"::character varying = t2."CVE_DESCARGA";
end;
$$;


ALTER PROCEDURE "BaseSistema"."MarcaPagosInValidosXdocu"() OWNER TO postgres;

--
-- TOC entry 402 (class 1255 OID 69648)
-- Name: MarcaPagosInValidosXfechas(bigint, character); Type: PROCEDURE; Schema: BaseSistema; Owner: postgres
--

CREATE PROCEDURE "BaseSistema"."MarcaPagosInValidosXfechas"(idusrsolicita bigint, rfc character)
    LANGUAGE plpgsql
    AS $$
begin
	UPDATE "BaseSistema"."LOGCARGAXML" T1
	SET "USAPAGO" = t2."USA", "MSGERROR" = t2."MSG"
	FROM (
		SELECT 
			t1."CVE_DESCARGA",
			CASE
				WHEN t10."FECHAPAGO" BETWEEN pe."FECHAINICIAL" AND pe."FECHAFINAL" THEN 1
				ELSE 0
			END AS "USA",
			CASE
				WHEN t10."FECHAPAGO" BETWEEN pe."FECHAINICIAL" AND pe."FECHAFINAL" THEN NULL
				ELSE 'LA FECHA DEL DOCUMENTO RELACIONADO NO ES DEL PERIODO CONSULTADO'
			END AS "MSG"
		FROM "InfUsuario"."CFDICOMPROBANTE" t1
		 JOIN "BaseSistema"."LOGCARGAXML" th ON th."ID_CARGAXML"::character varying::bpchar = 
			t1."CVE_DESCARGA" AND th."STATUS" = 36 AND th."STATUSPERIODO" = 38 AND th."USAPAGO" = 1
		 JOIN "BaseSistema"."SOLCONSULPER" s ON s."PERIODO" = th."PERIODO" AND s."STATUS" = 40
		 LEFT JOIN "BaseSistema"."CFGPERIODOS"pe ON s."PERIODO" = pe."PERIODO"
		 JOIN "BaseSistema"."LOGDESCARGAWSPROCESO" pr ON pr."CVE_DESCARGA" = th."CVE_DESCARGA" AND pr."STATUS" = 31
		 JOIN "BaseSistema"."CFGCLTESRFC" t3 ON t3."ID_RFC" = pr."ID_RFC" AND t3."STATUS" = 5
		 JOIN "BaseSistema"."CFGCLTES" t4 ON t4."ID_CLTE" = t3."ID_CLTE" AND t4."STATUS" = 3
		 JOIN "InfUsuario"."CATALOGOPROVEEDORES" t5 ON t5."RFC_EMISOR" = t1."RFCEMISOR" AND t5."STATUS" = 1
		 LEFT JOIN "InfUsuario"."CFDICONCEPTOS" t6 ON t6."ID_COMPROBANTE" = t1."ID_COMPROBANTE"
		 LEFT JOIN "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" t7 ON t7."ID_CONCEPTO" = t6."ID_CONCEPTO"
		 LEFT JOIN "InfUsuario"."CFDICONCEPTOSIMPUESTOSRETENCIONES" t8 ON t8."ID_CONCEPTO" = t6."ID_CONCEPTO"
		 LEFT JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTO" t9 ON t9."ID_COMPROBANTE" = t1."ID_COMPROBANTE"
		 LEFT JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOS" t10 ON t10."ID_COMPROBANTE" = t1."ID_COMPROBANTE"
		 LEFT JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOSDOCS" t11 ON t11."ID_PAGO" = t10."ID_PAGO"
		 LEFT JOIN "InfUsuario"."CFDICOMPROBANTERELACIONADOS" t14 ON t14."ID_COMPROBANTE" = t14."ID_COMPROBANTE"
		WHERE s."ID_USR_ALTA" = idusrsolicita
			AND s."RFC" = rfc
			AND t1."TIPODECOMPROBANTE" = 'P' AND
			CASE
				WHEN t10."FECHAPAGO" BETWEEN pe."FECHAINICIAL" AND pe."FECHAFINAL" THEN 1
				ELSE 0
			END = 0
		) t2
	WHERE T1."ID_CARGAXML"::character varying = t2."CVE_DESCARGA";
end;
$$;


ALTER PROCEDURE "BaseSistema"."MarcaPagosInValidosXfechas"(idusrsolicita bigint, rfc character) OWNER TO postgres;

--
-- TOC entry 385 (class 1255 OID 60967)
-- Name: MarcaPagosValidos(character); Type: PROCEDURE; Schema: BaseSistema; Owner: postgres
--

CREATE PROCEDURE "BaseSistema"."MarcaPagosValidos"(cve_descarga character)
    LANGUAGE plpgsql
    AS $$
begin
IF cve_descarga <> '' THEN
	UPDATE "BaseSistema"."LOGCARGAXML" T3
	SET "USAPAGO" = 1
	FROM (
		SELECT t1."CVE_DESCARGA",
			t12."ID_CARGAXML"
		FROM "InfUsuario"."CFDICOMPROBANTE" t1
		JOIN "BaseSistema"."LOGCARGAXML" th ON th."ID_CARGAXML"::character varying::bpchar = t1."CVE_DESCARGA"
		JOIN "BaseSistema"."LOGDESCARGAWSAUTH" t2 ON t2."CVE_DESCARGA" = th."CVE_DESCARGA"
		JOIN "BaseSistema"."CFGCLTESRFC" t3 ON t3."ID_RFC" = t2."ID_RFC" AND t3."STATUS" = 5
		JOIN "BaseSistema"."CFGCLTES" t4 ON t4."ID_CLTE" = t3."ID_CLTE" AND t4."STATUS" = 3
		JOIN "InfUsuario"."CATALOGOPROVEEDORES" t5 ON t5."RFC_EMISOR" = t1."RFCEMISOR" AND t5."STATUS" = 1
		LEFT JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTO" t9 ON t9."ID_COMPROBANTE" = t1."ID_COMPROBANTE"
		LEFT JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOS" t10 ON t10."ID_COMPROBANTE" = t1."ID_COMPROBANTE"
		LEFT JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOSDOCS" t11 ON t11."ID_PAGO" = t10."ID_PAGO"
		LEFT JOIN "BaseSistema"."LOGCARGAXML" t12 ON REPLACE(TRIM(t12."ARCHIVOXML"),'.xml','') = TRIM(t11."IDDOCUMENTO")
		WHERE t1."TIPODECOMPROBANTE" = 'P'
			AND t12."ARCHIVOXML" <> ''
		GROUP BY t1."CVE_DESCARGA",
			t12."ID_CARGAXML"	
		) T4
	WHERE T3."ID_CARGAXML" IN (T4."CVE_DESCARGA"::integer, T4."ID_CARGAXML"::integer);
END IF;
end;
$$;


ALTER PROCEDURE "BaseSistema"."MarcaPagosValidos"(cve_descarga character) OWNER TO postgres;

--
-- TOC entry 386 (class 1255 OID 60968)
-- Name: MarcaXML(character, bigint, character); Type: PROCEDURE; Schema: BaseSistema; Owner: postgres
--

CREATE PROCEDURE "BaseSistema"."MarcaXML"(cve_descarga character, id_rfc bigint, periodo character)
    LANGUAGE plpgsql
    AS $$
begin
IF cve_descarga <> '' THEN
	UPDATE "BaseSistema"."LOGCARGAXML" T3
	SET "STATUS" = 35, "FCARGA" = NOW(), "CVE_CARGA" = cve_descarga
	FROM (
		SELECT T1."CVE_DESCARGA", T1."PAGINA"
		FROM "BaseSistema"."LOGCARGAXML" T1
		INNER JOIN "BaseSistema"."LOGDESCARGAWSAUTH" T2 ON
			--T2."CVE_DESCARGA" = T1."CVE_DESCARGA" AND 
			T2."STATUS" = 31 AND
			T2."MSGERROR" <> '' AND	
			T2."ID_RFC" = id_rfc AND 
			T2."CVE_CARGA" IS NULL AND
			T2."TIPO" = 'CFDI'
		WHERE T1."CVE_CARGA" IS NULL AND T1."STATUS" = 34 AND 
			T1."PERIODO" = periodo AND 
			T1."STATUSPERIODO" = 38
		GROUP BY T1."CVE_DESCARGA", T1."PAGINA"
		ORDER BY T1."CVE_DESCARGA" DESC, T1."PAGINA"
		LIMIT 1
		) T4
	WHERE T4."CVE_DESCARGA" = T3."CVE_DESCARGA"
		AND T4."PAGINA" = T3."PAGINA";
END IF;
end;
$$;


ALTER PROCEDURE "BaseSistema"."MarcaXML"(cve_descarga character, id_rfc bigint, periodo character) OWNER TO postgres;

--
-- TOC entry 387 (class 1255 OID 60969)
-- Name: RecargaResultados(character); Type: PROCEDURE; Schema: BaseSistema; Owner: postgres
--

CREATE PROCEDURE "BaseSistema"."RecargaResultados"(cve_descarga character)
    LANGUAGE plpgsql
    AS $$
DECLARE HayDatos int;
begin

	SELECT COUNT(1) INTO HayDatos FROM "InfUsuario"."CFDICOMPROBANTE" WHERE "CVE_DESCARGA" = cve_descarga;
	RAISE NOTICE 'Hay datos XML (%)',HayDatos;
	
	--SELECT 1 as x INTO HayDatos;
	
	IF HayDatos > 0 THEN
		REFRESH MATERIALIZED VIEW "InfUsuario"."CFDIVALIDADOS69Y69B" WITH DATA;
	END IF;
	
end;
$$;


ALTER PROCEDURE "BaseSistema"."RecargaResultados"(cve_descarga character) OWNER TO postgres;

--
-- TOC entry 400 (class 1255 OID 69646)
-- Name: SolicitaReporte(character, character, bigint, character); Type: FUNCTION; Schema: BaseSistema; Owner: postgres
--

CREATE FUNCTION "BaseSistema"."SolicitaReporte"(cve_consulta character DEFAULT ''::bpchar, periodo character DEFAULT ''::bpchar, idusuario bigint DEFAULT 0, rfc character DEFAULT ''::bpchar) RETURNS TABLE(status character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE HayDatos int;
begin
	IF cve_consulta = '' THEN
		RETURN QUERY SELECT 'DIGITE UN CLAVE DE CONSULTA'::varchar AS "STATUS";
	ELSE
		IF periodo = '' THEN
			RETURN QUERY SELECT 'DIGITE EL PERIODO'::varchar AS "STATUS";
		ELSE
			IF idusuario = 0 THEN
				RETURN QUERY SELECT 'DIGITE EL ID DE USUARIO QUE SOLICITA EL REPORTE'::varchar AS "STATUS";
			ELSE
				IF rfc = '' THEN
					RETURN QUERY SELECT 'DIGITE EL RFC QUE SOLICITA PARA EL REPORTE'::varchar AS "STATUS";
				ELSE
					INSERT INTO "BaseSistema"."SOLCONSULPER"(
						"CVE_CONSULTA", "PERIODO", "FH_ALTA", "ID_USR_ALTA", "STATUS", "RFC")
					VALUES (cve_consulta, periodo, NOW(), idusuario, 40, rfc);

					SELECT "ID_CONSULTA"
					INTO HayDatos
					FROM "BaseSistema"."SOLCONSULPER"
					WHERE "CVE_CONSULTA" = cve_consulta AND
						"PERIODO" = periodo AND
						"ID_USR_ALTA" = idusuario AND
						"RFC" = rfc;

					IF HayDatos > 0 THEN
						RETURN QUERY SELECT 'EXITO'::varchar AS "STATUS";
					ELSE
						RETURN QUERY SELECT 'ERROR'::varchar AS "STATUS";
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;
end;
$$;


ALTER FUNCTION "BaseSistema"."SolicitaReporte"(cve_consulta character, periodo character, idusuario bigint, rfc character) OWNER TO postgres;

--
-- TOC entry 396 (class 1255 OID 69642)
-- Name: IVA_ACREDITABLE(bigint, character); Type: FUNCTION; Schema: InfUsuario; Owner: postgres
--

CREATE FUNCTION "InfUsuario"."IVA_ACREDITABLE"(idusrsolicita bigint DEFAULT 0, rfc character DEFAULT ''::bpchar) RETURNS TABLE("RFC_CLTE" character, "RFC_ASOC" character, "IMPORTEIVA" double precision)
    LANGUAGE plpgsql
    AS $$
begin
RETURN QUERY 
SELECT R."RFC_CLTE",
	R."RFC_ASOC",
	COALESCE(T1."IMPORTEIVA",0)
	+ COALESCE(T2."IMPORTEIVA",0)
	+ COALESCE(T3."IMPORTEIVA",0)
	- COALESCE(T4."IMPORTEIVA",0) 
	- COALESCE(T5."IMPORTEIVA",0) 
	+ COALESCE(T6."IMPORTEIVA",0) 
	- COALESCE(T7."IMPORTEIVA",0) 
	+ COALESCE(T8."IMPORTEIVA",0) AS "IMPORTEIVA"
FROM (
	SELECT t4."RFC" AS "RFC_CLTE",
		t3."RFC" AS "RFC_ASOC"
	FROM "InfUsuario"."CFDICOMPROBANTE" t1
	JOIN "BaseSistema"."LOGCARGAXML" th ON th."ID_CARGAXML"::character varying::bpchar = t1."CVE_DESCARGA" AND th."STATUS" = 36 AND th."STATUSPERIODO" = 38
	JOIN "BaseSistema"."SOLCONSULPER" s ON s."PERIODO" = th."PERIODO" AND s."STATUS" = 40
	JOIN "BaseSistema"."LOGDESCARGAWSPROCESO" pr ON pr."CVE_DESCARGA" = th."CVE_DESCARGA" AND pr."STATUS" = 31
	JOIN "BaseSistema"."CFGCLTESRFC" t3 ON t3."ID_RFC" = pr."ID_RFC" AND t3."STATUS" = 5
	JOIN "BaseSistema"."CFGCLTES" t4 ON t4."ID_CLTE" = t3."ID_CLTE" AND t4."STATUS" = 3
	WHERE s."ID_USR_ALTA" = idusrsolicita
		AND s."RFC" = rfc
	GROUP BY t4."RFC", t3."RFC"
	) R
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'ACREDITABLE' AND
		TT."IVA_SUBTIPO" = 'PAGOS_CONTADO'
	) T1 ON
	T1."RFC_CLTE" = R."RFC_CLTE" AND
	T1."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'ACREDITABLE' AND
		TT."IVA_SUBTIPO" = 'PAGO_ANTICIPO'
	) T2 ON
	T2."RFC_CLTE" = R."RFC_CLTE" AND
	T2."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'ACREDITABLE' AND
		TT."IVA_SUBTIPO" = 'APLIC_ANTICIPOS'
	) T3 ON
	T3."RFC_CLTE" = R."RFC_CLTE" AND
	T3."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'ACREDITABLE' AND
		TT."IVA_SUBTIPO" = 'DISMINUCION_APLIC_ANTICIPOS'
	) T4 ON
	T4."RFC_CLTE" = R."RFC_CLTE" AND
	T4."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'ACREDITABLE' AND
		TT."IVA_SUBTIPO" = 'DISMINUCION_NC'
	) T5 ON
	T5."RFC_CLTE" = R."RFC_CLTE" AND
	T5."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'ACREDITABLE' AND
		TT."IVA_SUBTIPO" = 'NOTAS_DEBITO'
	) T6 ON
	T6."RFC_CLTE" = R."RFC_CLTE" AND
	T6."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'ACREDITABLE' AND
		TT."IVA_SUBTIPO" = 'DEVOLUCIONES'
	) T7 ON
	T7."RFC_CLTE" = R."RFC_CLTE" AND
	T7."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'ACREDITABLE' AND
		TT."IVA_SUBTIPO" = 'PAGOS'
	) T8 ON
	T8."RFC_CLTE" = R."RFC_CLTE" AND
	T8."RFC_ASOC" = R."RFC_ASOC";
end;
$$;


ALTER FUNCTION "InfUsuario"."IVA_ACREDITABLE"(idusrsolicita bigint, rfc character) OWNER TO postgres;

--
-- TOC entry 395 (class 1255 OID 69641)
-- Name: IVA_DET_ASOC(bigint, character); Type: FUNCTION; Schema: InfUsuario; Owner: postgres
--

CREATE FUNCTION "InfUsuario"."IVA_DET_ASOC"(idusrsolicita bigint DEFAULT 0, rfc character DEFAULT ''::bpchar) RETURNS TABLE("RFC_CLTE" character, "RFC_ASOC" character, "IMPORTEIVA" double precision)
    LANGUAGE plpgsql
    AS $$
begin
RETURN QUERY 
SELECT t1."RFC_CLTE",
    t1."RFC_ASOC",
    sum(t1."IMPORTEIVA") AS "IMPORTEIVA"
   FROM "InfUsuario"."IVA_DET_GRAL"(idusrsolicita, rfc) t1
  GROUP BY 
  	t1."RFC_CLTE",
    t1."RFC_ASOC";
end;
$$;


ALTER FUNCTION "InfUsuario"."IVA_DET_ASOC"(idusrsolicita bigint, rfc character) OWNER TO postgres;

--
-- TOC entry 391 (class 1255 OID 69636)
-- Name: IVA_DET_COMPL(bigint, character); Type: FUNCTION; Schema: InfUsuario; Owner: postgres
--

CREATE FUNCTION "InfUsuario"."IVA_DET_COMPL"(idusrsolicita bigint DEFAULT 0, rfc character DEFAULT ''::bpchar) RETURNS TABLE("RFC_CLTE" character, "RFC_ASOC" character, "SERIE" character, "LUGAREXPEDICION" character, "COMPROBANTEDESCUENTO" double precision, "FORMAPAGO" character, "TIPOCAMBIO" double precision, "USOCFDI" character, "NOIDENTIFICACION" character, "CANTIDAD" double precision, "UNIDAD" character, "DESCRIPCION" character, "DESCUENTO" double precision, "VALORUNITARIO" double precision, "IMPORTE" double precision, "TASAOCUOTA" double precision, "TIPORELACION" character, "UUID" character, "FECHAPAGO" timestamp without time zone, "FORMADEPAGOP" character, "MONTO" double precision, "MONEDAP" character, "TIPOCAMBIOP" integer, "NUMEROOPERACION" integer, "RFCEMISORCTAORD" text, "CTAORDENANTE" text, "RFCEMISORCTABEN" text, "CTABENEFICIARIO" text, "DOCUMENTOSERIE" character, "NUMPARCIALIDAD" character, "MONEDADR" character, "TIPOCAMBIODR" integer, "METODODEPAGODR" character, "CLAVEPRODSERV" character, "FOLIO" character, "TRASLADOSIMPORTE" double precision, "CVE_DESCARGA" character, "IVA_TIPO" text, "IVA_SUBTIPO" text)
    LANGUAGE plpgsql
    AS $$
begin
RETURN QUERY 
SELECT 
	t4."RFC" AS "RFC_CLTE",
    t3."RFC" AS "RFC_ASOC",
	t1."SERIE",
    t1."LUGAREXPEDICION",
    t1."DESCUENTO" AS "COMPROBANTEDESCUENTO",
    t1."FORMAPAGO",
    t1."TIPOCAMBIO",
    t1."USOCFDI",
    t6."NOIDENTIFICACION",
    t6."CANTIDAD",
    t6."UNIDAD",
    t6."DESCRIPCION",
    t6."DESCUENTO",
    t6."VALORUNITARIO",
    t6."IMPORTE",
    t7."TASAOCUOTA",
    t14."TIPORELACION",
    t14."UUID",
    t10."FECHAPAGO",
    t10."FORMADEPAGOP",
    t10."MONTO",
    t10."MONEDAP",
    0 AS "TIPOCAMBIOP",
    0 AS "NUMEROOPERACION",
    ''::text AS "RFCEMISORCTAORD",
    ''::text AS "CTAORDENANTE",
    ''::text AS "RFCEMISORCTABEN",
    ''::text AS "CTABENEFICIARIO",
    t11."SERIE" AS "DOCUMENTOSERIE",
    t11."NUMPARCIALIDAD",
    t11."MONEDADR",
    0 AS "TIPOCAMBIODR",
    t11."METODODEPAGODR",
    t6."CLAVEPRODSERV",
    t1."FOLIO",
    t7."IMPORTE" AS "TRASLADOSIMPORTE",
    t1."CVE_DESCARGA",
	CASE
		--ACREDITABLE
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ACREDITABLE' --8
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" <> '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ACREDITABLE' --7
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '01'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ACREDITABLE' --4
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '02'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ACREDITABLE' --5
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '03'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ACREDITABLE' --2
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t1."FORMAPAGO" = '30'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ACREDITABLE' --3
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ACREDITABLE' --1
		--TRASLADADO
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '01'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'TRASLADADO' --13
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '02'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'TRASLADADO' --14
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '03'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'TRASLADADO' --11
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'TRASLADADO' --9
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" <> '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'TRASLADADO' --16
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t1."FORMAPAGO" = '30'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'TRASLADADO' --12
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'TRASLADADO' --10
		ELSE 'NO IDENTIFICADO'
	END AS "IVA_TIPO",
	CASE
		--ACREDITABLE
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'PAGO_ANTICIPO' --8
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" <> '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'PAGOS_CONTADO' --7
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '01'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'DISMINUCION_NC' --4
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '02'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'NOTAS_DEBITO' --5
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '03'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'DEVOLUCIONES' --2
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t1."FORMAPAGO" = '30'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'DISMINUCION_APLIC_ANTICIPOS' --3
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'APLIC_ANTICIPOS' --1
		--TRASLADADO
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '01'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'EGRESO_DESCUENTOS_NC' --13
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '02'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'NOTAS_DEBITO' --14
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '03'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'DEVOLUCIONES' --11
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ANTICIPOS' --9
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" <> '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'VTAS_CONTADO' --16
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t1."FORMAPAGO" = '30'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'EGRESO_APLIC_ANTICIPOS' --12
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'APLIC_ANTICIPOS' --10
		ELSE 'NO IDENTIFICADO'
	END AS "IVA_SUBTIPO"
	--SELECT t1.*
FROM "InfUsuario"."CFDICOMPROBANTE" t1
     JOIN "BaseSistema"."LOGCARGAXML" th ON th."ID_CARGAXML"::character varying::bpchar = t1."CVE_DESCARGA" AND th."STATUS" = 36 AND th."STATUSPERIODO" = 38
     JOIN "BaseSistema"."SOLCONSULPER" s ON s."PERIODO" = th."PERIODO" AND s."STATUS" = 40
     JOIN "BaseSistema"."LOGDESCARGAWSPROCESO" pr ON pr."CVE_DESCARGA" = th."CVE_DESCARGA" AND pr."STATUS" = 31
     JOIN "BaseSistema"."CFGCLTESRFC" t3 ON t3."ID_RFC" = pr."ID_RFC" AND t3."STATUS" = 5
     JOIN "BaseSistema"."CFGCLTES" t4 ON t4."ID_CLTE" = t3."ID_CLTE" AND t4."STATUS" = 3
     JOIN "InfUsuario"."CATALOGOPROVEEDORES" t5 ON t5."RFC_EMISOR" = t1."RFCEMISOR" AND t5."STATUS" = 1
     LEFT JOIN "InfUsuario"."CFDICONCEPTOS" t6 ON t6."ID_COMPROBANTE" = t1."ID_COMPROBANTE"
     LEFT JOIN "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" t7 ON t7."ID_CONCEPTO" = t6."ID_CONCEPTO" AND t7."NUM" = t6."NUM"
     LEFT JOIN "InfUsuario"."CFDICONCEPTOSIMPUESTOSRETENCIONES" t8 ON t8."ID_CONCEPTO" = t6."ID_CONCEPTO" AND t8."NUM" = t6."NUM"
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTO" t9 ON t9."ID_COMPROBANTE" = t1."ID_COMPROBANTE"
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOS" t10 ON t10."ID_COMPROBANTE" = t1."ID_COMPROBANTE"
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOSDOCS" t11 ON t11."ID_PAGO" = t10."ID_PAGO"
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTERELACIONADOS" t14 ON t14."ID_COMPROBANTE" = t1."ID_COMPROBANTE"
	WHERE s."ID_USR_ALTA" = idusrsolicita
		AND s."RFC" = rfc;
end;
$$;


ALTER FUNCTION "InfUsuario"."IVA_DET_COMPL"(idusrsolicita bigint, rfc character) OWNER TO postgres;

--
-- TOC entry 392 (class 1255 OID 69638)
-- Name: IVA_DET_CSV(bigint, character); Type: FUNCTION; Schema: InfUsuario; Owner: postgres
--

CREATE FUNCTION "InfUsuario"."IVA_DET_CSV"(idusrsolicita bigint DEFAULT 0, rfc character DEFAULT ''::bpchar) RETURNS TABLE("RFC_CLTE" character, "RFC_ASOC" character, "SERIE" character, "FOLIO" character, "TIMBREUUID" character, "FECHA" timestamp without time zone, "TIPODECOMPROBANTE" character, "LUGAREXPEDICION" character, "RFCEMISOR" character, "NOMBREEMISOR" character, "RFCRECEPTOR" character, "NOMBRERECEPTOR" character, "COMPROBANTEDESCUENTO" double precision, "SUBTOTAL" double precision, "TOTALIMPUESTOSTRASLADADOS" double precision, "RETENCIONIMPORTE" double precision, "TOTAL" double precision, "FORMAPAGO" character, "MONEDA" character, "TIPOCAMBIO" double precision, "USOCFDI" character, "CLAVEPRODSERV" character, "NOIDENTIFICACION" character, "CANTIDAD" double precision, "UNIDAD" character, "DESCRIPCION" character, "DESCUENTO" double precision, "VALORUNITARIO" double precision, "TRASLADOSIMPORTE" double precision, "IMPORTE" double precision, "TASAOCUOTA" double precision, "TIPORELACION" character, "UUID" character, "FECHAPAGO" timestamp without time zone, "FORMADEPAGOP" character, "MONTO" double precision, "MONEDAP" character, "TIPOCAMBIOP" integer, "NUMEROOPERACION" integer, "RFCEMISORCTAORD" text, "CTAORDENANTE" text, "RFCEMISORCTABEN" text, "CTABENEFICIARIO" text, "IDDOCUMENTO" character, "DOCUMENTOSERIE" character, "DOCUMENTOFOLIO" character, "IMPSALDOANT" double precision, "IMPPAGADO" double precision, "IMPSALDOINSOLUTO" double precision, "NUMPARCIALIDAD" character, "MONEDADR" character, "TIPOCAMBIODR" integer, "METODODEPAGODR" character, "CVE_DESCARGA" character, "IVA_TIPO" text, "IVA_SUBTIPO" text)
    LANGUAGE plpgsql
    AS $$
begin
RETURN QUERY 
SELECT t1."RFC_CLTE",
    t1."RFC_ASOC",
    t2."SERIE",
    t1."FOLIO",
    t1."UUID" AS "TIMBREUUID",
    t1."FECHA",
    t1."TIPODECOMPROBANTE",
    t2."LUGAREXPEDICION",
    t1."RFCEMISOR",
    t1."NOMBREEMISOR",
    t1."RFCRECEPTOR",
    t1."NOMBRERECEPTOR",
    t2."COMPROBANTEDESCUENTO",
    t1."SUBTOTAL",
    t1."TOTALIMPUESTOSTRASLADADOS",
    t1."IMPORTE" AS "RETENCIONIMPORTE",
    t1."TOTAL",
    t2."FORMAPAGO",
    t1."MONEDA",
    t2."TIPOCAMBIO",
    t2."USOCFDI",
    t1."CLAVEPRODSERV",
    t2."NOIDENTIFICACION",
    t2."CANTIDAD",
    t2."UNIDAD",
    t2."DESCRIPCION",
    t2."DESCUENTO",
    t2."VALORUNITARIO",
    t1."IMPORTEIVA",
    t2."IMPORTE",
    t2."TASAOCUOTA",
    t2."TIPORELACION",
    t2."UUID",
    t2."FECHAPAGO",
    t2."FORMADEPAGOP",
    t2."MONTO",
    t2."MONEDAP",
    t2."TIPOCAMBIOP",
    t2."NUMEROOPERACION",
    t2."RFCEMISORCTAORD",
    t2."CTAORDENANTE",
    t2."RFCEMISORCTABEN",
    t2."CTABENEFICIARIO",
    t1."IDDOCUMENTO",
    t2."DOCUMENTOSERIE",
    t1."DOCUMENTOFOLIO",
    t1."IMPSALDOANT",
    t1."IMPPAGADO",
    t1."IMPSALDOINSOLUTO",
    t2."NUMPARCIALIDAD",
    t2."MONEDADR",
    t2."TIPOCAMBIODR",
    t2."METODODEPAGODR",
    t2."CVE_DESCARGA",
	t2."IVA_TIPO",
	t2."IVA_SUBTIPO"
   FROM "InfUsuario"."IVA_DET_GRAL"(idusrsolicita, rfc) t1
     LEFT JOIN "InfUsuario"."IVA_DET_COMPL"(idusrsolicita, rfc) t2 ON 
	 	t2."RFC_CLTE" = t1."RFC_CLTE" AND 
		t2."RFC_ASOC" = t1."RFC_ASOC" AND 
		t2."FOLIO" = t1."FOLIO" AND 
		t2."UUID" = t1."UUID" AND
		t2."CLAVEPRODSERV" = t1."CLAVEPRODSERV" AND 
		t2."IVA_TIPO" = t1."IVA_TIPO" AND 
		t2."IVA_SUBTIPO" = t1."IVA_SUBTIPO";
end;
$$;


ALTER FUNCTION "InfUsuario"."IVA_DET_CSV"(idusrsolicita bigint, rfc character) OWNER TO postgres;

--
-- TOC entry 393 (class 1255 OID 69639)
-- Name: IVA_DET_FACT(bigint, character); Type: FUNCTION; Schema: InfUsuario; Owner: postgres
--

CREATE FUNCTION "InfUsuario"."IVA_DET_FACT"(idusrsolicita bigint DEFAULT 0, rfc character DEFAULT ''::bpchar) RETURNS TABLE("RFC_CLTE" character, "RFC_ASOC" character, "FOLIO" character, "UUID" character, "FECHA" timestamp without time zone, "TIPODECOMPROBANTE" character, "RFCEMISOR" character, "NOMBREEMISOR" character, "RFCRECEPTOR" character, "NOMBRERECEPTOR" character, "IVA_TIPO" text, "IVA_SUBTIPO" text, "IMPORTEIVA" double precision, "CVE_DESCARGA" character, "CANT" bigint)
    LANGUAGE plpgsql
    AS $$
begin
RETURN QUERY 
SELECT t1."RFC_CLTE",
    t1."RFC_ASOC",
    t1."FOLIO",
    t1."UUID",
    t1."FECHA",
    t1."TIPODECOMPROBANTE",
    t1."RFCEMISOR",
    t1."NOMBREEMISOR",
    t1."RFCRECEPTOR",
    t1."NOMBRERECEPTOR",
	t1."IVA_TIPO",
	t1."IVA_SUBTIPO",
    sum(t1."IMPORTEIVA") AS "IMPORTEIVA",
	t1."CVE_DESCARGA",
	COUNT(1) AS "CANT"
   FROM "InfUsuario"."IVA_DET_GRAL"(idusrsolicita, rfc) t1
  GROUP BY 
  	t1."RFC_CLTE",
    t1."RFC_ASOC",
    t1."FOLIO",
    t1."UUID",
    t1."FECHA",
    t1."TIPODECOMPROBANTE",
    t1."RFCEMISOR",
    t1."NOMBREEMISOR",
    t1."RFCRECEPTOR",
    t1."NOMBRERECEPTOR",
	t1."IVA_TIPO",
	t1."IVA_SUBTIPO",
		t1."CVE_DESCARGA";
end;
$$;


ALTER FUNCTION "InfUsuario"."IVA_DET_FACT"(idusrsolicita bigint, rfc character) OWNER TO postgres;

--
-- TOC entry 390 (class 1255 OID 69634)
-- Name: IVA_DET_GRAL(bigint, character); Type: FUNCTION; Schema: InfUsuario; Owner: postgres
--

CREATE FUNCTION "InfUsuario"."IVA_DET_GRAL"(idusrsolicita bigint DEFAULT 0, rfc character DEFAULT ''::bpchar) RETURNS TABLE("RFC_CLTE" character, "RFC_ASOC" character, "FOLIO" character, "UUID" character, "FECHA" timestamp without time zone, "TIPODECOMPROBANTE" character, "RFCEMISOR" character, "NOMBREEMISOR" character, "RFCRECEPTOR" character, "NOMBRERECEPTOR" character, "SUBTOTAL" double precision, "TOTALIMPUESTOSTRASLADADOS" double precision, "IMPORTE" double precision, "TOTAL" double precision, "MONEDA" character, "FECHAPAGO" timestamp without time zone, "MONTO" double precision, "MONEDAP" character, "IDDOCUMENTO" character, "DOCUMENTOFOLIO" character, "IMPSALDOANT" double precision, "IMPPAGADO" double precision, "IMPSALDOINSOLUTO" double precision, "IMPORTEIVA" double precision, "ESTATUS_69" character, "ESTATUS_69B" character, "ESTATUS_32D" text, "METODOPAGO" character, "FORMAPAGO" character, "CLAVEPRODSERV" character, "IMPUESTO" character, "TIPORELACION" character, "CVE_DESCARGA" character, "IVA_TIPO" text, "IVA_SUBTIPO" text)
    LANGUAGE plpgsql
    AS $$
begin
RETURN QUERY 
SELECT t4."RFC" AS "RFC_CLTE",
    t3."RFC" AS "RFC_ASOC",
    t1."FOLIO",
    t9."UUID",
    t1."FECHA",
    t1."TIPODECOMPROBANTE",
    t1."RFCEMISOR",
    t1."NOMBREEMISOR",
    t1."RFCRECEPTOR",
    t1."NOMBRERECEPTOR",
    t1."SUBTOTAL",
    t1."TOTALIMPUESTOSTRASLADADOS",
    t8."IMPORTE",
    t1."TOTAL",
    t1."MONEDA",
    t10."FECHAPAGO",
    t10."MONTO",
    t10."MONEDAP",
    t11."IDDOCUMENTO",
    t11."FOLIO" AS "DOCUMENTOFOLIO",
    t11."IMPSALDOANT",
    t11."IMPPAGADO",
    t11."IMPSALDOINSOLUTO",
	CASE
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" <> 'P' THEN COALESCE(t7."IMPORTE",0) 
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" <> 'P' THEN COALESCE(t7."IMPORTE",0)
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'P' THEN COALESCE(pa."IVAPAGOT",0)
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'P' THEN COALESCE(pa."IVAPAGOA",0)
		ELSE 0
	END AS "IMPORTEIVA",
    t5."ESTATUS_69",
    t5."ESTATUS_69B",
    NULL::text AS "ESTATUS_32D",
    t1."METODOPAGO",
    t1."FORMAPAGO",
    t6."CLAVEPRODSERV",
    t7."IMPUESTO",
    t14."TIPORELACION",
    t1."CVE_DESCARGA",
	CASE
		--ACREDITABLE
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ACREDITABLE' --8
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" <> '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ACREDITABLE' --7
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '01'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ACREDITABLE' --4
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '02'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ACREDITABLE' --5
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '03'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ACREDITABLE' --2
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t1."FORMAPAGO" = '30'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ACREDITABLE' --3
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ACREDITABLE' --1
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'P'::bpchar THEN 'ACREDITABLE' --10
		--TRASLADADO
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '01'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'TRASLADADO' --13
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '02'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'TRASLADADO' --14
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '03'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'TRASLADADO' --11
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'TRASLADADO' --9
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" <> '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'TRASLADADO' --16
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t1."FORMAPAGO" = '30'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'TRASLADADO' --12
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'TRASLADADO' --10
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'P'::bpchar THEN 'TRASLADADO' --10
		ELSE 'NO IDENTIFICADO'
	END AS "IVA_TIPO",
	CASE
		--ACREDITABLE
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'PAGO_ANTICIPO' --8
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" <> '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'PAGOS_CONTADO' --7
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '01'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'DISMINUCION_NC' --4
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '02'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'NOTAS_DEBITO' --5
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '03'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'DEVOLUCIONES' --2
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t1."FORMAPAGO" = '30'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'DISMINUCION_APLIC_ANTICIPOS' --3
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'APLIC_ANTICIPOS' --1
		WHEN t3."RFC" = t1."RFCRECEPTOR" AND t1."TIPODECOMPROBANTE" = 'P'::bpchar THEN 'PAGOS' --10
		--TRASLADADO
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '01'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'EGRESO_DESCUENTOS_NC' --13
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '02'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'NOTAS_DEBITO' --14
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t14."TIPORELACION" = '03'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'DEVOLUCIONES' --11
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'ANTICIPOS' --9
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND (t1."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND t6."CLAVEPRODSERV" <> '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'VTAS_CONTADO' --16
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'E'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t1."FORMAPAGO" = '30'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t6."CLAVEPRODSERV" = '84111506'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'EGRESO_APLIC_ANTICIPOS' --12
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'I'::bpchar AND t1."METODOPAGO" = 'PUE'::bpchar AND t14."TIPORELACION" = '07'::bpchar AND t7."IMPUESTO" = '002'::bpchar THEN 'APLIC_ANTICIPOS' --10
		WHEN t3."RFC" = t1."RFCEMISOR" AND t1."TIPODECOMPROBANTE" = 'P'::bpchar THEN 'PAGOS' --10
		ELSE 'NO IDENTIFICADO'
	END AS "IVA_SUBTIPO"
	--SELECT t1.*
   FROM "InfUsuario"."CFDICOMPROBANTE" t1
     JOIN "BaseSistema"."LOGCARGAXML" th ON th."ID_CARGAXML"::character varying::bpchar = 
	 	t1."CVE_DESCARGA" AND th."STATUS" = 36 AND th."STATUSPERIODO" = 38 AND th."USAPAGO" = 1
     JOIN "BaseSistema"."SOLCONSULPER" s ON s."PERIODO" = th."PERIODO" AND s."STATUS" = 40
     JOIN "BaseSistema"."LOGDESCARGAWSPROCESO" pr ON pr."CVE_DESCARGA" = th."CVE_DESCARGA" AND pr."STATUS" = 31 AND pr."TIPO" = 'CFDI'
     JOIN "BaseSistema"."CFGCLTESRFC" t3 ON t3."ID_RFC" = pr."ID_RFC" AND t3."STATUS" = 5
     JOIN "BaseSistema"."CFGCLTES" t4 ON t4."ID_CLTE" = t3."ID_CLTE" AND t4."STATUS" = 3
     JOIN "InfUsuario"."CATALOGOPROVEEDORES" t5 ON t5."RFC_EMISOR" = t1."RFCEMISOR" AND t5."STATUS" = 1
     LEFT JOIN "InfUsuario"."CFDICONCEPTOS" t6 ON t6."ID_COMPROBANTE" = t1."ID_COMPROBANTE"
     LEFT JOIN "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" t7 ON t7."ID_CONCEPTO" = t6."ID_CONCEPTO" AND t7."NUM" = t6."NUM"
     LEFT JOIN "InfUsuario"."CFDICONCEPTOSIMPUESTOSRETENCIONES" t8 ON t8."ID_CONCEPTO" = t6."ID_CONCEPTO" AND t8."NUM" = t6."NUM"
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTO" t9 ON t9."ID_COMPROBANTE" = t1."ID_COMPROBANTE"
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOS" t10 ON t10."ID_COMPROBANTE" = t1."ID_COMPROBANTE"
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOSDOCS" t11 ON t11."ID_PAGO" = t10."ID_PAGO"
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTERELACIONADOS" t14 ON t14."ID_COMPROBANTE" = t1."ID_COMPROBANTE"
	 --WHERE t9."UUID" = 'c699310d-052c-42ed-b012-7a04e986d1e8'
	 LEFT JOIN (
		SELECT t11."IDDOCUMENTO", 
		 	(t12."MONTO" / (1 + t7."TASAOCUOTA")) * t7."TASAOCUOTA" AS "IVAPAGOT",
		 	(t12."MONTO" / (1 + t8."TASAOCUOTA")) * t8."TASAOCUOTA" AS "IVAPAGOA"
		FROM "InfUsuario"."CFDICOMPROBANTE" t9
		LEFT JOIN "InfUsuario"."CFDICONCEPTOS" t6 ON t6."ID_COMPROBANTE" = t9."ID_COMPROBANTE"
		LEFT JOIN "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" t7 ON t7."ID_CONCEPTO" = t6."ID_CONCEPTO" AND t7."NUM" = t6."NUM"
		LEFT JOIN "InfUsuario"."CFDICONCEPTOSIMPUESTOSRETENCIONES" t8 ON t8."ID_CONCEPTO" = t6."ID_CONCEPTO" AND t8."NUM" = t6."NUM"
		LEFT JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTO" t10 ON t10."ID_COMPROBANTE" = t9."ID_COMPROBANTE"
		LEFT JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOS" t12 ON
		 	t12."ID_COMPROBANTE" = t10."ID_COMPROBANTE"
		INNER JOIN "BaseSistema"."LOGCARGAXML" t5 ON
			t5."ID_CARGAXML"::character varying = t9."CVE_DESCARGA" AND
			t5."STATUS" = 36 AND t5."STATUSPERIODO" = 38 AND t5."USAPAGO" = 1
		INNER JOIN "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOSDOCS" t11 ON 
		 	REPLACE(t5."ARCHIVOXML",'.xml', '') = t11."IDDOCUMENTO"
		WHERE t9."TIPODECOMPROBANTE" = 'P' AND 
		 	(t7."IMPUESTO" = '002' OR t8."IMPUESTO" = '002')
	 	) pa ON pa."IDDOCUMENTO" = t11."IDDOCUMENTO"
	WHERE s."ID_USR_ALTA" = idusrsolicita
		AND s."RFC" = rfc;
end;
$$;


ALTER FUNCTION "InfUsuario"."IVA_DET_GRAL"(idusrsolicita bigint, rfc character) OWNER TO postgres;

--
-- TOC entry 394 (class 1255 OID 69640)
-- Name: IVA_DET_TIPO(bigint, character); Type: FUNCTION; Schema: InfUsuario; Owner: postgres
--

CREATE FUNCTION "InfUsuario"."IVA_DET_TIPO"(idusrsolicita bigint DEFAULT 0, rfc character DEFAULT ''::bpchar) RETURNS TABLE("RFC_CLTE" character, "RFC_ASOC" character, "IVA_TIPO" text, "IVA_SUBTIPO" text, "IMPORTEIVA" double precision, "CANT" bigint)
    LANGUAGE plpgsql
    AS $$
begin
RETURN QUERY 
SELECT t1."RFC_CLTE",
    t1."RFC_ASOC",
    t1."IVA_TIPO",
	t1."IVA_SUBTIPO",
    sum(t1."IMPORTEIVA") AS "IMPORTEIVA",
	COUNT(1) AS "CANT"
   FROM "InfUsuario"."IVA_DET_GRAL"(idusrsolicita, rfc) t1
  GROUP BY 
  	t1."RFC_CLTE",
    t1."RFC_ASOC",
    t1."IVA_TIPO",
	t1."IVA_SUBTIPO";
end;
$$;


ALTER FUNCTION "InfUsuario"."IVA_DET_TIPO"(idusrsolicita bigint, rfc character) OWNER TO postgres;

--
-- TOC entry 399 (class 1255 OID 69645)
-- Name: IVA_DEVOLUCION(bigint, character); Type: FUNCTION; Schema: InfUsuario; Owner: postgres
--

CREATE FUNCTION "InfUsuario"."IVA_DEVOLUCION"(idusrsolicita bigint DEFAULT 0, rfc character DEFAULT ''::bpchar) RETURNS TABLE("RFC_CLTE" character, "RFC_ASOC" character, "IMPORTEIVA" double precision)
    LANGUAGE plpgsql
    AS $$
begin
RETURN QUERY 
SELECT R."RFC_CLTE",
	R."RFC_ASOC",
	COALESCE(T1."IMPORTEIVA",0)
	- COALESCE(T2."IMPORTEIVA",0)
	- COALESCE(T3."IMPORTEIVA",0) AS "IMPORTEIVA"
FROM (
	SELECT t4."RFC" AS "RFC_CLTE",
		t3."RFC" AS "RFC_ASOC"
	FROM "InfUsuario"."CFDICOMPROBANTE" t1
	JOIN "BaseSistema"."LOGCARGAXML" th ON th."ID_CARGAXML"::character varying::bpchar = t1."CVE_DESCARGA" AND th."STATUS" = 36 AND th."STATUSPERIODO" = 38
	JOIN "BaseSistema"."SOLCONSULPER" s ON s."PERIODO" = th."PERIODO" AND s."STATUS" = 40
	JOIN "BaseSistema"."LOGDESCARGAWSPROCESO" pr ON pr."CVE_DESCARGA" = th."CVE_DESCARGA" AND pr."STATUS" = 31
	JOIN "BaseSistema"."CFGCLTESRFC" t3 ON t3."ID_RFC" = pr."ID_RFC" AND t3."STATUS" = 5
	JOIN "BaseSistema"."CFGCLTES" t4 ON t4."ID_CLTE" = t3."ID_CLTE" AND t4."STATUS" = 3
	WHERE s."ID_USR_ALTA" = idusrsolicita
		AND s."RFC" = rfc
	GROUP BY t4."RFC", t3."RFC"
	) R
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_TRASLADADO"(idusrsolicita, rfc) TT
	) T1 ON
	T1."RFC_CLTE" = R."RFC_CLTE" AND
	T1."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_ACREDITABLE"(idusrsolicita, rfc) TT
	) T2 ON
	T2."RFC_CLTE" = R."RFC_CLTE" AND
	T2."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_OBSERVABLE"(idusrsolicita, rfc) TT
	) T3 ON
	T3."RFC_CLTE" = R."RFC_CLTE" AND
	T3."RFC_ASOC" = R."RFC_ASOC";
end;
$$;


ALTER FUNCTION "InfUsuario"."IVA_DEVOLUCION"(idusrsolicita bigint, rfc character) OWNER TO postgres;

--
-- TOC entry 398 (class 1255 OID 69644)
-- Name: IVA_OBSERVABLE(bigint, character); Type: FUNCTION; Schema: InfUsuario; Owner: postgres
--

CREATE FUNCTION "InfUsuario"."IVA_OBSERVABLE"(idusrsolicita bigint DEFAULT 0, rfc character DEFAULT ''::bpchar) RETURNS TABLE("RFC_CLTE" character, "RFC_ASOC" character, "IMPORTEIVA" double precision)
    LANGUAGE plpgsql
    AS $$
begin
RETURN QUERY 
SELECT TT."RFC_CLTE",
	TT."RFC_ASOC",
	SUM(TT."IMPORTEIVA") AS "IMPORTEIVA"
FROM "InfUsuario"."IVA_DET_GRAL"(idusrsolicita, rfc) TT
WHERE "IVA_TIPO" = 'ACREDITABLE' AND
	("ESTATUS_69" IN ('NO LOCALIZADO','SENTENCIAS') OR 
	"ESTATUS_69B" <> '')
GROUP BY TT."RFC_CLTE",
	TT."RFC_ASOC";
end;
$$;


ALTER FUNCTION "InfUsuario"."IVA_OBSERVABLE"(idusrsolicita bigint, rfc character) OWNER TO postgres;

--
-- TOC entry 397 (class 1255 OID 69643)
-- Name: IVA_TRASLADADO(bigint, character); Type: FUNCTION; Schema: InfUsuario; Owner: postgres
--

CREATE FUNCTION "InfUsuario"."IVA_TRASLADADO"(idusrsolicita bigint DEFAULT 0, rfc character DEFAULT ''::bpchar) RETURNS TABLE("RFC_CLTE" character, "RFC_ASOC" character, "IMPORTEIVA" double precision)
    LANGUAGE plpgsql
    AS $$
begin
RETURN QUERY 
SELECT R."RFC_CLTE",
	R."RFC_ASOC",
	COALESCE(T1."IMPORTEIVA",0)
	+ COALESCE(T2."IMPORTEIVA",0)
	+ COALESCE(T3."IMPORTEIVA",0)
	- COALESCE(T4."IMPORTEIVA",0) 
	- COALESCE(T5."IMPORTEIVA",0) 
	+ COALESCE(T6."IMPORTEIVA",0) 
	- COALESCE(T7."IMPORTEIVA",0) 
	+ COALESCE(T8."IMPORTEIVA",0) AS "IMPORTEIVA"
FROM (
	SELECT t4."RFC" AS "RFC_CLTE",
		t3."RFC" AS "RFC_ASOC"
	FROM "InfUsuario"."CFDICOMPROBANTE" t1
	JOIN "BaseSistema"."LOGCARGAXML" th ON th."ID_CARGAXML"::character varying::bpchar = t1."CVE_DESCARGA" AND th."STATUS" = 36 AND th."STATUSPERIODO" = 38
	JOIN "BaseSistema"."SOLCONSULPER" s ON s."PERIODO" = th."PERIODO" AND s."STATUS" = 40
	JOIN "BaseSistema"."LOGDESCARGAWSPROCESO" pr ON pr."CVE_DESCARGA" = th."CVE_DESCARGA" AND pr."STATUS" = 31
	JOIN "BaseSistema"."CFGCLTESRFC" t3 ON t3."ID_RFC" = pr."ID_RFC" AND t3."STATUS" = 5
	JOIN "BaseSistema"."CFGCLTES" t4 ON t4."ID_CLTE" = t3."ID_CLTE" AND t4."STATUS" = 3
	WHERE s."ID_USR_ALTA" = idusrsolicita
		AND s."RFC" = rfc
	GROUP BY t4."RFC", t3."RFC"
	) R
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'TRASLADADO' AND
		TT."IVA_SUBTIPO" = 'VTAS_CONTADO'
	) T1 ON
	T1."RFC_CLTE" = R."RFC_CLTE" AND
	T1."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'TRASLADADO' AND
		TT."IVA_SUBTIPO" = 'ANTICIPOS'
	) T2 ON
	T2."RFC_CLTE" = R."RFC_CLTE" AND
	T2."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'TRASLADADO' AND
		TT."IVA_SUBTIPO" = 'APLIC_ANTICIPOS'
	) T3 ON
	T3."RFC_CLTE" = R."RFC_CLTE" AND
	T3."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'TRASLADADO' AND
		TT."IVA_SUBTIPO" = 'EGRESO_APLIC_ANTICIPOS'
	) T4 ON
	T4."RFC_CLTE" = R."RFC_CLTE" AND
	T4."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'TRASLADADO' AND
		TT."IVA_SUBTIPO" = 'EGRESO_DESCUENTOS_NC'
	) T5 ON
	T5."RFC_CLTE" = R."RFC_CLTE" AND
	T5."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'TRASLADADO' AND
		TT."IVA_SUBTIPO" = 'NOTAS_DEBITO'
	) T6 ON
	T6."RFC_CLTE" = R."RFC_CLTE" AND
	T6."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'TRASLADADO' AND
		TT."IVA_SUBTIPO" = 'DEVOLUCIONES'
	) T7 ON
	T7."RFC_CLTE" = R."RFC_CLTE" AND
	T7."RFC_ASOC" = R."RFC_ASOC"
LEFT JOIN (
	SELECT TT."RFC_CLTE", TT."RFC_ASOC", TT."IMPORTEIVA" 
	FROM "InfUsuario"."IVA_DET_TIPO"(idusrsolicita, rfc) TT
	WHERE TT."IVA_TIPO" = 'TRASLADADO' AND
		TT."IVA_SUBTIPO" = 'PAGOS'
	) T8 ON
	T8."RFC_CLTE" = R."RFC_CLTE" AND
	T8."RFC_ASOC" = R."RFC_ASOC";
end;
$$;


ALTER FUNCTION "InfUsuario"."IVA_TRASLADADO"(idusrsolicita bigint, rfc character) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 207 (class 1259 OID 60983)
-- Name: CATACCIONES; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CATACCIONES" (
    "ID_ACCION" integer NOT NULL,
    "DESCRIPCION" character(25)
);


ALTER TABLE "BaseSistema"."CATACCIONES" OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 60986)
-- Name: CATACCIONES_ID_ACCION_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."CATACCIONES_ID_ACCION_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "BaseSistema"."CATACCIONES_ID_ACCION_seq" OWNER TO postgres;

--
-- TOC entry 3711 (class 0 OID 0)
-- Dependencies: 208
-- Name: CATACCIONES_ID_ACCION_seq; Type: SEQUENCE OWNED BY; Schema: BaseSistema; Owner: postgres
--

ALTER SEQUENCE "BaseSistema"."CATACCIONES_ID_ACCION_seq" OWNED BY "BaseSistema"."CATACCIONES"."ID_ACCION";


--
-- TOC entry 209 (class 1259 OID 60988)
-- Name: CATPROCESOS_ID_PROCESO_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."CATPROCESOS_ID_PROCESO_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "BaseSistema"."CATPROCESOS_ID_PROCESO_seq" OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 60990)
-- Name: CATPROCESOS; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CATPROCESOS" (
    "ID_PROCESO" integer DEFAULT nextval('"BaseSistema"."CATPROCESOS_ID_PROCESO_seq"'::regclass) NOT NULL,
    "DESCRIPCION" character(30)
);


ALTER TABLE "BaseSistema"."CATPROCESOS" OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 60994)
-- Name: CATPROCESOSSTATUS_ID_STATUS_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."CATPROCESOSSTATUS_ID_STATUS_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "BaseSistema"."CATPROCESOSSTATUS_ID_STATUS_seq" OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 60996)
-- Name: CATPROCESOSSTATUS; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CATPROCESOSSTATUS" (
    "ID_PROCESOSTATUS" integer DEFAULT nextval('"BaseSistema"."CATPROCESOSSTATUS_ID_STATUS_seq"'::regclass) NOT NULL,
    "DESCRIPCION" character(20)
);


ALTER TABLE "BaseSistema"."CATPROCESOSSTATUS" OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 61000)
-- Name: CATSTATUS; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CATSTATUS" (
    "ID_STATUS" integer NOT NULL,
    "ID_PROCESO" bigint NOT NULL,
    "ID_PROCESOSTATUS" bigint NOT NULL
);


ALTER TABLE "BaseSistema"."CATSTATUS" OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 61003)
-- Name: CATSTATUS_ID_STATUS_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."CATSTATUS_ID_STATUS_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "BaseSistema"."CATSTATUS_ID_STATUS_seq" OWNER TO postgres;

--
-- TOC entry 3712 (class 0 OID 0)
-- Dependencies: 214
-- Name: CATSTATUS_ID_STATUS_seq; Type: SEQUENCE OWNED BY; Schema: BaseSistema; Owner: postgres
--

ALTER SEQUENCE "BaseSistema"."CATSTATUS_ID_STATUS_seq" OWNED BY "BaseSistema"."CATSTATUS"."ID_STATUS";


--
-- TOC entry 215 (class 1259 OID 61005)
-- Name: CFGALMACEN_ID_ALMACEN_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."CFGALMACEN_ID_ALMACEN_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "BaseSistema"."CFGALMACEN_ID_ALMACEN_seq" OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 61007)
-- Name: CLTES_ID_CLTE_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."CLTES_ID_CLTE_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "BaseSistema"."CLTES_ID_CLTE_seq" OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 61009)
-- Name: CFGCLTES; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CFGCLTES" (
    "ID_CLTE" integer DEFAULT nextval('"BaseSistema"."CLTES_ID_CLTE_seq"'::regclass) NOT NULL,
    "NAME_CLTE" character(500) NOT NULL,
    "RFC" character(13) NOT NULL,
    "PAIS" character(25),
    "ESTADO" character(25),
    "CIUDAD" character(25),
    "MPIO_DEL" character(25),
    "COLONIA" character(25) NOT NULL,
    "CP" character(5) NOT NULL,
    "ID_REPOSITORIO" bigint,
    "FH_ALTA" timestamp without time zone,
    "FH_BAJA" timestamp without time zone,
    "ID_USR_ALTA" bigint,
    "ID_USR_BAJA" bigint,
    "STATUS" bigint
);


ALTER TABLE "BaseSistema"."CFGCLTES" OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 61016)
-- Name: CFGCLTESCREDENCIALES_ID_CRED_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."CFGCLTESCREDENCIALES_ID_CRED_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "BaseSistema"."CFGCLTESCREDENCIALES_ID_CRED_seq" OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 61018)
-- Name: CFGCLTESCREDENCIALES; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CFGCLTESCREDENCIALES" (
    "ID_CRED" integer DEFAULT nextval('"BaseSistema"."CFGCLTESCREDENCIALES_ID_CRED_seq"'::regclass) NOT NULL,
    "ID_RFC" bigint NOT NULL,
    "PASS" text NOT NULL,
    "LLAVE" bytea NOT NULL,
    "CERTIF" bytea NOT NULL,
    "FH_ALTA" timestamp without time zone,
    "FH_BAJA" timestamp without time zone,
    "ID_USR_ALTA" bigint,
    "ID_USR_BAJA" bigint,
    "STATUS" bigint
);


ALTER TABLE "BaseSistema"."CFGCLTESCREDENCIALES" OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 61025)
-- Name: CFGCLTESREPOSITORIOS; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CFGCLTESREPOSITORIOS" (
    "ID_REPOSITORIO" integer DEFAULT nextval('"BaseSistema"."CFGALMACEN_ID_ALMACEN_seq"'::regclass) NOT NULL,
    "NAME_REPO" character(15) NOT NULL,
    "DESCRIPCION" character(150),
    "FH_ALTA" timestamp without time zone,
    "FH_BAJA" timestamp without time zone,
    "ID_USR_ALTA" bigint,
    "ID_USR_BAJA" bigint,
    "STATUS" bigint
);


ALTER TABLE "BaseSistema"."CFGCLTESREPOSITORIOS" OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 61029)
-- Name: RFCS_ID_RFC_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."RFCS_ID_RFC_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "BaseSistema"."RFCS_ID_RFC_seq" OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 61031)
-- Name: CFGCLTESRFC; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CFGCLTESRFC" (
    "ID_RFC" integer DEFAULT nextval('"BaseSistema"."RFCS_ID_RFC_seq"'::regclass) NOT NULL,
    "RFC" character(13) NOT NULL,
    "RAZON_SOC" character(255) NOT NULL,
    "ID_CLTE" bigint NOT NULL,
    "FH_ALTA" timestamp without time zone,
    "FH_BAJA" time(1) without time zone,
    "ID_USR_ALTA" bigint,
    "ID_USR_BAJA" bigint,
    "STATUS" bigint
);


ALTER TABLE "BaseSistema"."CFGCLTESRFC" OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 61035)
-- Name: CFGFILE_ID_FILE_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."CFGFILE_ID_FILE_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "BaseSistema"."CFGFILE_ID_FILE_seq" OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 61037)
-- Name: CFGFILE; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CFGFILE" (
    "ID_FILE" integer DEFAULT nextval('"BaseSistema"."CFGFILE_ID_FILE_seq"'::regclass) NOT NULL,
    "TYP_FILE" character(5) NOT NULL,
    "DESCR" character(70) NOT NULL,
    "DESCARGA_WEBS_CARGA" character(1) NOT NULL,
    "RT_DEST" character(250),
    "RT_BKP" character(250) NOT NULL,
    "VIG_BKP" bigint NOT NULL,
    "RT_ORIG_HTTP" character(250),
    "FILE_NAME" character(50),
    "TBL_DEST" character(15),
    "UNZIP" bit(1) NOT NULL,
    "SAVE_ID_CLTE" bit(1) NOT NULL,
    "FH_ALTA" timestamp without time zone,
    "FH_BAJA" timestamp without time zone,
    "ID_USR_ALTA" bigint,
    "ID_USR_BAJA" bigint,
    "STATUS" bigint,
    "TEMPORAL" character(30)
);


ALTER TABLE "BaseSistema"."CFGFILE" OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 61044)
-- Name: CFGFILECOLUMNS_ID_COLUMN_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."CFGFILECOLUMNS_ID_COLUMN_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "BaseSistema"."CFGFILECOLUMNS_ID_COLUMN_seq" OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 61046)
-- Name: CFGFILECOLUMNS; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CFGFILECOLUMNS" (
    "ID_COL" integer DEFAULT nextval('"BaseSistema"."CFGFILECOLUMNS_ID_COLUMN_seq"'::regclass) NOT NULL,
    "COLUMNA" character(100),
    "CAMPO" character(100),
    "FH_ALTA" timestamp without time zone,
    "FH_BAJA" timestamp without time zone,
    "ID_USR_ALTA" bigint,
    "ID_USR_BAJA" bigint,
    "STATUS" bigint,
    "REG" character(100),
    "VALOR" character(5000)
);


ALTER TABLE "BaseSistema"."CFGFILECOLUMNS" OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 61053)
-- Name: LOGDESCARGAFILE; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."LOGDESCARGAFILE" (
    "ID_DESCARGA" integer NOT NULL,
    "CVE_DESCARGA" character(15) NOT NULL,
    "FH_DESCARGA" timestamp without time zone NOT NULL,
    "FH_PUB" timestamp without time zone,
    "ID_FILE" bigint NOT NULL,
    "ID_RFC" bigint,
    "STATUS" bigint NOT NULL,
    "MSGERROR" text
);


ALTER TABLE "BaseSistema"."LOGDESCARGAFILE" OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 61059)
-- Name: CFGFILEUNLOADS_ID_UNLOAD_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."CFGFILEUNLOADS_ID_UNLOAD_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "BaseSistema"."CFGFILEUNLOADS_ID_UNLOAD_seq" OWNER TO postgres;

--
-- TOC entry 3713 (class 0 OID 0)
-- Dependencies: 228
-- Name: CFGFILEUNLOADS_ID_UNLOAD_seq; Type: SEQUENCE OWNED BY; Schema: BaseSistema; Owner: postgres
--

ALTER SEQUENCE "BaseSistema"."CFGFILEUNLOADS_ID_UNLOAD_seq" OWNED BY "BaseSistema"."LOGDESCARGAFILE"."ID_DESCARGA";


--
-- TOC entry 229 (class 1259 OID 61061)
-- Name: CFGPERIODOS; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CFGPERIODOS" (
    "ID_PERIODO" integer NOT NULL,
    "PERIODO" character(6),
    "FECHAINICIAL" timestamp without time zone,
    "FECHAFINAL" timestamp without time zone,
    "FH_ALTA" timestamp without time zone,
    "FH_BAJA" timestamp without time zone,
    "ID_USR_ALTA" bigint,
    "ID_USR_BAJA" bigint,
    "STATUS" bigint
);


ALTER TABLE "BaseSistema"."CFGPERIODOS" OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 61064)
-- Name: CFGPERIODOS_ID_PERIODO_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."CFGPERIODOS_ID_PERIODO_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "BaseSistema"."CFGPERIODOS_ID_PERIODO_seq" OWNER TO postgres;

--
-- TOC entry 3714 (class 0 OID 0)
-- Dependencies: 230
-- Name: CFGPERIODOS_ID_PERIODO_seq; Type: SEQUENCE OWNED BY; Schema: BaseSistema; Owner: postgres
--

ALTER SEQUENCE "BaseSistema"."CFGPERIODOS_ID_PERIODO_seq" OWNED BY "BaseSistema"."CFGPERIODOS"."ID_PERIODO";


--
-- TOC entry 231 (class 1259 OID 61066)
-- Name: INF69; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."INF69" (
    "ID_INF" integer,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(50),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "AGRUPACION" character(50),
    "SELECCION" bigint
);


ALTER TABLE "BaseSistema"."INF69" OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 61069)
-- Name: INF69B; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."INF69B" (
    "ID_INF" integer,
    "NO" bigint,
    "RFC" character(13),
    "NAME_CONTR" character(500),
    "SITUACION_CONTR" character(40),
    "FH_OFIC_GLO_PRESUN_SAT" character(150),
    "FH_PUB_PRESUN_SAT" date,
    "FH_OFIC_GLO_PRESUN_DOF" character(150),
    "FH_PUB_PRESUN_DOF" date,
    "FH_OFIC_GLO_DESV_SAT" character(150),
    "FH_OFIC_GLO_DESV_DOF" character(150),
    "FH_PUB_SAT_DEF" date,
    "FH_PUB_DOF_DEF" date,
    "FH_OFIC_GLO_SENT_FAV" character(150),
    "FH_PUB_SENT_FAV_SAT" date,
    "FH_OFIC_GLO_SENT_FAV_SAT" character(150),
    "FH_PUB_SENT_FAV_DOF" date,
    "FH_PUB_69B" date,
    "FH_PUB_DESV_SAT" character(150),
    "FH_PUB_DESV_DOF" character(150)
);


ALTER TABLE "BaseSistema"."INF69B" OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 61075)
-- Name: LOGCARGAXML_ID_CARGAXML_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."LOGCARGAXML_ID_CARGAXML_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "BaseSistema"."LOGCARGAXML_ID_CARGAXML_seq" OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 61077)
-- Name: LOGCARGAXML; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."LOGCARGAXML" (
    "ID_CARGAXML" integer DEFAULT nextval('"BaseSistema"."LOGCARGAXML_ID_CARGAXML_seq"'::regclass) NOT NULL,
    "CVE_DESCARGA" character(15),
    "ARCHIVOXML" character(50),
    "STATUS" bigint,
    "MSGERROR" text,
    "FCARGA" timestamp without time zone,
    "PAGINA" bigint,
    "CVE_CARGA" character(15),
    "USAPAGO" bigint,
    "PERIODO" character(6),
    "STATUSPERIODO" bigint,
    "EMISOR_RECEPTOR" character(10)
);


ALTER TABLE "BaseSistema"."LOGCARGAXML" OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 61084)
-- Name: LOGDESCARGAWSCABECERA_ID_DESCARGA_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."LOGDESCARGAWSCABECERA_ID_DESCARGA_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "BaseSistema"."LOGDESCARGAWSCABECERA_ID_DESCARGA_seq" OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 61086)
-- Name: LOGDESCARGAWSAUTH; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."LOGDESCARGAWSAUTH" (
    "ID_DESCARGAWS" integer DEFAULT nextval('"BaseSistema"."LOGDESCARGAWSCABECERA_ID_DESCARGA_seq"'::regclass) NOT NULL,
    "CVE_DESCARGA" character(15) NOT NULL,
    "ID_RFC" bigint NOT NULL,
    "FH_INI" timestamp without time zone,
    "FH_FIN" timestamp without time zone,
    "TIPO" character(15) NOT NULL,
    "TOKEN" text,
    "STATUS" bigint,
    "MSGERROR" text,
    "CVE_CARGA" character(15),
    "EMISOR_RECEPTOR" character(10)
);


ALTER TABLE "BaseSistema"."LOGDESCARGAWSAUTH" OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 61093)
-- Name: LOGDESCARGAWSPROCESO_ID_DESCARGA_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."LOGDESCARGAWSPROCESO_ID_DESCARGA_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "BaseSistema"."LOGDESCARGAWSPROCESO_ID_DESCARGA_seq" OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 61095)
-- Name: LOGDESCARGAWSPROCESO; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."LOGDESCARGAWSPROCESO" (
    "ID_PROCESOWS" integer DEFAULT nextval('"BaseSistema"."LOGDESCARGAWSPROCESO_ID_DESCARGA_seq"'::regclass) NOT NULL,
    "CVE_DESCARGA" character(15) NOT NULL,
    "ID_RFC" bigint NOT NULL,
    "FH_INI" timestamp without time zone,
    "FH_FIN" timestamp without time zone,
    "TIPO" character(15) NOT NULL,
    "IDPROCESO" text,
    "STATUS" bigint,
    "MSGERROR" text,
    "EMISOR_RECEPTOR" character(10)
);


ALTER TABLE "BaseSistema"."LOGDESCARGAWSPROCESO" OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 61102)
-- Name: PROVEEDORES69; Type: MATERIALIZED VIEW; Schema: BaseSistema; Owner: postgres
--

CREATE MATERIALIZED VIEW "BaseSistema"."PROVEEDORES69" AS
 SELECT ta."RFC",
    ta."AGRUPACION" AS "ESTATUS_69",
        CASE
            WHEN (ta."SELECCION" = 1) THEN min(ta."FH_PUB")
            WHEN (ta."SELECCION" = 2) THEN min(ta."FH_PUB")
            ELSE max(ta."FH_PUB")
        END AS "FH_PUB_69"
   FROM ("BaseSistema"."INF69" ta
     JOIN ( SELECT "INF69"."RFC",
            min("INF69"."SELECCION") AS "SELECCION"
           FROM "BaseSistema"."INF69"
          GROUP BY "INF69"."RFC") tb ON (((tb."RFC" = ta."RFC") AND (tb."SELECCION" = ta."SELECCION"))))
  GROUP BY ta."RFC", ta."AGRUPACION", ta."SELECCION"
  WITH NO DATA;


ALTER TABLE "BaseSistema"."PROVEEDORES69" OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 61107)
-- Name: PROVEEDORES69B; Type: MATERIALIZED VIEW; Schema: BaseSistema; Owner: postgres
--

CREATE MATERIALIZED VIEW "BaseSistema"."PROVEEDORES69B" AS
 SELECT ta."RFC",
    ta."SITUACION_CONTR" AS "ESTATUS_69B",
    ta."FH_PUB_69B"
   FROM ("BaseSistema"."INF69B" ta
     JOIN ( SELECT "INF69B"."RFC",
            max("INF69B"."FH_PUB_69B") AS "FH_PUB_69B"
           FROM "BaseSistema"."INF69B"
          GROUP BY "INF69B"."RFC") tb ON (((ta."RFC" = tb."RFC") AND (ta."FH_PUB_69B" = tb."FH_PUB_69B"))))
  WITH NO DATA;


ALTER TABLE "BaseSistema"."PROVEEDORES69B" OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 61112)
-- Name: RELACIONSTATUS; Type: VIEW; Schema: BaseSistema; Owner: postgres
--

CREATE VIEW "BaseSistema"."RELACIONSTATUS" AS
 SELECT s."ID_STATUS",
    s."ID_PROCESO",
    p."DESCRIPCION" AS "PROCESO",
    s."ID_PROCESOSTATUS",
    ps."DESCRIPCION" AS "PROCESOSTATUS"
   FROM (("BaseSistema"."CATSTATUS" s
     LEFT JOIN "BaseSistema"."CATPROCESOS" p ON ((p."ID_PROCESO" = s."ID_PROCESO")))
     LEFT JOIN "BaseSistema"."CATPROCESOSSTATUS" ps ON ((ps."ID_PROCESOSTATUS" = s."ID_PROCESOSTATUS")));


ALTER TABLE "BaseSistema"."RELACIONSTATUS" OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 61116)
-- Name: SOLCONSULPER; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."SOLCONSULPER" (
    "ID_CONSULTA" integer NOT NULL,
    "CVE_CONSULTA" character(15),
    "PERIODO" character(6),
    "FH_ALTA" timestamp without time zone,
    "FH_BAJA" timestamp without time zone,
    "ID_USR_ALTA" bigint,
    "ID_USR_BAJA" bigint,
    "STATUS" bigint,
    "RFC" character(13)
);


ALTER TABLE "BaseSistema"."SOLCONSULPER" OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 61119)
-- Name: SOLCONSULPER_ID_CONSULTA_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."SOLCONSULPER_ID_CONSULTA_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "BaseSistema"."SOLCONSULPER_ID_CONSULTA_seq" OWNER TO postgres;

--
-- TOC entry 3715 (class 0 OID 0)
-- Dependencies: 243
-- Name: SOLCONSULPER_ID_CONSULTA_seq; Type: SEQUENCE OWNED BY; Schema: BaseSistema; Owner: postgres
--

ALTER SEQUENCE "BaseSistema"."SOLCONSULPER_ID_CONSULTA_seq" OWNED BY "BaseSistema"."SOLCONSULPER"."ID_CONSULTA";


--
-- TOC entry 244 (class 1259 OID 61121)
-- Name: USRSIST_ID_USR_seq; Type: SEQUENCE; Schema: BaseSistema; Owner: postgres
--

CREATE SEQUENCE "BaseSistema"."USRSIST_ID_USR_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "BaseSistema"."USRSIST_ID_USR_seq" OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 61123)
-- Name: INF69_ID_INF_seq; Type: SEQUENCE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE SEQUENCE "BaseSistemaHistorico"."INF69_ID_INF_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "BaseSistemaHistorico"."INF69_ID_INF_seq" OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 61125)
-- Name: INF69; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(50),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(50),
    "SELECCION" bigint
)
PARTITION BY RANGE ("FH_HIST");


ALTER TABLE "BaseSistemaHistorico"."INF69" OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 61129)
-- Name: INF69B_ID_INF_seq; Type: SEQUENCE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE SEQUENCE "BaseSistemaHistorico"."INF69B_ID_INF_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "BaseSistemaHistorico"."INF69B_ID_INF_seq" OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 61131)
-- Name: INF69B; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69B" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"'::regclass) NOT NULL,
    "NO" bigint,
    "RFC" character(13),
    "NAME_CONTR" character(500),
    "SITUACION_CONTR" character(40),
    "FH_OFIC_GLO_PRESUN_SAT" character(150),
    "FH_PUB_PRESUN_SAT" date,
    "FH_OFIC_GLO_PRESUN_DOF" character(150),
    "FH_PUB_PRESUN_DOF" date,
    "FH_OFIC_GLO_DESV_SAT" character(150),
    "FH_OFIC_GLO_DESV_DOF" character(150),
    "FH_PUB_SAT_DEF" date,
    "FH_PUB_DOF_DEF" date,
    "FH_OFIC_GLO_SENT_FAV" character(150),
    "FH_PUB_SENT_FAV_SAT" date,
    "FH_OFIC_GLO_SENT_FAV_SAT" character(150),
    "FH_PUB_SENT_FAV_DOF" date,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "FH_PUB_69B" date,
    "FH_OFIC_GLO_SENT_FAV_1" character(150),
    "FH_PUB_DESV_SAT" character(150),
    "FH_PUB_DESV_DOF" character(150)
)
PARTITION BY RANGE ("FH_HIST");


ALTER TABLE "BaseSistemaHistorico"."INF69B" OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 61135)
-- Name: INF69B_y2019m09; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69B_y2019m09" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"'::regclass) NOT NULL,
    "NO" bigint,
    "RFC" character(13),
    "NAME_CONTR" character(500),
    "SITUACION_CONTR" character(40),
    "FH_OFIC_GLO_PRESUN_SAT" character(150),
    "FH_PUB_PRESUN_SAT" date,
    "FH_OFIC_GLO_PRESUN_DOF" character(150),
    "FH_PUB_PRESUN_DOF" date,
    "FH_OFIC_GLO_DESV_SAT" character(150),
    "FH_OFIC_GLO_DESV_DOF" character(150),
    "FH_PUB_SAT_DEF" date,
    "FH_PUB_DOF_DEF" date,
    "FH_OFIC_GLO_SENT_FAV" character(150),
    "FH_PUB_SENT_FAV_SAT" date,
    "FH_OFIC_GLO_SENT_FAV_SAT" character(150),
    "FH_PUB_SENT_FAV_DOF" date,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "FH_PUB_69B" date,
    "FH_OFIC_GLO_SENT_FAV_1" character(150),
    "FH_PUB_DESV_SAT" character(150),
    "FH_PUB_DESV_DOF" character(150)
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69B" ATTACH PARTITION "BaseSistemaHistorico"."INF69B_y2019m09" FOR VALUES FROM ('2019-09-01') TO ('2019-10-01');


ALTER TABLE "BaseSistemaHistorico"."INF69B_y2019m09" OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 61142)
-- Name: INF69B_y2019m10; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69B_y2019m10" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"'::regclass) NOT NULL,
    "NO" bigint,
    "RFC" character(13),
    "NAME_CONTR" character(500),
    "SITUACION_CONTR" character(40),
    "FH_OFIC_GLO_PRESUN_SAT" character(150),
    "FH_PUB_PRESUN_SAT" date,
    "FH_OFIC_GLO_PRESUN_DOF" character(150),
    "FH_PUB_PRESUN_DOF" date,
    "FH_OFIC_GLO_DESV_SAT" character(150),
    "FH_OFIC_GLO_DESV_DOF" character(150),
    "FH_PUB_SAT_DEF" date,
    "FH_PUB_DOF_DEF" date,
    "FH_OFIC_GLO_SENT_FAV" character(150),
    "FH_PUB_SENT_FAV_SAT" date,
    "FH_OFIC_GLO_SENT_FAV_SAT" character(150),
    "FH_PUB_SENT_FAV_DOF" date,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "FH_PUB_69B" date,
    "FH_OFIC_GLO_SENT_FAV_1" character(150),
    "FH_PUB_DESV_SAT" character(150),
    "FH_PUB_DESV_DOF" character(150)
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69B" ATTACH PARTITION "BaseSistemaHistorico"."INF69B_y2019m10" FOR VALUES FROM ('2019-10-01') TO ('2019-11-01');


ALTER TABLE "BaseSistemaHistorico"."INF69B_y2019m10" OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 61149)
-- Name: INF69B_y2019m11; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69B_y2019m11" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"'::regclass) NOT NULL,
    "NO" bigint,
    "RFC" character(13),
    "NAME_CONTR" character(500),
    "SITUACION_CONTR" character(40),
    "FH_OFIC_GLO_PRESUN_SAT" character(150),
    "FH_PUB_PRESUN_SAT" date,
    "FH_OFIC_GLO_PRESUN_DOF" character(150),
    "FH_PUB_PRESUN_DOF" date,
    "FH_OFIC_GLO_DESV_SAT" character(150),
    "FH_OFIC_GLO_DESV_DOF" character(150),
    "FH_PUB_SAT_DEF" date,
    "FH_PUB_DOF_DEF" date,
    "FH_OFIC_GLO_SENT_FAV" character(150),
    "FH_PUB_SENT_FAV_SAT" date,
    "FH_OFIC_GLO_SENT_FAV_SAT" character(150),
    "FH_PUB_SENT_FAV_DOF" date,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "FH_PUB_69B" date,
    "FH_OFIC_GLO_SENT_FAV_1" character(150),
    "FH_PUB_DESV_SAT" character(150),
    "FH_PUB_DESV_DOF" character(150)
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69B" ATTACH PARTITION "BaseSistemaHistorico"."INF69B_y2019m11" FOR VALUES FROM ('2019-11-01') TO ('2019-12-01');


ALTER TABLE "BaseSistemaHistorico"."INF69B_y2019m11" OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 61156)
-- Name: INF69B_y2019m12; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69B_y2019m12" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"'::regclass) NOT NULL,
    "NO" bigint,
    "RFC" character(13),
    "NAME_CONTR" character(500),
    "SITUACION_CONTR" character(40),
    "FH_OFIC_GLO_PRESUN_SAT" character(150),
    "FH_PUB_PRESUN_SAT" date,
    "FH_OFIC_GLO_PRESUN_DOF" character(150),
    "FH_PUB_PRESUN_DOF" date,
    "FH_OFIC_GLO_DESV_SAT" character(150),
    "FH_OFIC_GLO_DESV_DOF" character(150),
    "FH_PUB_SAT_DEF" date,
    "FH_PUB_DOF_DEF" date,
    "FH_OFIC_GLO_SENT_FAV" character(150),
    "FH_PUB_SENT_FAV_SAT" date,
    "FH_OFIC_GLO_SENT_FAV_SAT" character(150),
    "FH_PUB_SENT_FAV_DOF" date,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "FH_PUB_69B" date,
    "FH_OFIC_GLO_SENT_FAV_1" character(150),
    "FH_PUB_DESV_SAT" character(150),
    "FH_PUB_DESV_DOF" character(150)
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69B" ATTACH PARTITION "BaseSistemaHistorico"."INF69B_y2019m12" FOR VALUES FROM ('2019-12-01') TO ('2020-01-01');


ALTER TABLE "BaseSistemaHistorico"."INF69B_y2019m12" OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 61163)
-- Name: INF69B_y2020m01; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69B_y2020m01" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"'::regclass) NOT NULL,
    "NO" bigint,
    "RFC" character(13),
    "NAME_CONTR" character(500),
    "SITUACION_CONTR" character(40),
    "FH_OFIC_GLO_PRESUN_SAT" character(150),
    "FH_PUB_PRESUN_SAT" date,
    "FH_OFIC_GLO_PRESUN_DOF" character(150),
    "FH_PUB_PRESUN_DOF" date,
    "FH_OFIC_GLO_DESV_SAT" character(150),
    "FH_OFIC_GLO_DESV_DOF" character(150),
    "FH_PUB_SAT_DEF" date,
    "FH_PUB_DOF_DEF" date,
    "FH_OFIC_GLO_SENT_FAV" character(150),
    "FH_PUB_SENT_FAV_SAT" date,
    "FH_OFIC_GLO_SENT_FAV_SAT" character(150),
    "FH_PUB_SENT_FAV_DOF" date,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "FH_PUB_69B" date,
    "FH_OFIC_GLO_SENT_FAV_1" character(150),
    "FH_PUB_DESV_SAT" character(150),
    "FH_PUB_DESV_DOF" character(150)
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69B" ATTACH PARTITION "BaseSistemaHistorico"."INF69B_y2020m01" FOR VALUES FROM ('2020-01-01') TO ('2020-02-01');


ALTER TABLE "BaseSistemaHistorico"."INF69B_y2020m01" OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 61170)
-- Name: INF69B_y2020m02; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69B_y2020m02" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"'::regclass) NOT NULL,
    "NO" bigint,
    "RFC" character(13),
    "NAME_CONTR" character(500),
    "SITUACION_CONTR" character(40),
    "FH_OFIC_GLO_PRESUN_SAT" character(150),
    "FH_PUB_PRESUN_SAT" date,
    "FH_OFIC_GLO_PRESUN_DOF" character(150),
    "FH_PUB_PRESUN_DOF" date,
    "FH_OFIC_GLO_DESV_SAT" character(150),
    "FH_OFIC_GLO_DESV_DOF" character(150),
    "FH_PUB_SAT_DEF" date,
    "FH_PUB_DOF_DEF" date,
    "FH_OFIC_GLO_SENT_FAV" character(150),
    "FH_PUB_SENT_FAV_SAT" date,
    "FH_OFIC_GLO_SENT_FAV_SAT" character(150),
    "FH_PUB_SENT_FAV_DOF" date,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "FH_PUB_69B" date,
    "FH_OFIC_GLO_SENT_FAV_1" character(150),
    "FH_PUB_DESV_SAT" character(150),
    "FH_PUB_DESV_DOF" character(150)
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69B" ATTACH PARTITION "BaseSistemaHistorico"."INF69B_y2020m02" FOR VALUES FROM ('2020-02-01') TO ('2020-03-01');


ALTER TABLE "BaseSistemaHistorico"."INF69B_y2020m02" OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 61177)
-- Name: INF69B_y2020m03; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69B_y2020m03" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"'::regclass) NOT NULL,
    "NO" bigint,
    "RFC" character(13),
    "NAME_CONTR" character(500),
    "SITUACION_CONTR" character(40),
    "FH_OFIC_GLO_PRESUN_SAT" character(150),
    "FH_PUB_PRESUN_SAT" date,
    "FH_OFIC_GLO_PRESUN_DOF" character(150),
    "FH_PUB_PRESUN_DOF" date,
    "FH_OFIC_GLO_DESV_SAT" character(150),
    "FH_OFIC_GLO_DESV_DOF" character(150),
    "FH_PUB_SAT_DEF" date,
    "FH_PUB_DOF_DEF" date,
    "FH_OFIC_GLO_SENT_FAV" character(150),
    "FH_PUB_SENT_FAV_SAT" date,
    "FH_OFIC_GLO_SENT_FAV_SAT" character(150),
    "FH_PUB_SENT_FAV_DOF" date,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "FH_PUB_69B" date,
    "FH_OFIC_GLO_SENT_FAV_1" character(150),
    "FH_PUB_DESV_SAT" character(150),
    "FH_PUB_DESV_DOF" character(150)
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69B" ATTACH PARTITION "BaseSistemaHistorico"."INF69B_y2020m03" FOR VALUES FROM ('2020-03-01') TO ('2020-04-01');


ALTER TABLE "BaseSistemaHistorico"."INF69B_y2020m03" OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 61184)
-- Name: INF69B_y2020m04; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69B_y2020m04" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"'::regclass) NOT NULL,
    "NO" bigint,
    "RFC" character(13),
    "NAME_CONTR" character(500),
    "SITUACION_CONTR" character(40),
    "FH_OFIC_GLO_PRESUN_SAT" character(150),
    "FH_PUB_PRESUN_SAT" date,
    "FH_OFIC_GLO_PRESUN_DOF" character(150),
    "FH_PUB_PRESUN_DOF" date,
    "FH_OFIC_GLO_DESV_SAT" character(150),
    "FH_OFIC_GLO_DESV_DOF" character(150),
    "FH_PUB_SAT_DEF" date,
    "FH_PUB_DOF_DEF" date,
    "FH_OFIC_GLO_SENT_FAV" character(150),
    "FH_PUB_SENT_FAV_SAT" date,
    "FH_OFIC_GLO_SENT_FAV_SAT" character(150),
    "FH_PUB_SENT_FAV_DOF" date,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "FH_PUB_69B" date,
    "FH_OFIC_GLO_SENT_FAV_1" character(150),
    "FH_PUB_DESV_SAT" character(150),
    "FH_PUB_DESV_DOF" character(150)
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69B" ATTACH PARTITION "BaseSistemaHistorico"."INF69B_y2020m04" FOR VALUES FROM ('2020-04-01') TO ('2020-05-01');


ALTER TABLE "BaseSistemaHistorico"."INF69B_y2020m04" OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 61191)
-- Name: INF69B_y2020m05; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69B_y2020m05" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"'::regclass) NOT NULL,
    "NO" bigint,
    "RFC" character(13),
    "NAME_CONTR" character(500),
    "SITUACION_CONTR" character(40),
    "FH_OFIC_GLO_PRESUN_SAT" character(150),
    "FH_PUB_PRESUN_SAT" date,
    "FH_OFIC_GLO_PRESUN_DOF" character(150),
    "FH_PUB_PRESUN_DOF" date,
    "FH_OFIC_GLO_DESV_SAT" character(150),
    "FH_OFIC_GLO_DESV_DOF" character(150),
    "FH_PUB_SAT_DEF" date,
    "FH_PUB_DOF_DEF" date,
    "FH_OFIC_GLO_SENT_FAV" character(150),
    "FH_PUB_SENT_FAV_SAT" date,
    "FH_OFIC_GLO_SENT_FAV_SAT" character(150),
    "FH_PUB_SENT_FAV_DOF" date,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "FH_PUB_69B" date,
    "FH_OFIC_GLO_SENT_FAV_1" character(150),
    "FH_PUB_DESV_SAT" character(150),
    "FH_PUB_DESV_DOF" character(150)
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69B" ATTACH PARTITION "BaseSistemaHistorico"."INF69B_y2020m05" FOR VALUES FROM ('2020-05-01') TO ('2020-06-01');


ALTER TABLE "BaseSistemaHistorico"."INF69B_y2020m05" OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 61198)
-- Name: INF69B_y2020m06; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69B_y2020m06" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"'::regclass) NOT NULL,
    "NO" bigint,
    "RFC" character(13),
    "NAME_CONTR" character(500),
    "SITUACION_CONTR" character(40),
    "FH_OFIC_GLO_PRESUN_SAT" character(150),
    "FH_PUB_PRESUN_SAT" date,
    "FH_OFIC_GLO_PRESUN_DOF" character(150),
    "FH_PUB_PRESUN_DOF" date,
    "FH_OFIC_GLO_DESV_SAT" character(150),
    "FH_OFIC_GLO_DESV_DOF" character(150),
    "FH_PUB_SAT_DEF" date,
    "FH_PUB_DOF_DEF" date,
    "FH_OFIC_GLO_SENT_FAV" character(150),
    "FH_PUB_SENT_FAV_SAT" date,
    "FH_OFIC_GLO_SENT_FAV_SAT" character(150),
    "FH_PUB_SENT_FAV_DOF" date,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "FH_PUB_69B" date,
    "FH_OFIC_GLO_SENT_FAV_1" character(150),
    "FH_PUB_DESV_SAT" character(150),
    "FH_PUB_DESV_DOF" character(150)
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69B" ATTACH PARTITION "BaseSistemaHistorico"."INF69B_y2020m06" FOR VALUES FROM ('2020-06-01') TO ('2020-07-01');


ALTER TABLE "BaseSistemaHistorico"."INF69B_y2020m06" OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 61205)
-- Name: INF69B_y2020m07; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69B_y2020m07" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"'::regclass) NOT NULL,
    "NO" bigint,
    "RFC" character(13),
    "NAME_CONTR" character(500),
    "SITUACION_CONTR" character(40),
    "FH_OFIC_GLO_PRESUN_SAT" character(150),
    "FH_PUB_PRESUN_SAT" date,
    "FH_OFIC_GLO_PRESUN_DOF" character(150),
    "FH_PUB_PRESUN_DOF" date,
    "FH_OFIC_GLO_DESV_SAT" character(150),
    "FH_OFIC_GLO_DESV_DOF" character(150),
    "FH_PUB_SAT_DEF" date,
    "FH_PUB_DOF_DEF" date,
    "FH_OFIC_GLO_SENT_FAV" character(150),
    "FH_PUB_SENT_FAV_SAT" date,
    "FH_OFIC_GLO_SENT_FAV_SAT" character(150),
    "FH_PUB_SENT_FAV_DOF" date,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "FH_PUB_69B" date,
    "FH_OFIC_GLO_SENT_FAV_1" character(150),
    "FH_PUB_DESV_SAT" character(150),
    "FH_PUB_DESV_DOF" character(150)
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69B" ATTACH PARTITION "BaseSistemaHistorico"."INF69B_y2020m07" FOR VALUES FROM ('2020-07-01') TO ('2020-08-01');


ALTER TABLE "BaseSistemaHistorico"."INF69B_y2020m07" OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 61212)
-- Name: INF69B_y2020m08; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69B_y2020m08" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"'::regclass) NOT NULL,
    "NO" bigint,
    "RFC" character(13),
    "NAME_CONTR" character(500),
    "SITUACION_CONTR" character(40),
    "FH_OFIC_GLO_PRESUN_SAT" character(150),
    "FH_PUB_PRESUN_SAT" date,
    "FH_OFIC_GLO_PRESUN_DOF" character(150),
    "FH_PUB_PRESUN_DOF" date,
    "FH_OFIC_GLO_DESV_SAT" character(150),
    "FH_OFIC_GLO_DESV_DOF" character(150),
    "FH_PUB_SAT_DEF" date,
    "FH_PUB_DOF_DEF" date,
    "FH_OFIC_GLO_SENT_FAV" character(150),
    "FH_PUB_SENT_FAV_SAT" date,
    "FH_OFIC_GLO_SENT_FAV_SAT" character(150),
    "FH_PUB_SENT_FAV_DOF" date,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "FH_PUB_69B" date,
    "FH_OFIC_GLO_SENT_FAV_1" character(150),
    "FH_PUB_DESV_SAT" character(150),
    "FH_PUB_DESV_DOF" character(150)
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69B" ATTACH PARTITION "BaseSistemaHistorico"."INF69B_y2020m08" FOR VALUES FROM ('2020-08-01') TO ('2020-09-01');


ALTER TABLE "BaseSistemaHistorico"."INF69B_y2020m08" OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 61219)
-- Name: INF69_y2019m09; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2019m09" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(50),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(50),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2019m09" FOR VALUES FROM ('2019-09-01') TO ('2019-10-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2019m09" OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 61223)
-- Name: INF69_y2019m10; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2019m10" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(50),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(50),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2019m10" FOR VALUES FROM ('2019-10-01') TO ('2019-11-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2019m10" OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 61227)
-- Name: INF69_y2019m11; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2019m11" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(50),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(50),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2019m11" FOR VALUES FROM ('2019-11-01') TO ('2019-12-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2019m11" OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 61231)
-- Name: INF69_y2019m12; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2019m12" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(50),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(50),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2019m12" FOR VALUES FROM ('2019-12-01') TO ('2020-01-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2019m12" OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 61235)
-- Name: INF69_y2020m01; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m01" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(50),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(50),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m01" FOR VALUES FROM ('2020-01-01') TO ('2020-02-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m01" OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 61239)
-- Name: INF69_y2020m02; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m02" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(50),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(50),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m02" FOR VALUES FROM ('2020-02-01') TO ('2020-03-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m02" OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 61243)
-- Name: INF69_y2020m03; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m03" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(50),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(50),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m03" FOR VALUES FROM ('2020-03-01') TO ('2020-04-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m03" OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 61247)
-- Name: INF69_y2020m04; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m04" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(50),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(50),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m04" FOR VALUES FROM ('2020-04-01') TO ('2020-05-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m04" OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 61251)
-- Name: INF69_y2020m05; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m05" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(50),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(50),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m05" FOR VALUES FROM ('2020-05-01') TO ('2020-06-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m05" OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 61255)
-- Name: INF69_y2020m06; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m06" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(50),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(50),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m06" FOR VALUES FROM ('2020-06-01') TO ('2020-07-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m06" OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 61259)
-- Name: INF69_y2020m07; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m07" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(50),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(50),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m07" FOR VALUES FROM ('2020-07-01') TO ('2020-08-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m07" OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 61263)
-- Name: INF69_y2020m08; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m08" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(50),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(50),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m08" FOR VALUES FROM ('2020-08-01') TO ('2020-09-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m08" OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 61267)
-- Name: INF32D_ID_INF_seq; Type: SEQUENCE; Schema: InfHistorica; Owner: postgres
--

CREATE SEQUENCE "InfHistorica"."INF32D_ID_INF_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "InfHistorica"."INF32D_ID_INF_seq" OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 61269)
-- Name: INF32D; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INF32D" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INF32D_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
)
PARTITION BY RANGE ("FH_PERIODO");


ALTER TABLE "InfHistorica"."INF32D" OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 61273)
-- Name: INF32D_y2019m09; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INF32D_y2019m09" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INF32D_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INF32D" ATTACH PARTITION "InfHistorica"."INF32D_y2019m09" FOR VALUES FROM ('2019-09-01') TO ('2019-10-01');


ALTER TABLE "InfHistorica"."INF32D_y2019m09" OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 61277)
-- Name: INF32D_y2019m10; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INF32D_y2019m10" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INF32D_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INF32D" ATTACH PARTITION "InfHistorica"."INF32D_y2019m10" FOR VALUES FROM ('2019-10-01') TO ('2019-11-01');


ALTER TABLE "InfHistorica"."INF32D_y2019m10" OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 61281)
-- Name: INF32D_y2019m11; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INF32D_y2019m11" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INF32D_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INF32D" ATTACH PARTITION "InfHistorica"."INF32D_y2019m11" FOR VALUES FROM ('2019-11-01') TO ('2019-12-01');


ALTER TABLE "InfHistorica"."INF32D_y2019m11" OWNER TO postgres;

--
-- TOC entry 278 (class 1259 OID 61285)
-- Name: INF32D_y2019m12; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INF32D_y2019m12" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INF32D_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INF32D" ATTACH PARTITION "InfHistorica"."INF32D_y2019m12" FOR VALUES FROM ('2019-12-01') TO ('2020-01-01');


ALTER TABLE "InfHistorica"."INF32D_y2019m12" OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 61289)
-- Name: INF32D_y2020m01; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INF32D_y2020m01" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INF32D_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INF32D" ATTACH PARTITION "InfHistorica"."INF32D_y2020m01" FOR VALUES FROM ('2020-01-01') TO ('2020-02-01');


ALTER TABLE "InfHistorica"."INF32D_y2020m01" OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 61293)
-- Name: INF32D_y2020m02; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INF32D_y2020m02" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INF32D_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INF32D" ATTACH PARTITION "InfHistorica"."INF32D_y2020m02" FOR VALUES FROM ('2020-02-01') TO ('2020-03-01');


ALTER TABLE "InfHistorica"."INF32D_y2020m02" OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 61297)
-- Name: INF32D_y2020m03; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INF32D_y2020m03" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INF32D_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INF32D" ATTACH PARTITION "InfHistorica"."INF32D_y2020m03" FOR VALUES FROM ('2020-03-01') TO ('2020-04-01');


ALTER TABLE "InfHistorica"."INF32D_y2020m03" OWNER TO postgres;

--
-- TOC entry 282 (class 1259 OID 61301)
-- Name: INF32D_y2020m04; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INF32D_y2020m04" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INF32D_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INF32D" ATTACH PARTITION "InfHistorica"."INF32D_y2020m04" FOR VALUES FROM ('2020-04-01') TO ('2020-05-01');


ALTER TABLE "InfHistorica"."INF32D_y2020m04" OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 61305)
-- Name: INF32D_y2020m05; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INF32D_y2020m05" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INF32D_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INF32D" ATTACH PARTITION "InfHistorica"."INF32D_y2020m05" FOR VALUES FROM ('2020-05-01') TO ('2020-06-01');


ALTER TABLE "InfHistorica"."INF32D_y2020m05" OWNER TO postgres;

--
-- TOC entry 284 (class 1259 OID 61309)
-- Name: INF32D_y2020m06; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INF32D_y2020m06" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INF32D_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INF32D" ATTACH PARTITION "InfHistorica"."INF32D_y2020m06" FOR VALUES FROM ('2020-06-01') TO ('2020-07-01');


ALTER TABLE "InfHistorica"."INF32D_y2020m06" OWNER TO postgres;

--
-- TOC entry 285 (class 1259 OID 61313)
-- Name: INF32D_y2020m07; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INF32D_y2020m07" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INF32D_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INF32D" ATTACH PARTITION "InfHistorica"."INF32D_y2020m07" FOR VALUES FROM ('2020-07-01') TO ('2020-08-01');


ALTER TABLE "InfHistorica"."INF32D_y2020m07" OWNER TO postgres;

--
-- TOC entry 286 (class 1259 OID 61317)
-- Name: INF32D_y2020m08; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INF32D_y2020m08" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INF32D_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INF32D" ATTACH PARTITION "InfHistorica"."INF32D_y2020m08" FOR VALUES FROM ('2020-08-01') TO ('2020-09-01');


ALTER TABLE "InfHistorica"."INF32D_y2020m08" OWNER TO postgres;

--
-- TOC entry 287 (class 1259 OID 61321)
-- Name: INFMETA_ID_INF_seq; Type: SEQUENCE; Schema: InfHistorica; Owner: postgres
--

CREATE SEQUENCE "InfHistorica"."INFMETA_ID_INF_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "InfHistorica"."INFMETA_ID_INF_seq" OWNER TO postgres;

--
-- TOC entry 288 (class 1259 OID 61323)
-- Name: INFMETA; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INFMETA" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INFMETA_ID_INF_seq"'::regclass) NOT NULL,
    "UUID" character(40),
    "RFC_EMISOR" character(13),
    "NAME_EMISOR" character(155),
    "RFC_RECEPTOR" character(13),
    "NAME_RECEPTOR" character(155),
    "RFC_PAC" character(13),
    "FH_EMISION" timestamp with time zone,
    "FH_CERT_SAT" timestamp with time zone,
    "MNTO" bigint,
    "EFECTO_COMP" character(2),
    "STATUS" bigint,
    "FH_CANC" timestamp with time zone,
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
)
PARTITION BY RANGE ("FH_PERIODO");


ALTER TABLE "InfHistorica"."INFMETA" OWNER TO postgres;

--
-- TOC entry 289 (class 1259 OID 61327)
-- Name: INFMETA_y2019m09; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INFMETA_y2019m09" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INFMETA_ID_INF_seq"'::regclass) NOT NULL,
    "UUID" character(40),
    "RFC_EMISOR" character(13),
    "NAME_EMISOR" character(155),
    "RFC_RECEPTOR" character(13),
    "NAME_RECEPTOR" character(155),
    "RFC_PAC" character(13),
    "FH_EMISION" timestamp with time zone,
    "FH_CERT_SAT" timestamp with time zone,
    "MNTO" bigint,
    "EFECTO_COMP" character(2),
    "STATUS" bigint,
    "FH_CANC" timestamp with time zone,
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INFMETA" ATTACH PARTITION "InfHistorica"."INFMETA_y2019m09" FOR VALUES FROM ('2019-09-01') TO ('2019-10-01');


ALTER TABLE "InfHistorica"."INFMETA_y2019m09" OWNER TO postgres;

--
-- TOC entry 290 (class 1259 OID 61331)
-- Name: INFMETA_y2019m10; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INFMETA_y2019m10" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INFMETA_ID_INF_seq"'::regclass) NOT NULL,
    "UUID" character(40),
    "RFC_EMISOR" character(13),
    "NAME_EMISOR" character(155),
    "RFC_RECEPTOR" character(13),
    "NAME_RECEPTOR" character(155),
    "RFC_PAC" character(13),
    "FH_EMISION" timestamp with time zone,
    "FH_CERT_SAT" timestamp with time zone,
    "MNTO" bigint,
    "EFECTO_COMP" character(2),
    "STATUS" bigint,
    "FH_CANC" timestamp with time zone,
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INFMETA" ATTACH PARTITION "InfHistorica"."INFMETA_y2019m10" FOR VALUES FROM ('2019-10-01') TO ('2019-11-01');


ALTER TABLE "InfHistorica"."INFMETA_y2019m10" OWNER TO postgres;

--
-- TOC entry 291 (class 1259 OID 61335)
-- Name: INFMETA_y2019m11; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INFMETA_y2019m11" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INFMETA_ID_INF_seq"'::regclass) NOT NULL,
    "UUID" character(40),
    "RFC_EMISOR" character(13),
    "NAME_EMISOR" character(155),
    "RFC_RECEPTOR" character(13),
    "NAME_RECEPTOR" character(155),
    "RFC_PAC" character(13),
    "FH_EMISION" timestamp with time zone,
    "FH_CERT_SAT" timestamp with time zone,
    "MNTO" bigint,
    "EFECTO_COMP" character(2),
    "STATUS" bigint,
    "FH_CANC" timestamp with time zone,
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INFMETA" ATTACH PARTITION "InfHistorica"."INFMETA_y2019m11" FOR VALUES FROM ('2019-11-01') TO ('2019-12-01');


ALTER TABLE "InfHistorica"."INFMETA_y2019m11" OWNER TO postgres;

--
-- TOC entry 292 (class 1259 OID 61339)
-- Name: INFMETA_y2019m12; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INFMETA_y2019m12" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INFMETA_ID_INF_seq"'::regclass) NOT NULL,
    "UUID" character(40),
    "RFC_EMISOR" character(13),
    "NAME_EMISOR" character(155),
    "RFC_RECEPTOR" character(13),
    "NAME_RECEPTOR" character(155),
    "RFC_PAC" character(13),
    "FH_EMISION" timestamp with time zone,
    "FH_CERT_SAT" timestamp with time zone,
    "MNTO" bigint,
    "EFECTO_COMP" character(2),
    "STATUS" bigint,
    "FH_CANC" timestamp with time zone,
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INFMETA" ATTACH PARTITION "InfHistorica"."INFMETA_y2019m12" FOR VALUES FROM ('2019-12-01') TO ('2020-01-01');


ALTER TABLE "InfHistorica"."INFMETA_y2019m12" OWNER TO postgres;

--
-- TOC entry 293 (class 1259 OID 61343)
-- Name: INFMETA_y2020m01; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INFMETA_y2020m01" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INFMETA_ID_INF_seq"'::regclass) NOT NULL,
    "UUID" character(40),
    "RFC_EMISOR" character(13),
    "NAME_EMISOR" character(155),
    "RFC_RECEPTOR" character(13),
    "NAME_RECEPTOR" character(155),
    "RFC_PAC" character(13),
    "FH_EMISION" timestamp with time zone,
    "FH_CERT_SAT" timestamp with time zone,
    "MNTO" bigint,
    "EFECTO_COMP" character(2),
    "STATUS" bigint,
    "FH_CANC" timestamp with time zone,
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INFMETA" ATTACH PARTITION "InfHistorica"."INFMETA_y2020m01" FOR VALUES FROM ('2020-01-01') TO ('2020-02-01');


ALTER TABLE "InfHistorica"."INFMETA_y2020m01" OWNER TO postgres;

--
-- TOC entry 294 (class 1259 OID 61347)
-- Name: INFMETA_y2020m02; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INFMETA_y2020m02" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INFMETA_ID_INF_seq"'::regclass) NOT NULL,
    "UUID" character(40),
    "RFC_EMISOR" character(13),
    "NAME_EMISOR" character(155),
    "RFC_RECEPTOR" character(13),
    "NAME_RECEPTOR" character(155),
    "RFC_PAC" character(13),
    "FH_EMISION" timestamp with time zone,
    "FH_CERT_SAT" timestamp with time zone,
    "MNTO" bigint,
    "EFECTO_COMP" character(2),
    "STATUS" bigint,
    "FH_CANC" timestamp with time zone,
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INFMETA" ATTACH PARTITION "InfHistorica"."INFMETA_y2020m02" FOR VALUES FROM ('2020-02-01') TO ('2020-03-01');


ALTER TABLE "InfHistorica"."INFMETA_y2020m02" OWNER TO postgres;

--
-- TOC entry 295 (class 1259 OID 61351)
-- Name: INFMETA_y2020m03; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INFMETA_y2020m03" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INFMETA_ID_INF_seq"'::regclass) NOT NULL,
    "UUID" character(40),
    "RFC_EMISOR" character(13),
    "NAME_EMISOR" character(155),
    "RFC_RECEPTOR" character(13),
    "NAME_RECEPTOR" character(155),
    "RFC_PAC" character(13),
    "FH_EMISION" timestamp with time zone,
    "FH_CERT_SAT" timestamp with time zone,
    "MNTO" bigint,
    "EFECTO_COMP" character(2),
    "STATUS" bigint,
    "FH_CANC" timestamp with time zone,
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INFMETA" ATTACH PARTITION "InfHistorica"."INFMETA_y2020m03" FOR VALUES FROM ('2020-03-01') TO ('2020-04-01');


ALTER TABLE "InfHistorica"."INFMETA_y2020m03" OWNER TO postgres;

--
-- TOC entry 296 (class 1259 OID 61355)
-- Name: INFMETA_y2020m04; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INFMETA_y2020m04" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INFMETA_ID_INF_seq"'::regclass) NOT NULL,
    "UUID" character(40),
    "RFC_EMISOR" character(13),
    "NAME_EMISOR" character(155),
    "RFC_RECEPTOR" character(13),
    "NAME_RECEPTOR" character(155),
    "RFC_PAC" character(13),
    "FH_EMISION" timestamp with time zone,
    "FH_CERT_SAT" timestamp with time zone,
    "MNTO" bigint,
    "EFECTO_COMP" character(2),
    "STATUS" bigint,
    "FH_CANC" timestamp with time zone,
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INFMETA" ATTACH PARTITION "InfHistorica"."INFMETA_y2020m04" FOR VALUES FROM ('2020-04-01') TO ('2020-05-01');


ALTER TABLE "InfHistorica"."INFMETA_y2020m04" OWNER TO postgres;

--
-- TOC entry 297 (class 1259 OID 61359)
-- Name: INFMETA_y2020m05; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INFMETA_y2020m05" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INFMETA_ID_INF_seq"'::regclass) NOT NULL,
    "UUID" character(40),
    "RFC_EMISOR" character(13),
    "NAME_EMISOR" character(155),
    "RFC_RECEPTOR" character(13),
    "NAME_RECEPTOR" character(155),
    "RFC_PAC" character(13),
    "FH_EMISION" timestamp with time zone,
    "FH_CERT_SAT" timestamp with time zone,
    "MNTO" bigint,
    "EFECTO_COMP" character(2),
    "STATUS" bigint,
    "FH_CANC" timestamp with time zone,
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INFMETA" ATTACH PARTITION "InfHistorica"."INFMETA_y2020m05" FOR VALUES FROM ('2020-05-01') TO ('2020-06-01');


ALTER TABLE "InfHistorica"."INFMETA_y2020m05" OWNER TO postgres;

--
-- TOC entry 298 (class 1259 OID 61363)
-- Name: INFMETA_y2020m06; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INFMETA_y2020m06" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INFMETA_ID_INF_seq"'::regclass) NOT NULL,
    "UUID" character(40),
    "RFC_EMISOR" character(13),
    "NAME_EMISOR" character(155),
    "RFC_RECEPTOR" character(13),
    "NAME_RECEPTOR" character(155),
    "RFC_PAC" character(13),
    "FH_EMISION" timestamp with time zone,
    "FH_CERT_SAT" timestamp with time zone,
    "MNTO" bigint,
    "EFECTO_COMP" character(2),
    "STATUS" bigint,
    "FH_CANC" timestamp with time zone,
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INFMETA" ATTACH PARTITION "InfHistorica"."INFMETA_y2020m06" FOR VALUES FROM ('2020-06-01') TO ('2020-07-01');


ALTER TABLE "InfHistorica"."INFMETA_y2020m06" OWNER TO postgres;

--
-- TOC entry 299 (class 1259 OID 61367)
-- Name: INFMETA_y2020m07; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INFMETA_y2020m07" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INFMETA_ID_INF_seq"'::regclass) NOT NULL,
    "UUID" character(40),
    "RFC_EMISOR" character(13),
    "NAME_EMISOR" character(155),
    "RFC_RECEPTOR" character(13),
    "NAME_RECEPTOR" character(155),
    "RFC_PAC" character(13),
    "FH_EMISION" timestamp with time zone,
    "FH_CERT_SAT" timestamp with time zone,
    "MNTO" bigint,
    "EFECTO_COMP" character(2),
    "STATUS" bigint,
    "FH_CANC" timestamp with time zone,
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INFMETA" ATTACH PARTITION "InfHistorica"."INFMETA_y2020m07" FOR VALUES FROM ('2020-07-01') TO ('2020-08-01');


ALTER TABLE "InfHistorica"."INFMETA_y2020m07" OWNER TO postgres;

--
-- TOC entry 300 (class 1259 OID 61371)
-- Name: INFMETA_y2020m08; Type: TABLE; Schema: InfHistorica; Owner: postgres
--

CREATE TABLE "InfHistorica"."INFMETA_y2020m08" (
    "ID_INF" integer DEFAULT nextval('"InfHistorica"."INFMETA_ID_INF_seq"'::regclass) NOT NULL,
    "UUID" character(40),
    "RFC_EMISOR" character(13),
    "NAME_EMISOR" character(155),
    "RFC_RECEPTOR" character(13),
    "NAME_RECEPTOR" character(155),
    "RFC_PAC" character(13),
    "FH_EMISION" timestamp with time zone,
    "FH_CERT_SAT" timestamp with time zone,
    "MNTO" bigint,
    "EFECTO_COMP" character(2),
    "STATUS" bigint,
    "FH_CANC" timestamp with time zone,
    "CVE_DESCARGA" character(15),
    "FH_PERIODO" date NOT NULL
);
ALTER TABLE ONLY "InfHistorica"."INFMETA" ATTACH PARTITION "InfHistorica"."INFMETA_y2020m08" FOR VALUES FROM ('2020-08-01') TO ('2020-09-01');


ALTER TABLE "InfHistorica"."INFMETA_y2020m08" OWNER TO postgres;

--
-- TOC entry 301 (class 1259 OID 61375)
-- Name: INFMETA; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."INFMETA" (
    "ID_INF" integer,
    "UUID" character(40),
    "RFC_EMISOR" character(13),
    "NAME_EMISOR" character(155),
    "RFC_RECEPTOR" character(13),
    "NAME_RECEPTOR" character(155),
    "RFC_PAC" character(13),
    "FH_EMISION" timestamp with time zone,
    "FH_CERT_SAT" timestamp with time zone,
    "MNTO" bigint,
    "EFECTO_COMP" character(1),
    "STATUS" bigint,
    "FH_CANC" timestamp with time zone,
    "CVE_DESCARGA" character(15)
);


ALTER TABLE "InfUsuario"."INFMETA" OWNER TO postgres;

--
-- TOC entry 328 (class 1259 OID 65173)
-- Name: CATALOGOPROVEEDORES; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."CATALOGOPROVEEDORES" AS
 SELECT DISTINCT tb."RFC_CLTE",
    tb."RFC_ASOC",
    tb."RFC_EMISOR",
    tb."NAME_EMISOR",
    tb."ESTATUS_69",
    tb."FH_PUB_69",
    tb."ESTATUS_69B",
    tb."FH_PUB_69B",
    tb."STATUS"
   FROM ( SELECT te."RFC" AS "RFC_CLTE",
            td."RFC" AS "RFC_ASOC",
            ta."RFC_EMISOR",
            replace(replace(replace(replace((ta."NAME_EMISOR")::text, ','::text, ''::text), '.'::text, ''::text), 'É'::text, 'E'::text), 'Ó'::text, 'O'::text) AS "NAME_EMISOR",
            tb_1."ESTATUS_69",
            tb_1."FH_PUB_69",
            tf."ESTATUS_69B",
            tf."FH_PUB_69B",
            ta."STATUS"
           FROM ((((("InfUsuario"."INFMETA" ta
             LEFT JOIN "BaseSistema"."PROVEEDORES69" tb_1 ON ((tb_1."RFC" = ta."RFC_EMISOR")))
             LEFT JOIN "BaseSistema"."PROVEEDORES69B" tf ON ((tf."RFC" = ta."RFC_EMISOR")))
             LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = ta."CVE_DESCARGA")))
             LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
             LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))) tb
  GROUP BY tb."RFC_CLTE", tb."RFC_ASOC", tb."RFC_EMISOR", tb."NAME_EMISOR", tb."ESTATUS_69", tb."FH_PUB_69", tb."ESTATUS_69B", tb."FH_PUB_69B", tb."STATUS"
  WITH NO DATA;


ALTER TABLE "InfUsuario"."CATALOGOPROVEEDORES" OWNER TO postgres;

--
-- TOC entry 302 (class 1259 OID 61383)
-- Name: CFDICOMPLEMENTOSPAGOS_ID_PAGODOCS_seq; Type: SEQUENCE; Schema: InfUsuario; Owner: postgres
--

CREATE SEQUENCE "InfUsuario"."CFDICOMPLEMENTOSPAGOS_ID_PAGODOCS_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "InfUsuario"."CFDICOMPLEMENTOSPAGOS_ID_PAGODOCS_seq" OWNER TO postgres;

--
-- TOC entry 303 (class 1259 OID 61385)
-- Name: CFDICOMPLEMENTOSPAGOS_ID_PAGO_seq; Type: SEQUENCE; Schema: InfUsuario; Owner: postgres
--

CREATE SEQUENCE "InfUsuario"."CFDICOMPLEMENTOSPAGOS_ID_PAGO_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "InfUsuario"."CFDICOMPLEMENTOSPAGOS_ID_PAGO_seq" OWNER TO postgres;

--
-- TOC entry 304 (class 1259 OID 61387)
-- Name: CFDICOMPLEMENTOS_ID_COMPLEMENTO_seq; Type: SEQUENCE; Schema: InfUsuario; Owner: postgres
--

CREATE SEQUENCE "InfUsuario"."CFDICOMPLEMENTOS_ID_COMPLEMENTO_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "InfUsuario"."CFDICOMPLEMENTOS_ID_COMPLEMENTO_seq" OWNER TO postgres;

--
-- TOC entry 305 (class 1259 OID 61389)
-- Name: CFDICOMPROBANTE_ID_COMPROBANTE_seq; Type: SEQUENCE; Schema: InfUsuario; Owner: postgres
--

CREATE SEQUENCE "InfUsuario"."CFDICOMPROBANTE_ID_COMPROBANTE_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "InfUsuario"."CFDICOMPROBANTE_ID_COMPROBANTE_seq" OWNER TO postgres;

--
-- TOC entry 306 (class 1259 OID 61391)
-- Name: CFDICOMPROBANTE; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICOMPROBANTE" (
    "ID_COMPROBANTE" integer DEFAULT nextval('"InfUsuario"."CFDICOMPROBANTE_ID_COMPROBANTE_seq"'::regclass) NOT NULL,
    "VERSION" character(5),
    "SERIE" character(25),
    "FOLIO" character(40),
    "FECHA" timestamp(1) without time zone,
    "SELLO" text,
    "FORMAPAGO" character(2),
    "NOCERTIFICADO" character(30),
    "CERTIFICADO" text,
    "CONDICIONESDEPAGO" character(1000),
    "SUBTOTAL" double precision,
    "DESCUENTO" double precision,
    "MONEDA" character(5),
    "TIPOCAMBIO" double precision,
    "TOTAL" double precision,
    "TIPODECOMPROBANTE" character(2),
    "METODOPAGO" character(3),
    "LUGAREXPEDICION" character(5),
    "CONFIRMACION" character(5),
    "RFCEMISOR" character(13),
    "NOMBREEMISOR" character(255),
    "REGIMENFISCAL" character(3),
    "RFCRECEPTOR" character(13),
    "NOMBRERECEPTOR" character(255),
    "RESIDENCIAFISICARECEPTOR" character(5),
    "NUMREGIDTRIBRECEPTOR" character(40),
    "USOCFDI" character(3),
    "TOTALIMPUESTOSRETENIDOS" double precision,
    "TOTALIMPUESTOSTRASLADADOS" double precision,
    "ID_CFDI" bigint,
    "CVE_DESCARGA" character(15)
);


ALTER TABLE "InfUsuario"."CFDICOMPROBANTE" OWNER TO postgres;

--
-- TOC entry 307 (class 1259 OID 61398)
-- Name: CFDICOMPROBANTECOMPLEMENTO; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICOMPROBANTECOMPLEMENTO" (
    "ID_COMPLEMENTO" integer DEFAULT nextval('"InfUsuario"."CFDICOMPLEMENTOS_ID_COMPLEMENTO_seq"'::regclass) NOT NULL,
    "SELLOCFD" character(1000),
    "NOCERTIFICADOSAT" character(30),
    "RFCPROVCERTIF" character(13),
    "UUID" character(36),
    "FECHATIMBRADO" timestamp(1) without time zone,
    "SELLOSAT" character(1000),
    "ID_COMPROBANTE" bigint,
    "VERSION" character(5)
);


ALTER TABLE "InfUsuario"."CFDICOMPROBANTECOMPLEMENTO" OWNER TO postgres;

--
-- TOC entry 308 (class 1259 OID 61405)
-- Name: CFDICOMPROBANTECOMPLEMENTOPAGOS; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOS" (
    "ID_PAGO" integer DEFAULT nextval('"InfUsuario"."CFDICOMPLEMENTOSPAGOS_ID_PAGO_seq"'::regclass) NOT NULL,
    "FECHAPAGO" timestamp without time zone,
    "FORMADEPAGOP" character(2),
    "MONEDAP" character(5),
    "MONTO" double precision,
    "RFCEMISORCTABEN" character(13),
    "CTABENEFICIARIO" character(20),
    "ID_COMPROBANTE" bigint
);


ALTER TABLE "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOS" OWNER TO postgres;

--
-- TOC entry 309 (class 1259 OID 61409)
-- Name: CFDICOMPROBANTECOMPLEMENTOPAGOSDOCS; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOSDOCS" (
    "ID_PAGODOC" integer DEFAULT nextval('"InfUsuario"."CFDICOMPLEMENTOSPAGOS_ID_PAGODOCS_seq"'::regclass) NOT NULL,
    "IDDOCUMENTO" character(36),
    "SERIE" character(25),
    "FOLIO" character(40),
    "MONEDADR" character(5),
    "METODODEPAGODR" character(3),
    "NUMPARCIALIDAD" character(5),
    "IMPSALDOANT" double precision,
    "IMPPAGADO" double precision,
    "IMPSALDOINSOLUTO" double precision,
    "ID_PAGO" bigint
);


ALTER TABLE "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOSDOCS" OWNER TO postgres;

--
-- TOC entry 310 (class 1259 OID 61413)
-- Name: CFDIRETENIDOS_ID_RETENIDO_seq; Type: SEQUENCE; Schema: InfUsuario; Owner: postgres
--

CREATE SEQUENCE "InfUsuario"."CFDIRETENIDOS_ID_RETENIDO_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "InfUsuario"."CFDIRETENIDOS_ID_RETENIDO_seq" OWNER TO postgres;

--
-- TOC entry 311 (class 1259 OID 61415)
-- Name: CFDICOMPROBANTEIMPUESTOSRETENIDOS; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICOMPROBANTEIMPUESTOSRETENIDOS" (
    "ID_RETENIDOS" integer DEFAULT nextval('"InfUsuario"."CFDIRETENIDOS_ID_RETENIDO_seq"'::regclass) NOT NULL,
    "IMPUESTO" character(3),
    "IMPORTE" double precision,
    "ID_COMPROBANTE" bigint
);


ALTER TABLE "InfUsuario"."CFDICOMPROBANTEIMPUESTOSRETENIDOS" OWNER TO postgres;

--
-- TOC entry 312 (class 1259 OID 61419)
-- Name: CFDITRASLADOS_ID_TRASLADO_seq; Type: SEQUENCE; Schema: InfUsuario; Owner: postgres
--

CREATE SEQUENCE "InfUsuario"."CFDITRASLADOS_ID_TRASLADO_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "InfUsuario"."CFDITRASLADOS_ID_TRASLADO_seq" OWNER TO postgres;

--
-- TOC entry 313 (class 1259 OID 61421)
-- Name: CFDICOMPROBANTEIMPUESTOSTRASLADOS; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICOMPROBANTEIMPUESTOSTRASLADOS" (
    "ID_TRASLADO" integer DEFAULT nextval('"InfUsuario"."CFDITRASLADOS_ID_TRASLADO_seq"'::regclass) NOT NULL,
    "IMPUESTO" character(3),
    "TIPOFACTOR" character(8),
    "TASAOCUOTA" double precision,
    "IMPORTE" double precision,
    "ID_COMPROBANTE" bigint
);


ALTER TABLE "InfUsuario"."CFDICOMPROBANTEIMPUESTOSTRASLADOS" OWNER TO postgres;

--
-- TOC entry 314 (class 1259 OID 61425)
-- Name: CFDICOMPROBANTERELACIONADOS; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICOMPROBANTERELACIONADOS" (
    "ID_RELACIONADOS" integer NOT NULL,
    "TIPORELACION" character(2),
    "UUID" character(50),
    "ID_COMPROBANTE" bigint
);


ALTER TABLE "InfUsuario"."CFDICOMPROBANTERELACIONADOS" OWNER TO postgres;

--
-- TOC entry 315 (class 1259 OID 61428)
-- Name: CFDICONCEPTOS_ID_CONCEPTO_seq; Type: SEQUENCE; Schema: InfUsuario; Owner: postgres
--

CREATE SEQUENCE "InfUsuario"."CFDICONCEPTOS_ID_CONCEPTO_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "InfUsuario"."CFDICONCEPTOS_ID_CONCEPTO_seq" OWNER TO postgres;

--
-- TOC entry 316 (class 1259 OID 61430)
-- Name: CFDICONCEPTOS; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICONCEPTOS" (
    "ID_CONCEPTO" integer DEFAULT nextval('"InfUsuario"."CFDICONCEPTOS_ID_CONCEPTO_seq"'::regclass) NOT NULL,
    "CLAVEPRODSERV" character(10),
    "NOIDENTIFICACION" character(100),
    "CANTIDAD" double precision,
    "CLAVEUNIDAD" character(5),
    "UNIDAD" character(150),
    "DESCRIPCION" character(1000),
    "VALORUNITARIO" double precision,
    "IMPORTE" double precision,
    "DESCUENTO" double precision,
    "NUMEROPEDIM" character(20),
    "NUMEROCUENTAPREDIAL" character(150),
    "ID_COMPROBANTE" bigint,
    "NUM" bigint
);


ALTER TABLE "InfUsuario"."CFDICONCEPTOS" OWNER TO postgres;

--
-- TOC entry 317 (class 1259 OID 61437)
-- Name: CFDICONCEPTOSIMPUESTOSRETENCIONES; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICONCEPTOSIMPUESTOSRETENCIONES" (
    "ID_RETENCION" integer NOT NULL,
    "BASE" double precision,
    "IMPUESTO" character(3),
    "TIPOFACTOR" character(8),
    "TASAOCUOTA" double precision,
    "IMPORTE" double precision,
    "ID_CONCEPTO" bigint,
    "NUM" bigint
);


ALTER TABLE "InfUsuario"."CFDICONCEPTOSIMPUESTOSRETENCIONES" OWNER TO postgres;

--
-- TOC entry 318 (class 1259 OID 61440)
-- Name: CFDICONCEPTOSIMPUESTOSTRASLADOS; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" (
    "ID_IMPUESTO" integer NOT NULL,
    "BASE" double precision,
    "IMPUESTO" character(3),
    "TIPOFACTOR" character(8),
    "TASAOCUOTA" double precision,
    "IMPORTE" double precision,
    "ID_CONCEPTO" bigint,
    "NUM" bigint
);


ALTER TABLE "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" OWNER TO postgres;

--
-- TOC entry 319 (class 1259 OID 61443)
-- Name: CFDIPARTES_ID_PARTE_seq; Type: SEQUENCE; Schema: InfUsuario; Owner: postgres
--

CREATE SEQUENCE "InfUsuario"."CFDIPARTES_ID_PARTE_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE "InfUsuario"."CFDIPARTES_ID_PARTE_seq" OWNER TO postgres;

--
-- TOC entry 320 (class 1259 OID 61445)
-- Name: CFDICONCEPTOSPARTES; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICONCEPTOSPARTES" (
    "ID_PARTE" integer DEFAULT nextval('"InfUsuario"."CFDIPARTES_ID_PARTE_seq"'::regclass) NOT NULL,
    "CLAVEPRODSERV" character(10),
    "NOIDENTIFICACION" character(100),
    "CANTIDAD" double precision,
    "UNIDAD" character(10),
    "DESCRIPCION" character(1000),
    "VALORUNITARIO" double precision,
    "IMPORTE" double precision,
    "NUMEROPEDIM" character(20),
    "ID_CONCEPTO" bigint
);


ALTER TABLE "InfUsuario"."CFDICONCEPTOSPARTES" OWNER TO postgres;

--
-- TOC entry 321 (class 1259 OID 61452)
-- Name: CFDIIMPUESTOS_ID_IMPUESTO_seq; Type: SEQUENCE; Schema: InfUsuario; Owner: postgres
--

CREATE SEQUENCE "InfUsuario"."CFDIIMPUESTOS_ID_IMPUESTO_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "InfUsuario"."CFDIIMPUESTOS_ID_IMPUESTO_seq" OWNER TO postgres;

--
-- TOC entry 3716 (class 0 OID 0)
-- Dependencies: 321
-- Name: CFDIIMPUESTOS_ID_IMPUESTO_seq; Type: SEQUENCE OWNED BY; Schema: InfUsuario; Owner: postgres
--

ALTER SEQUENCE "InfUsuario"."CFDIIMPUESTOS_ID_IMPUESTO_seq" OWNED BY "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS"."ID_IMPUESTO";


--
-- TOC entry 322 (class 1259 OID 61454)
-- Name: CFDIRELACIONADOS_ID_RELACIONADOS_seq; Type: SEQUENCE; Schema: InfUsuario; Owner: postgres
--

CREATE SEQUENCE "InfUsuario"."CFDIRELACIONADOS_ID_RELACIONADOS_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "InfUsuario"."CFDIRELACIONADOS_ID_RELACIONADOS_seq" OWNER TO postgres;

--
-- TOC entry 3717 (class 0 OID 0)
-- Dependencies: 322
-- Name: CFDIRELACIONADOS_ID_RELACIONADOS_seq; Type: SEQUENCE OWNED BY; Schema: InfUsuario; Owner: postgres
--

ALTER SEQUENCE "InfUsuario"."CFDIRELACIONADOS_ID_RELACIONADOS_seq" OWNED BY "InfUsuario"."CFDICOMPROBANTERELACIONADOS"."ID_RELACIONADOS";


--
-- TOC entry 323 (class 1259 OID 61456)
-- Name: CFDIRETENCIONES_ID_RETENCION_seq; Type: SEQUENCE; Schema: InfUsuario; Owner: postgres
--

CREATE SEQUENCE "InfUsuario"."CFDIRETENCIONES_ID_RETENCION_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "InfUsuario"."CFDIRETENCIONES_ID_RETENCION_seq" OWNER TO postgres;

--
-- TOC entry 3718 (class 0 OID 0)
-- Dependencies: 323
-- Name: CFDIRETENCIONES_ID_RETENCION_seq; Type: SEQUENCE OWNED BY; Schema: InfUsuario; Owner: postgres
--

ALTER SEQUENCE "InfUsuario"."CFDIRETENCIONES_ID_RETENCION_seq" OWNED BY "InfUsuario"."CFDICONCEPTOSIMPUESTOSRETENCIONES"."ID_RETENCION";


--
-- TOC entry 324 (class 1259 OID 61458)
-- Name: CFDITOTAL; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDITOTAL" (
    "ID_CFDI" integer NOT NULL,
    "ERROR" text,
    "UUID" character(150)
);


ALTER TABLE "InfUsuario"."CFDITOTAL" OWNER TO postgres;

--
-- TOC entry 325 (class 1259 OID 61464)
-- Name: CFDITOTAL_ID_CFDI_seq; Type: SEQUENCE; Schema: InfUsuario; Owner: postgres
--

CREATE SEQUENCE "InfUsuario"."CFDITOTAL_ID_CFDI_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "InfUsuario"."CFDITOTAL_ID_CFDI_seq" OWNER TO postgres;

--
-- TOC entry 3719 (class 0 OID 0)
-- Dependencies: 325
-- Name: CFDITOTAL_ID_CFDI_seq; Type: SEQUENCE OWNED BY; Schema: InfUsuario; Owner: postgres
--

ALTER SEQUENCE "InfUsuario"."CFDITOTAL_ID_CFDI_seq" OWNED BY "InfUsuario"."CFDITOTAL"."ID_CFDI";


--
-- TOC entry 326 (class 1259 OID 61466)
-- Name: CFDIVALIDADOS69Y69B; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."CFDIVALIDADOS69Y69B" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCRECEPTOR",
    tf."ESTATUS_69",
        CASE
            WHEN (tf."ESTATUS_69" = 'NO LOCALIZADO'::bpchar) THEN 1
            ELSE 0
        END AS "OBSERVABLE69",
    tg."ESTATUS_69B",
        CASE
            WHEN (tg."ESTATUS_69B" IS NOT NULL) THEN 1
            ELSE 0
        END AS "OBSERVABLE69B"
   FROM (((((("InfUsuario"."CFDICOMPROBANTE" ta
     JOIN "BaseSistema"."LOGCARGAXML" th ON (((((th."ID_CARGAXML")::character varying)::bpchar = ta."CVE_DESCARGA") AND (th."STATUS" = 36) AND (th."STATUSPERIODO" = 38))))
     JOIN "BaseSistema"."LOGDESCARGAWSPROCESO" pr ON (((pr."CVE_DESCARGA" = th."CVE_DESCARGA") AND (pr."STATUS" = 31))))
     JOIN "BaseSistema"."CFGCLTESRFC" td ON (((td."ID_RFC" = pr."ID_RFC") AND (td."STATUS" = 5))))
     JOIN "BaseSistema"."CFGCLTES" te ON (((te."ID_CLTE" = td."ID_CLTE") AND (te."STATUS" = 3))))
     LEFT JOIN "BaseSistema"."PROVEEDORES69" tf ON ((tf."RFC" = ta."RFCRECEPTOR")))
     LEFT JOIN "BaseSistema"."PROVEEDORES69B" tg ON ((tg."RFC" = ta."RFCRECEPTOR")))
  WITH NO DATA;


ALTER TABLE "InfUsuario"."CFDIVALIDADOS69Y69B" OWNER TO postgres;

--
-- TOC entry 327 (class 1259 OID 61471)
-- Name: INF32D; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."INF32D" (
    "ID_INF" integer NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255)
);


ALTER TABLE "InfUsuario"."INF32D" OWNER TO postgres;

--
-- TOC entry 329 (class 1259 OID 65221)
-- Name: TEMPORAL; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."TEMPORAL" (
    "ID_CARGAXML" integer,
    "CVE_DESCARGA" character(15),
    "ARCHIVOXML" character(50),
    "STATUS" bigint,
    "MSGERROR" text,
    "FCARGA" timestamp without time zone,
    "PAGINA" bigint,
    "CVE_CARGA" character(15),
    "USAPAGO" bigint,
    "PERIODO" character(6),
    "STATUSPERIODO" bigint,
    "EMISOR_RECEPTOR" character(1)
);


ALTER TABLE public."TEMPORAL" OWNER TO postgres;

--
-- TOC entry 3371 (class 2604 OID 61474)
-- Name: CATACCIONES ID_ACCION; Type: DEFAULT; Schema: BaseSistema; Owner: postgres
--

ALTER TABLE ONLY "BaseSistema"."CATACCIONES" ALTER COLUMN "ID_ACCION" SET DEFAULT nextval('"BaseSistema"."CATACCIONES_ID_ACCION_seq"'::regclass);


--
-- TOC entry 3374 (class 2604 OID 61475)
-- Name: CATSTATUS ID_STATUS; Type: DEFAULT; Schema: BaseSistema; Owner: postgres
--

ALTER TABLE ONLY "BaseSistema"."CATSTATUS" ALTER COLUMN "ID_STATUS" SET DEFAULT nextval('"BaseSistema"."CATSTATUS_ID_STATUS_seq"'::regclass);


--
-- TOC entry 3382 (class 2604 OID 61476)
-- Name: CFGPERIODOS ID_PERIODO; Type: DEFAULT; Schema: BaseSistema; Owner: postgres
--

ALTER TABLE ONLY "BaseSistema"."CFGPERIODOS" ALTER COLUMN "ID_PERIODO" SET DEFAULT nextval('"BaseSistema"."CFGPERIODOS_ID_PERIODO_seq"'::regclass);


--
-- TOC entry 3381 (class 2604 OID 61477)
-- Name: LOGDESCARGAFILE ID_DESCARGA; Type: DEFAULT; Schema: BaseSistema; Owner: postgres
--

ALTER TABLE ONLY "BaseSistema"."LOGDESCARGAFILE" ALTER COLUMN "ID_DESCARGA" SET DEFAULT nextval('"BaseSistema"."CFGFILEUNLOADS_ID_UNLOAD_seq"'::regclass);


--
-- TOC entry 3386 (class 2604 OID 61478)
-- Name: SOLCONSULPER ID_CONSULTA; Type: DEFAULT; Schema: BaseSistema; Owner: postgres
--

ALTER TABLE ONLY "BaseSistema"."SOLCONSULPER" ALTER COLUMN "ID_CONSULTA" SET DEFAULT nextval('"BaseSistema"."SOLCONSULPER_ID_CONSULTA_seq"'::regclass);


--
-- TOC entry 3445 (class 2604 OID 61479)
-- Name: CFDICOMPROBANTERELACIONADOS ID_RELACIONADOS; Type: DEFAULT; Schema: InfUsuario; Owner: postgres
--

ALTER TABLE ONLY "InfUsuario"."CFDICOMPROBANTERELACIONADOS" ALTER COLUMN "ID_RELACIONADOS" SET DEFAULT nextval('"InfUsuario"."CFDIRELACIONADOS_ID_RELACIONADOS_seq"'::regclass);


--
-- TOC entry 3447 (class 2604 OID 61480)
-- Name: CFDICONCEPTOSIMPUESTOSRETENCIONES ID_RETENCION; Type: DEFAULT; Schema: InfUsuario; Owner: postgres
--

ALTER TABLE ONLY "InfUsuario"."CFDICONCEPTOSIMPUESTOSRETENCIONES" ALTER COLUMN "ID_RETENCION" SET DEFAULT nextval('"InfUsuario"."CFDIRETENCIONES_ID_RETENCION_seq"'::regclass);


--
-- TOC entry 3448 (class 2604 OID 61481)
-- Name: CFDICONCEPTOSIMPUESTOSTRASLADOS ID_IMPUESTO; Type: DEFAULT; Schema: InfUsuario; Owner: postgres
--

ALTER TABLE ONLY "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" ALTER COLUMN "ID_IMPUESTO" SET DEFAULT nextval('"InfUsuario"."CFDIIMPUESTOS_ID_IMPUESTO_seq"'::regclass);


--
-- TOC entry 3450 (class 2604 OID 61482)
-- Name: CFDITOTAL ID_CFDI; Type: DEFAULT; Schema: InfUsuario; Owner: postgres
--

ALTER TABLE ONLY "InfUsuario"."CFDITOTAL" ALTER COLUMN "ID_CFDI" SET DEFAULT nextval('"InfUsuario"."CFDITOTAL_ID_CFDI_seq"'::regclass);


--
-- TOC entry 3586 (class 0 OID 60983)
-- Dependencies: 207
-- Data for Name: CATACCIONES; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--

INSERT INTO "BaseSistema"."CATACCIONES" VALUES (1, 'SOLICITA                 ');
INSERT INTO "BaseSistema"."CATACCIONES" VALUES (2, 'VALIDA                   ');
INSERT INTO "BaseSistema"."CATACCIONES" VALUES (3, 'DESCARGA                 ');
INSERT INTO "BaseSistema"."CATACCIONES" VALUES (4, 'CARGA                    ');
INSERT INTO "BaseSistema"."CATACCIONES" VALUES (5, 'TERMINA                  ');
INSERT INTO "BaseSistema"."CATACCIONES" VALUES (6, 'AUTORIZA                 ');


--
-- TOC entry 3589 (class 0 OID 60990)
-- Dependencies: 210
-- Data for Name: CATPROCESOS; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--

INSERT INTO "BaseSistema"."CATPROCESOS" VALUES (1, 'REPOSITORIO                   ');
INSERT INTO "BaseSistema"."CATPROCESOS" VALUES (2, 'CLIENTE                       ');
INSERT INTO "BaseSistema"."CATPROCESOS" VALUES (3, 'RFC                           ');
INSERT INTO "BaseSistema"."CATPROCESOS" VALUES (4, 'CREDENCIAL RFC                ');
INSERT INTO "BaseSistema"."CATPROCESOS" VALUES (5, 'ARCHIVO                       ');
INSERT INTO "BaseSistema"."CATPROCESOS" VALUES (6, 'COLUMNA                       ');
INSERT INTO "BaseSistema"."CATPROCESOS" VALUES (7, 'DESCARGA                      ');
INSERT INTO "BaseSistema"."CATPROCESOS" VALUES (8, 'RESPALDO                      ');
INSERT INTO "BaseSistema"."CATPROCESOS" VALUES (9, 'CARGA                         ');
INSERT INTO "BaseSistema"."CATPROCESOS" VALUES (10, 'DESCOMPRIME                   ');
INSERT INTO "BaseSistema"."CATPROCESOS" VALUES (11, 'DESCARGA WS                   ');
INSERT INTO "BaseSistema"."CATPROCESOS" VALUES (12, 'CARGA XML                     ');
INSERT INTO "BaseSistema"."CATPROCESOS" VALUES (13, 'PERIODO                       ');
INSERT INTO "BaseSistema"."CATPROCESOS" VALUES (14, 'CONSULTA                      ');


--
-- TOC entry 3591 (class 0 OID 60996)
-- Dependencies: 212
-- Data for Name: CATPROCESOSSTATUS; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--

INSERT INTO "BaseSistema"."CATPROCESOSSTATUS" VALUES (1, 'ACTIVO              ');
INSERT INTO "BaseSistema"."CATPROCESOSSTATUS" VALUES (2, 'CANCELADO           ');
INSERT INTO "BaseSistema"."CATPROCESOSSTATUS" VALUES (3, 'CONFIGURANDO        ');
INSERT INTO "BaseSistema"."CATPROCESOSSTATUS" VALUES (4, 'EN PROCESO          ');
INSERT INTO "BaseSistema"."CATPROCESOSSTATUS" VALUES (5, 'TERMINADO           ');
INSERT INTO "BaseSistema"."CATPROCESOSSTATUS" VALUES (6, 'PENDIENTE           ');
INSERT INTO "BaseSistema"."CATPROCESOSSTATUS" VALUES (7, 'CERRADO             ');
INSERT INTO "BaseSistema"."CATPROCESOSSTATUS" VALUES (8, 'AUTORIZADO          ');
INSERT INTO "BaseSistema"."CATPROCESOSSTATUS" VALUES (9, 'SOLICITADO          ');
INSERT INTO "BaseSistema"."CATPROCESOSSTATUS" VALUES (10, 'VERIFICADO          ');
INSERT INTO "BaseSistema"."CATPROCESOSSTATUS" VALUES (11, 'DESCARGADO          ');
INSERT INTO "BaseSistema"."CATPROCESOSSTATUS" VALUES (12, 'FALLIDO             ');


--
-- TOC entry 3592 (class 0 OID 61000)
-- Dependencies: 213
-- Data for Name: CATSTATUS; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--

INSERT INTO "BaseSistema"."CATSTATUS" VALUES (1, 1, 1);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (2, 1, 2);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (3, 2, 1);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (4, 2, 2);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (5, 3, 1);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (6, 3, 2);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (7, 4, 1);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (8, 4, 2);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (9, 5, 3);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (10, 5, 1);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (11, 5, 2);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (12, 6, 1);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (13, 6, 2);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (14, 7, 6);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (15, 7, 4);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (16, 7, 5);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (17, 8, 6);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (18, 8, 4);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (19, 8, 5);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (20, 9, 6);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (21, 9, 4);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (22, 9, 5);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (23, 10, 6);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (24, 10, 4);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (25, 10, 5);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (26, 11, 6);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (27, 11, 1);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (28, 11, 8);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (29, 11, 9);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (30, 11, 10);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (31, 11, 11);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (32, 11, 12);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (33, 9, 12);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (34, 12, 6);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (35, 12, 4);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (36, 12, 5);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (37, 12, 12);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (38, 13, 1);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (39, 13, 2);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (40, 14, 4);
INSERT INTO "BaseSistema"."CATSTATUS" VALUES (41, 14, 5);


--
-- TOC entry 3596 (class 0 OID 61009)
-- Dependencies: 217
-- Data for Name: CFGCLTES; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3598 (class 0 OID 61018)
-- Dependencies: 219
-- Data for Name: CFGCLTESCREDENCIALES; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3599 (class 0 OID 61025)
-- Dependencies: 220
-- Data for Name: CFGCLTESREPOSITORIOS; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--

INSERT INTO "BaseSistema"."CFGCLTESREPOSITORIOS" VALUES (2, 'InfUsuario     ', 'Informacion del Usuario                                                                                                                               ', '2019-09-05 16:11:58.939296', NULL, 0, NULL, 1);


--
-- TOC entry 3601 (class 0 OID 61031)
-- Dependencies: 222
-- Data for Name: CFGCLTESRFC; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3603 (class 0 OID 61037)
-- Dependencies: 224
-- Data for Name: CFGFILE; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--

INSERT INTO "BaseSistema"."CFGFILE" VALUES (14, 'CFDI ', 'CFDI DEL CLIENTE ZIP                                                  ', '2', '/GRIT/INSUMOS/CFDI                                                                                                                                                                                                                                        ', '/GRIT/BACKUPS/CFDI                                                                                                                                                                                                                                        ', 5, NULL, NULL, NULL, B'1', B'1', '2019-09-05 18:00:15.251042', NULL, 0, NULL, 10, NULL);
INSERT INTO "BaseSistema"."CFGFILE" VALUES (13, 'MET  ', 'METADATOS DEL CLIENTE                                                 ', '3', '/GRIT/INSUMOS/METADATOS                                                                                                                                                                                                                                   ', '/GRIT/BACKUPS/METADATOS                                                                                                                                                                                                                                   ', 0, NULL, '*.TXT                                             ', 'META           ', B'0', B'1', '2019-09-05 17:38:06.863223', NULL, 0, NULL, 10, NULL);
INSERT INTO "BaseSistema"."CFGFILE" VALUES (15, 'CFDI ', 'CFDI DEL CLIENTE                                                      ', '3', '/GRIT/INSUMOS/CFDI                                                                                                                                                                                                                                        ', '/GRIT/BACKUPS/CFDI                                                                                                                                                                                                                                        ', 0, NULL, '*.XML                                             ', 'CFDI           ', B'0', B'1', '2019-09-05 18:01:50.329713', NULL, 0, NULL, 10, NULL);
INSERT INTO "BaseSistema"."CFGFILE" VALUES (16, '32D  ', 'OPINION DE CUMPLIMIENTO                                               ', '3', '/GRIT/INSUMOS/OPINIONCUMPLIMIENTO                                                                                                                                                                                                                         ', '/GRIT/BACKUPS/OPINIONCUMPLIMIENTO                                                                                                                                                                                                                         ', 5, NULL, '*.PDF                                             ', 'OPCUMPL        ', B'0', B'1', '2019-09-05 18:11:03.56732', NULL, 0, NULL, 10, NULL);
INSERT INTO "BaseSistema"."CFGFILE" VALUES (11, '69B  ', 'LISTADO 69B - Listado Completo                                        ', '1', '/GRIT/INSUMOS/GENERALES                                                                                                                                                                                                                                   ', '/GRIT/BACKUPS/GENERALES                                                                                                                                                                                                                                   ', 90, 'http://omawww.sat.gob.mx/cifras_sat/Documents/Listado_Completo_69-B.csv                                                                                                                                                                                   ', 'Listado_Completo_69-B.csv                         ', 'INF69B         ', B'0', B'0', '2019-09-05 17:27:42.613835', NULL, 0, NULL, 10, 'TemporalINFO69B_1             ');
INSERT INTO "BaseSistema"."CFGFILE" VALUES (4, '69   ', 'LISTADO 69 - Condonados de Recargo                                    ', '1', '/GRIT/INSUMOS/GENERALES                                                                                                                                                                                                                                   ', '/GRIT/BACKUPS/GENERALES                                                                                                                                                                                                                                   ', 90, 'http://omawww.sat.gob.mx/cifras_sat/Documents/Condonadosart21CFF.csv                                                                                                                                                                                      ', 'Condonadosart21CFF.csv                            ', 'INF69          ', B'0', B'0', '2019-09-05 17:22:02.65278', NULL, 0, NULL, 10, 'TemporalINFO69_2              ');
INSERT INTO "BaseSistema"."CFGFILE" VALUES (6, '69   ', 'LISTADO 69 - Exigibles                                                ', '1', '/GRIT/INSUMOS/GENERALES                                                                                                                                                                                                                                   ', '/GRIT/BACKUPS/GENERALES                                                                                                                                                                                                                                   ', 90, 'http://omawww.sat.gob.mx/cifras_sat/Documents/Exigibles.csv                                                                                                                                                                                               ', 'Exigibles.csv                                     ', 'INF69          ', B'0', B'0', '2019-09-05 17:23:21.405258', NULL, 0, NULL, 10, 'TemporalINFO69_2              ');
INSERT INTO "BaseSistema"."CFGFILE" VALUES (12, 'MET  ', 'METADATOS DEL CLIENTE ZIP                                             ', '2', '/GRIT/INSUMOS/METADATOS                                                                                                                                                                                                                                   ', '/GRIT/BACKUPS/METADATOS                                                                                                                                                                                                                                   ', 30, NULL, 'FFC35873-31A7-4458-9EE9-AFD7F6AE4BC5-0000.txt     ', NULL, B'1', B'1', '2019-09-05 17:33:54.945958', NULL, 0, NULL, 10, 'TemporalINFOMETA_1            ');
INSERT INTO "BaseSistema"."CFGFILE" VALUES (3, '69   ', 'LISTADO 69 - Condonados de Concurso Mercantil                         ', '1', '/GRIT/INSUMOS/GENERALES                                                                                                                                                                                                                                   ', '/GRIT/BACKUPS/GENERALES                                                                                                                                                                                                                                   ', 90, 'http://omawww.sat.gob.mx/cifras_sat/Documents/Condonadosart146BCFF.csv                                                                                                                                                                                    ', 'Condonadosart146BCFF.csv                          ', 'INF69          ', B'0', B'0', '2019-09-05 17:21:31.15263', NULL, 0, NULL, 10, 'TemporalINFO69_1              ');
INSERT INTO "BaseSistema"."CFGFILE" VALUES (7, '69   ', 'LISTADO 69 - Firmes                                                   ', '1', '/GRIT/INSUMOS/GENERALES                                                                                                                                                                                                                                   ', '/GRIT/BACKUPS/GENERALES                                                                                                                                                                                                                                   ', 90, 'http://omawww.sat.gob.mx/cifras_sat/Documents/Firmes.csv                                                                                                                                                                                                  ', 'Firmes.csv                                        ', 'INF69          ', B'0', B'0', '2019-09-05 17:23:43.305494', NULL, 0, NULL, 10, 'TemporalINFO69_3              ');
INSERT INTO "BaseSistema"."CFGFILE" VALUES (9, '69   ', 'LISTADO 69 - Sentencias                                               ', '1', '/GRIT/INSUMOS/GENERALES                                                                                                                                                                                                                                   ', '/GRIT/BACKUPS/GENERALES                                                                                                                                                                                                                                   ', 90, 'http://omawww.sat.gob.mx/cifras_sat/Documents/Sentencias.csv                                                                                                                                                                                              ', 'Sentencias.csv                                    ', 'INF69          ', B'0', B'0', '2019-09-05 17:24:31.997766', NULL, 0, NULL, 10, 'TemporalINFO69_2              ');
INSERT INTO "BaseSistema"."CFGFILE" VALUES (1, '69   ', 'LISTADO 69 - Cancelados                                               ', '1', '/GRIT/INSUMOS/GENERALES                                                                                                                                                                                                                                   ', '/GRIT/BACKUPS/GENERALES                                                                                                                                                                                                                                   ', 90, 'http://omawww.sat.gob.mx/cifras_sat/Documents/Cancelados.csv                                                                                                                                                                                              ', 'Cancelados.csv                                    ', 'INF69          ', B'0', B'0', '2019-09-05 17:18:43.247285', NULL, 0, NULL, 10, 'TemporalINFO69_1              ');
INSERT INTO "BaseSistema"."CFGFILE" VALUES (2, '69   ', 'LISTADO 69 - Condonados de Multas                                     ', '1', '/GRIT/INSUMOS/GENERALES                                                                                                                                                                                                                                   ', '/GRIT/BACKUPS/GENERALES                                                                                                                                                                                                                                   ', 90, 'http://omawww.sat.gob.mx/cifras_sat/Documents/Condonadosart74CFF.csv                                                                                                                                                                                      ', 'Condonadosart74CFF.csv                            ', 'INF69          ', B'0', B'0', '2019-09-05 17:20:57.725042', NULL, 0, NULL, 10, 'TemporalINFO69_2              ');
INSERT INTO "BaseSistema"."CFGFILE" VALUES (5, '69   ', 'LISTADO 69 - Condonados por Decreto                                   ', '1', '/GRIT/INSUMOS/GENERALES                                                                                                                                                                                                                                   ', '/GRIT/BACKUPS/GENERALES                                                                                                                                                                                                                                   ', 90, 'http://omawww.sat.gob.mx/cifras_sat/Documents/CondonadosporDecreto.csv                                                                                                                                                                                    ', 'CondonadosporDecreto.csv                          ', 'INF69          ', B'0', B'0', '2019-09-05 17:22:28.21943', NULL, 0, NULL, 10, 'TemporalINFO69_2              ');
INSERT INTO "BaseSistema"."CFGFILE" VALUES (8, '69   ', 'LISTADO 69 - No localizados                                           ', '1', '/GRIT/INSUMOS/GENERALES                                                                                                                                                                                                                                   ', '/GRIT/BACKUPS/GENERALES                                                                                                                                                                                                                                   ', 90, 'http://omawww.sat.gob.mx/cifras_sat/Documents/No%20localizados.csv                                                                                                                                                                                        ', 'No%20localizados.csv                              ', 'INF69          ', B'0', B'0', '2019-09-05 17:24:09.00405', NULL, 0, NULL, 10, 'TemporalINFO69_2              ');
INSERT INTO "BaseSistema"."CFGFILE" VALUES (10, '69   ', 'LISTADO 69 - Retorno                                                  ', '1', '/GRIT/INSUMOS/GENERALES                                                                                                                                                                                                                                   ', '/GRIT/BACKUPS/GENERALES                                                                                                                                                                                                                                   ', 90, 'http://omawww.sat.gob.mx/cifras_sat/Documents/Retornoinversiones.csv                                                                                                                                                                                      ', 'Retornoinversiones.csv                            ', 'INF69          ', B'0', B'0', '2019-09-05 17:25:44.319509', NULL, 0, NULL, 10, 'TemporalINFO69_2              ');


--
-- TOC entry 3605 (class 0 OID 61046)
-- Dependencies: 226
-- Data for Name: CFGFILECOLUMNS; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--

INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (8, 'unnamed: 7                                                                                          ', '"BCO1" character(15) COLLATE pg_catalog."default"                                                   ', NULL, NULL, NULL, NULL, 12, NULL, NULL);
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (9, 'unnamed: 8                                                                                          ', '"BCO2" character(15) COLLATE pg_catalog."default"                                                   ', NULL, NULL, NULL, NULL, 12, NULL, NULL);
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (10, 'unnamed: 5                                                                                          ', '"BCO3" character(15) COLLATE pg_catalog."default"                                                   ', NULL, NULL, NULL, NULL, 12, NULL, NULL);
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (11, 'unnamed: 6                                                                                          ', '"BCO4" character(15) COLLATE pg_catalog."default"                                                   ', NULL, NULL, NULL, NULL, 12, NULL, NULL);
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (14, 'situación del contribuyente                                                                         ', '"SITUACION_CONTR" character(40) COLLATE pg_catalog."default"                                        ', NULL, NULL, NULL, NULL, 12, '"SITUACION_CONTR"                                                                                   ', 'TRIM(BOTH FROM "SITUACION_CONTR") AS "SITUACION_CONTR"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (15, 'número y fecha de oficio global de presunción                                                       ', '"FH_OFIC_GLO_PRESUN_SAT" character(150) COLLATE pg_catalog."default"                                ', NULL, NULL, NULL, NULL, 12, '"FH_OFIC_GLO_PRESUN_SAT"                                                                            ', 'TRIM(BOTH FROM "FH_OFIC_GLO_PRESUN_SAT") AS "FH_OFIC_GLO_PRESUN_SAT"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (1, 'rfc                                                                                                 ', '"RFC" character(13) COLLATE pg_catalog."default"                                                    ', NULL, NULL, NULL, NULL, 12, '"RFC"                                                                                               ', '"RFC"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (2, 'razÓn social                                                                                        ', '"RAZON_SOC" character(255) COLLATE pg_catalog."default"                                             ', NULL, NULL, NULL, NULL, 12, '"RAZON_SOC"                                                                                         ', 'TRIM(BOTH FROM "RAZON_SOC") AS "RAZON_SOC"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (3, 'tipo persona                                                                                        ', '"TPO_PERS" character(2) COLLATE pg_catalog."default"                                                ', NULL, NULL, NULL, NULL, 12, '"TPO_PERS"                                                                                          ', 'TRIM(BOTH FROM "TPO_PERS") AS "TPO_PERS"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (5, 'fechas de primera publicacion                                                                       ', '"FH_PRIM_PUB" character(30) COLLATE pg_catalog."default"                                            ', NULL, NULL, NULL, NULL, 12, '"FH_PRIM_PUB"                                                                                       ', 'to_date("FH_PRIM_PUB",''DD/MM/YYYY'') AS "FH_PRIM_PUB"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (6, 'monto                                                                                               ', '"MNTO" character(30) COLLATE pg_catalog."default"                                                   ', NULL, NULL, NULL, NULL, 12, '"MNTO"                                                                                              ', '"MNTO"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (7, 'fecha de publicación (con monto de acuerdo a la ley de transparencia                                ', '"FH_PUB" character(30) COLLATE pg_catalog."default"                                                 ', NULL, NULL, NULL, NULL, 12, '"FH_PUB"                                                                                            ', 'to_date("FH_PUB",''DD/MM/YYYY'') as "FH_PUB"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (12, 'no                                                                                                  ', '"NO" character(70) COLLATE pg_catalog."default"                                                     ', NULL, NULL, NULL, NULL, 12, '"NO"                                                                                                ', 'TO_NUMBER("NO",''999999999'') AS "NO"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (13, 'nombre del contribuyente                                                                            ', '"NAME_CONTR" character(500) COLLATE pg_catalog."default"                                            ', NULL, NULL, NULL, NULL, 12, '"NAME_CONTR"                                                                                        ', 'TRIM(BOTH FROM "NAME_CONTR") AS "NAME_CONTR"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (16, 'publicación página sat presuntos                                                                    ', '"FH_PUB_PRESUN_SAT" character(150) COLLATE pg_catalog."default"                                     ', NULL, NULL, NULL, NULL, 12, '"FH_PUB_PRESUN_SAT"                                                                                 ', 'to_date("FH_PUB_PRESUN_SAT", ''DD/MM/YYYY'') AS "FH_PUB_PRESUN_SAT"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (17, 'número y fecha de oficio global de presunción.1                                                     ', '"FH_OFIC_GLO_PRESUN_DOF" character(150) COLLATE pg_catalog."default"                                ', NULL, NULL, NULL, NULL, 12, '"FH_OFIC_GLO_PRESUN_DOF"                                                                            ', 'TRIM(BOTH FROM "FH_OFIC_GLO_PRESUN_DOF") AS "FH_OFIC_GLO_PRESUN_DOF"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (18, 'publicación dof presuntos                                                                           ', '"FH_PUB_PRESUN_DOF" character(150) COLLATE pg_catalog."default"                                     ', NULL, NULL, NULL, NULL, 12, '"FH_PUB_PRESUN_DOF"                                                                                 ', 'to_date("FH_PUB_PRESUN_DOF", ''DD/MM/YYYY'') AS "FH_PUB_PRESUN_DOF"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (4, 'supuesto                                                                                            ', '"SUPUESTO" character(50) COLLATE pg_catalog."default"                                               ', NULL, NULL, NULL, NULL, 12, '"SUPUESTO"                                                                                          ', 'TRIM(BOTH FROM "SUPUESTO") AS "SUPUESTO"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (20, 'número y fecha de oficio global de contribuyentes que desvirtuaron                                  ', '"FH_OFIC_GLO_DESV_SAT" character(150) COLLATE pg_catalog."default"                                  ', NULL, NULL, NULL, NULL, 12, '"FH_OFIC_GLO_DESV_SAT"                                                                              ', 'TRIM(BOTH FROM "FH_OFIC_GLO_DESV_SAT") AS "FH_OFIC_GLO_DESV_SAT"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (22, 'número y fecha de oficio global de definitivos                                                      ', '"FH_OFIC_GLO_DESV_DOF" character(150) COLLATE pg_catalog."default"                                  ', NULL, NULL, NULL, NULL, 12, '"FH_OFIC_GLO_DESV_DOF"                                                                              ', 'TRIM(BOTH FROM "FH_OFIC_GLO_DESV_DOF") AS "FH_OFIC_GLO_DESV_DOF"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (23, 'publicación página sat definitivos                                                                  ', '"FH_PUB_SAT_DEF" character(150) COLLATE pg_catalog."default"                                        ', NULL, NULL, NULL, NULL, 12, '"FH_PUB_SAT_DEF"                                                                                    ', 'to_date("FH_PUB_SAT_DEF", ''DD/MM/YYYY'') AS "FH_PUB_SAT_DEF"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (24, 'publicación dof definitivos                                                                         ', '"FH_PUB_DOF_DEF" character(150) COLLATE pg_catalog."default"                                        ', NULL, NULL, NULL, NULL, 12, '"FH_PUB_DOF_DEF"                                                                                    ', 'to_date("FH_PUB_DOF_DEF", ''DD/MM/YYYY'') AS "FH_PUB_DOF_DEF"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (25, 'número y fecha de oficio global de sentencia favorable                                              ', '"FH_OFIC_GLO_SENT_FAV" character(150) COLLATE pg_catalog."default"                                  ', NULL, NULL, NULL, NULL, 12, '"FH_OFIC_GLO_SENT_FAV"                                                                              ', 'TRIM(BOTH FROM "FH_OFIC_GLO_SENT_FAV") AS "FH_OFIC_GLO_SENT_FAV"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (26, 'publicación página sat sentencia favorable                                                          ', '"FH_OFIC_GLO_SENT_FAV_SAT" character(150) COLLATE pg_catalog."default"                              ', NULL, NULL, NULL, NULL, 12, '"FH_OFIC_GLO_SENT_FAV_SAT"                                                                          ', 'to_date("FH_OFIC_GLO_SENT_FAV_SAT", ''DD/MM/YYYY'') AS "FH_OFIC_GLO_SENT_FAV_SAT"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (27, 'número y fecha de oficio global de sentencia favorable.1                                            ', '"FH_OFIC_GLO_SENT_FAV_1" character(150) COLLATE pg_catalog."default"                                ', NULL, NULL, NULL, NULL, 12, '"FH_OFIC_GLO_SENT_FAV_1"                                                                            ', 'TRIM(BOTH FROM "FH_OFIC_GLO_SENT_FAV_1") AS "FH_OFIC_GLO_SENT_FAV_1"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (28, 'publicación dof sentencia favorable                                                                 ', '"FH_PUB_SENT_FAV_DOF" character(150) COLLATE pg_catalog."default"                                   ', NULL, NULL, NULL, NULL, 12, '"FH_PUB_SENT_FAV_DOF"                                                                               ', 'to_date("FH_PUB_SENT_FAV_DOF", ''DD/MM/YYYY'') AS "FH_PUB_SENT_FAV_DOF"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (29, 'unnamed: 18                                                                                         ', '"BCO5" character(15) COLLATE pg_catalog."default"                                                   ', NULL, NULL, NULL, NULL, 12, NULL, NULL);
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (30, 'unnamed: 19                                                                                         ', '"BCO6" character(15) COLLATE pg_catalog."default"                                                   ', NULL, NULL, NULL, NULL, 12, NULL, NULL);
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (31, 'unnamed: 20                                                                                         ', '"BCO7" character(15) COLLATE pg_catalog."default"                                                   ', NULL, NULL, NULL, NULL, 12, NULL, NULL);
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (19, 'publicación página sat desvirtuados                                                                 ', '"FH_PUB_DESV_SAT" character(150) COLLATE pg_catalog."default"                                       ', NULL, NULL, NULL, NULL, 12, '"FH_PUB_DESV_SAT"                                                                                   ', 'TRIM(BOTH FROM "FH_PUB_DESV_SAT") AS "FH_PUB_DESV_SAT"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (21, 'publicación dof desvirtuados                                                                        ', '"FH_PUB_DESV_DOF" character(150) COLLATE pg_catalog."default"                                       ', NULL, NULL, NULL, NULL, 12, '"FH_PUB_DESV_DOF"                                                                                   ', 'TRIM(BOTH FROM "FH_PUB_DESV_DOF") AS "FH_PUB_DESV_DOF"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ');


--
-- TOC entry 3608 (class 0 OID 61061)
-- Dependencies: 229
-- Data for Name: CFGPERIODOS; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--

INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (1, '201701', '2017-01-01 00:00:00', '2017-01-31 00:00:00', '2019-10-16 22:54:07.360075', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (2, '201702', '2017-02-01 00:00:00', '2017-02-28 00:00:00', '2019-10-16 22:54:07.360075', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (3, '201703', '2017-03-01 00:00:00', '2017-03-31 00:00:00', '2019-10-16 22:54:07.360075', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (4, '201704', '2017-04-01 00:00:00', '2017-04-30 00:00:00', '2019-10-16 22:54:07.360075', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (5, '201705', '2017-05-01 00:00:00', '2017-05-31 00:00:00', '2019-10-16 22:54:07.360075', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (6, '201706', '2017-06-01 00:00:00', '2017-06-30 00:00:00', '2019-10-16 22:54:07.360075', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (7, '201707', '2017-07-01 00:00:00', '2017-07-31 00:00:00', '2019-10-16 22:54:07.360075', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (8, '201708', '2017-08-01 00:00:00', '2017-08-31 00:00:00', '2019-10-16 22:54:07.360075', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (9, '201709', '2017-09-01 00:00:00', '2017-09-30 00:00:00', '2019-10-16 22:54:07.360075', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (10, '201710', '2017-10-01 00:00:00', '2017-10-31 00:00:00', '2019-10-16 22:54:07.360075', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (11, '201711', '2017-11-01 00:00:00', '2017-11-30 00:00:00', '2019-10-16 22:54:07.360075', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (12, '201712', '2017-12-01 00:00:00', '2017-12-31 00:00:00', '2019-10-16 22:54:07.360075', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (13, '201801', '2018-01-01 00:00:00', '2018-01-31 00:00:00', '2019-10-16 22:59:06.340233', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (14, '201802', '2018-02-01 00:00:00', '2018-02-28 00:00:00', '2019-10-16 22:59:06.340233', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (15, '201803', '2018-03-01 00:00:00', '2018-03-31 00:00:00', '2019-10-16 22:59:06.340233', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (16, '201804', '2018-04-01 00:00:00', '2018-04-30 00:00:00', '2019-10-16 22:59:06.340233', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (17, '201805', '2018-05-01 00:00:00', '2018-05-31 00:00:00', '2019-10-16 22:59:06.340233', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (18, '201806', '2018-06-01 00:00:00', '2018-06-30 00:00:00', '2019-10-16 22:59:06.340233', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (19, '201807', '2018-07-01 00:00:00', '2018-07-31 00:00:00', '2019-10-16 22:59:06.340233', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (20, '201808', '2018-08-01 00:00:00', '2018-08-31 00:00:00', '2019-10-16 22:59:06.340233', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (21, '201809', '2018-09-01 00:00:00', '2018-09-30 00:00:00', '2019-10-16 22:59:06.340233', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (22, '201810', '2018-10-01 00:00:00', '2018-10-31 00:00:00', '2019-10-16 22:59:06.340233', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (23, '201811', '2018-11-01 00:00:00', '2018-11-30 00:00:00', '2019-10-16 22:59:06.340233', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (24, '201812', '2018-12-01 00:00:00', '2018-12-31 00:00:00', '2019-10-16 22:59:06.340233', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (25, '201901', '2019-01-01 00:00:00', '2019-01-31 00:00:00', '2019-10-16 22:59:56.360848', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (26, '201902', '2019-02-01 00:00:00', '2019-02-28 00:00:00', '2019-10-16 22:59:56.360848', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (27, '201903', '2019-03-01 00:00:00', '2019-03-31 00:00:00', '2019-10-16 22:59:56.360848', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (28, '201904', '2019-04-01 00:00:00', '2019-04-30 00:00:00', '2019-10-16 22:59:56.360848', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (29, '201905', '2019-05-01 00:00:00', '2019-05-31 00:00:00', '2019-10-16 22:59:56.360848', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (30, '201906', '2019-06-01 00:00:00', '2019-06-30 00:00:00', '2019-10-16 22:59:56.360848', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (31, '201907', '2019-07-01 00:00:00', '2019-07-31 00:00:00', '2019-10-16 22:59:56.360848', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (32, '201908', '2019-08-01 00:00:00', '2019-08-31 00:00:00', '2019-10-16 22:59:56.360848', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (33, '201909', '2019-09-01 00:00:00', '2019-09-30 00:00:00', '2019-10-16 22:59:56.360848', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (34, '201910', '2019-10-01 00:00:00', '2019-10-31 00:00:00', '2019-10-16 22:59:56.360848', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (35, '201911', '2019-11-01 00:00:00', '2019-11-30 00:00:00', '2019-10-16 22:59:56.360848', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (36, '201912', '2019-12-01 00:00:00', '2019-12-31 00:00:00', '2019-10-16 22:59:56.360848', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (37, '202001', '2020-01-01 00:00:00', '2020-01-31 00:00:00', '2019-10-16 23:00:16.909506', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (38, '202002', '2020-02-01 00:00:00', '2020-02-29 00:00:00', '2019-10-16 23:00:16.909506', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (39, '202003', '2020-03-01 00:00:00', '2020-03-31 00:00:00', '2019-10-16 23:00:16.909506', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (40, '202004', '2020-04-01 00:00:00', '2020-04-30 00:00:00', '2019-10-16 23:00:16.909506', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (41, '202005', '2020-05-01 00:00:00', '2020-05-31 00:00:00', '2019-10-16 23:00:16.909506', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (42, '202006', '2020-06-01 00:00:00', '2020-06-30 00:00:00', '2019-10-16 23:00:16.909506', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (43, '202007', '2020-07-01 00:00:00', '2020-07-31 00:00:00', '2019-10-16 23:00:16.909506', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (44, '202008', '2020-08-01 00:00:00', '2020-08-31 00:00:00', '2019-10-16 23:00:16.909506', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (45, '202009', '2020-09-01 00:00:00', '2020-09-30 00:00:00', '2019-10-16 23:00:16.909506', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (46, '202010', '2020-10-01 00:00:00', '2020-10-31 00:00:00', '2019-10-16 23:00:16.909506', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (47, '202011', '2020-11-01 00:00:00', '2020-11-30 00:00:00', '2019-10-16 23:00:16.909506', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (48, '202012', '2020-12-01 00:00:00', '2020-12-31 00:00:00', '2019-10-16 23:00:16.909506', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (49, '202101', '2021-01-01 00:00:00', '2021-01-31 00:00:00', '2019-10-16 23:00:34.296907', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (50, '202102', '2021-02-01 00:00:00', '2021-02-28 00:00:00', '2019-10-16 23:00:34.296907', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (51, '202103', '2021-03-01 00:00:00', '2021-03-31 00:00:00', '2019-10-16 23:00:34.296907', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (52, '202104', '2021-04-01 00:00:00', '2021-04-30 00:00:00', '2019-10-16 23:00:34.296907', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (53, '202105', '2021-05-01 00:00:00', '2021-05-31 00:00:00', '2019-10-16 23:00:34.296907', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (54, '202106', '2021-06-01 00:00:00', '2021-06-30 00:00:00', '2019-10-16 23:00:34.296907', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (55, '202107', '2021-07-01 00:00:00', '2021-07-31 00:00:00', '2019-10-16 23:00:34.296907', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (56, '202108', '2021-08-01 00:00:00', '2021-08-31 00:00:00', '2019-10-16 23:00:34.296907', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (57, '202109', '2021-09-01 00:00:00', '2021-09-30 00:00:00', '2019-10-16 23:00:34.296907', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (58, '202110', '2021-10-01 00:00:00', '2021-10-31 00:00:00', '2019-10-16 23:00:34.296907', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (59, '202111', '2021-11-01 00:00:00', '2021-11-30 00:00:00', '2019-10-16 23:00:34.296907', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (60, '202112', '2021-12-01 00:00:00', '2021-12-31 00:00:00', '2019-10-16 23:00:34.296907', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (61, '202201', '2022-01-01 00:00:00', '2022-01-31 00:00:00', '2019-10-16 23:00:48.160272', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (62, '202202', '2022-02-01 00:00:00', '2022-02-28 00:00:00', '2019-10-16 23:00:48.160272', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (63, '202203', '2022-03-01 00:00:00', '2022-03-31 00:00:00', '2019-10-16 23:00:48.160272', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (64, '202204', '2022-04-01 00:00:00', '2022-04-30 00:00:00', '2019-10-16 23:00:48.160272', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (65, '202205', '2022-05-01 00:00:00', '2022-05-31 00:00:00', '2019-10-16 23:00:48.160272', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (66, '202206', '2022-06-01 00:00:00', '2022-06-30 00:00:00', '2019-10-16 23:00:48.160272', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (67, '202207', '2022-07-01 00:00:00', '2022-07-31 00:00:00', '2019-10-16 23:00:48.160272', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (68, '202208', '2022-08-01 00:00:00', '2022-08-31 00:00:00', '2019-10-16 23:00:48.160272', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (69, '202209', '2022-09-01 00:00:00', '2022-09-30 00:00:00', '2019-10-16 23:00:48.160272', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (70, '202210', '2022-10-01 00:00:00', '2022-10-31 00:00:00', '2019-10-16 23:00:48.160272', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (71, '202211', '2022-11-01 00:00:00', '2022-11-30 00:00:00', '2019-10-16 23:00:48.160272', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (72, '202212', '2022-12-01 00:00:00', '2022-12-31 00:00:00', '2019-10-16 23:00:48.160272', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (73, '202301', '2023-01-01 00:00:00', '2023-01-31 00:00:00', '2019-10-16 23:01:04.326018', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (74, '202302', '2023-02-01 00:00:00', '2023-02-28 00:00:00', '2019-10-16 23:01:04.326018', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (75, '202303', '2023-03-01 00:00:00', '2023-03-31 00:00:00', '2019-10-16 23:01:04.326018', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (76, '202304', '2023-04-01 00:00:00', '2023-04-30 00:00:00', '2019-10-16 23:01:04.326018', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (77, '202305', '2023-05-01 00:00:00', '2023-05-31 00:00:00', '2019-10-16 23:01:04.326018', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (78, '202306', '2023-06-01 00:00:00', '2023-06-30 00:00:00', '2019-10-16 23:01:04.326018', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (79, '202307', '2023-07-01 00:00:00', '2023-07-31 00:00:00', '2019-10-16 23:01:04.326018', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (80, '202308', '2023-08-01 00:00:00', '2023-08-31 00:00:00', '2019-10-16 23:01:04.326018', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (81, '202309', '2023-09-01 00:00:00', '2023-09-30 00:00:00', '2019-10-16 23:01:04.326018', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (82, '202310', '2023-10-01 00:00:00', '2023-10-31 00:00:00', '2019-10-16 23:01:04.326018', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (83, '202311', '2023-11-01 00:00:00', '2023-11-30 00:00:00', '2019-10-16 23:01:04.326018', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (84, '202312', '2023-12-01 00:00:00', '2023-12-31 00:00:00', '2019-10-16 23:01:04.326018', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (85, '202401', '2024-01-01 00:00:00', '2024-01-31 00:00:00', '2019-10-16 23:01:30.303595', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (86, '202402', '2024-02-01 00:00:00', '2024-02-29 00:00:00', '2019-10-16 23:01:30.303595', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (87, '202403', '2024-03-01 00:00:00', '2024-03-31 00:00:00', '2019-10-16 23:01:30.303595', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (88, '202404', '2024-04-01 00:00:00', '2024-04-30 00:00:00', '2019-10-16 23:01:30.303595', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (89, '202405', '2024-05-01 00:00:00', '2024-05-31 00:00:00', '2019-10-16 23:01:30.303595', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (90, '202406', '2024-06-01 00:00:00', '2024-06-30 00:00:00', '2019-10-16 23:01:30.303595', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (91, '202407', '2024-07-01 00:00:00', '2024-07-31 00:00:00', '2019-10-16 23:01:30.303595', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (92, '202408', '2024-08-01 00:00:00', '2024-08-31 00:00:00', '2019-10-16 23:01:30.303595', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (93, '202409', '2024-09-01 00:00:00', '2024-09-30 00:00:00', '2019-10-16 23:01:30.303595', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (94, '202410', '2024-10-01 00:00:00', '2024-10-31 00:00:00', '2019-10-16 23:01:30.303595', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (95, '202411', '2024-11-01 00:00:00', '2024-11-30 00:00:00', '2019-10-16 23:01:30.303595', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (96, '202412', '2024-12-01 00:00:00', '2024-12-31 00:00:00', '2019-10-16 23:01:30.303595', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (97, '202501', '2025-01-01 00:00:00', '2025-01-31 00:00:00', '2019-10-16 23:01:44.486813', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (98, '202502', '2025-02-01 00:00:00', '2025-02-28 00:00:00', '2019-10-16 23:01:44.486813', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (99, '202503', '2025-03-01 00:00:00', '2025-03-31 00:00:00', '2019-10-16 23:01:44.486813', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (100, '202504', '2025-04-01 00:00:00', '2025-04-30 00:00:00', '2019-10-16 23:01:44.486813', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (101, '202505', '2025-05-01 00:00:00', '2025-05-31 00:00:00', '2019-10-16 23:01:44.486813', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (102, '202506', '2025-06-01 00:00:00', '2025-06-30 00:00:00', '2019-10-16 23:01:44.486813', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (103, '202507', '2025-07-01 00:00:00', '2025-07-31 00:00:00', '2019-10-16 23:01:44.486813', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (104, '202508', '2025-08-01 00:00:00', '2025-08-31 00:00:00', '2019-10-16 23:01:44.486813', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (105, '202509', '2025-09-01 00:00:00', '2025-09-30 00:00:00', '2019-10-16 23:01:44.486813', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (106, '202510', '2025-10-01 00:00:00', '2025-10-31 00:00:00', '2019-10-16 23:01:44.486813', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (107, '202511', '2025-11-01 00:00:00', '2025-11-30 00:00:00', '2019-10-16 23:01:44.486813', NULL, 0, NULL, 38);
INSERT INTO "BaseSistema"."CFGPERIODOS" VALUES (108, '202512', '2025-12-01 00:00:00', '2025-12-31 00:00:00', '2019-10-16 23:01:44.486813', NULL, 0, NULL, 38);


--
-- TOC entry 3610 (class 0 OID 61066)
-- Dependencies: 231
-- Data for Name: INF69; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3611 (class 0 OID 61069)
-- Dependencies: 232
-- Data for Name: INF69B; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3613 (class 0 OID 61077)
-- Dependencies: 234
-- Data for Name: LOGCARGAXML; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3606 (class 0 OID 61053)
-- Dependencies: 227
-- Data for Name: LOGDESCARGAFILE; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3615 (class 0 OID 61086)
-- Dependencies: 236
-- Data for Name: LOGDESCARGAWSAUTH; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3617 (class 0 OID 61095)
-- Dependencies: 238
-- Data for Name: LOGDESCARGAWSPROCESO; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3620 (class 0 OID 61116)
-- Dependencies: 242
-- Data for Name: SOLCONSULPER; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3625 (class 0 OID 61135)
-- Dependencies: 249
-- Data for Name: INF69B_y2019m09; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3626 (class 0 OID 61142)
-- Dependencies: 250
-- Data for Name: INF69B_y2019m10; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3627 (class 0 OID 61149)
-- Dependencies: 251
-- Data for Name: INF69B_y2019m11; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3628 (class 0 OID 61156)
-- Dependencies: 252
-- Data for Name: INF69B_y2019m12; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3629 (class 0 OID 61163)
-- Dependencies: 253
-- Data for Name: INF69B_y2020m01; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3630 (class 0 OID 61170)
-- Dependencies: 254
-- Data for Name: INF69B_y2020m02; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3631 (class 0 OID 61177)
-- Dependencies: 255
-- Data for Name: INF69B_y2020m03; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3632 (class 0 OID 61184)
-- Dependencies: 256
-- Data for Name: INF69B_y2020m04; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3633 (class 0 OID 61191)
-- Dependencies: 257
-- Data for Name: INF69B_y2020m05; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3634 (class 0 OID 61198)
-- Dependencies: 258
-- Data for Name: INF69B_y2020m06; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3635 (class 0 OID 61205)
-- Dependencies: 259
-- Data for Name: INF69B_y2020m07; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3636 (class 0 OID 61212)
-- Dependencies: 260
-- Data for Name: INF69B_y2020m08; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3637 (class 0 OID 61219)
-- Dependencies: 261
-- Data for Name: INF69_y2019m09; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3638 (class 0 OID 61223)
-- Dependencies: 262
-- Data for Name: INF69_y2019m10; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3639 (class 0 OID 61227)
-- Dependencies: 263
-- Data for Name: INF69_y2019m11; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3640 (class 0 OID 61231)
-- Dependencies: 264
-- Data for Name: INF69_y2019m12; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3641 (class 0 OID 61235)
-- Dependencies: 265
-- Data for Name: INF69_y2020m01; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3642 (class 0 OID 61239)
-- Dependencies: 266
-- Data for Name: INF69_y2020m02; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3643 (class 0 OID 61243)
-- Dependencies: 267
-- Data for Name: INF69_y2020m03; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3644 (class 0 OID 61247)
-- Dependencies: 268
-- Data for Name: INF69_y2020m04; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3645 (class 0 OID 61251)
-- Dependencies: 269
-- Data for Name: INF69_y2020m05; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3646 (class 0 OID 61255)
-- Dependencies: 270
-- Data for Name: INF69_y2020m06; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3647 (class 0 OID 61259)
-- Dependencies: 271
-- Data for Name: INF69_y2020m07; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3648 (class 0 OID 61263)
-- Dependencies: 272
-- Data for Name: INF69_y2020m08; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3650 (class 0 OID 61273)
-- Dependencies: 275
-- Data for Name: INF32D_y2019m09; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3651 (class 0 OID 61277)
-- Dependencies: 276
-- Data for Name: INF32D_y2019m10; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3652 (class 0 OID 61281)
-- Dependencies: 277
-- Data for Name: INF32D_y2019m11; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3653 (class 0 OID 61285)
-- Dependencies: 278
-- Data for Name: INF32D_y2019m12; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3654 (class 0 OID 61289)
-- Dependencies: 279
-- Data for Name: INF32D_y2020m01; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3655 (class 0 OID 61293)
-- Dependencies: 280
-- Data for Name: INF32D_y2020m02; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3656 (class 0 OID 61297)
-- Dependencies: 281
-- Data for Name: INF32D_y2020m03; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3657 (class 0 OID 61301)
-- Dependencies: 282
-- Data for Name: INF32D_y2020m04; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3658 (class 0 OID 61305)
-- Dependencies: 283
-- Data for Name: INF32D_y2020m05; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3659 (class 0 OID 61309)
-- Dependencies: 284
-- Data for Name: INF32D_y2020m06; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3660 (class 0 OID 61313)
-- Dependencies: 285
-- Data for Name: INF32D_y2020m07; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3661 (class 0 OID 61317)
-- Dependencies: 286
-- Data for Name: INF32D_y2020m08; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3663 (class 0 OID 61327)
-- Dependencies: 289
-- Data for Name: INFMETA_y2019m09; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3664 (class 0 OID 61331)
-- Dependencies: 290
-- Data for Name: INFMETA_y2019m10; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3665 (class 0 OID 61335)
-- Dependencies: 291
-- Data for Name: INFMETA_y2019m11; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3666 (class 0 OID 61339)
-- Dependencies: 292
-- Data for Name: INFMETA_y2019m12; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3667 (class 0 OID 61343)
-- Dependencies: 293
-- Data for Name: INFMETA_y2020m01; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3668 (class 0 OID 61347)
-- Dependencies: 294
-- Data for Name: INFMETA_y2020m02; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3669 (class 0 OID 61351)
-- Dependencies: 295
-- Data for Name: INFMETA_y2020m03; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3670 (class 0 OID 61355)
-- Dependencies: 296
-- Data for Name: INFMETA_y2020m04; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3671 (class 0 OID 61359)
-- Dependencies: 297
-- Data for Name: INFMETA_y2020m05; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3672 (class 0 OID 61363)
-- Dependencies: 298
-- Data for Name: INFMETA_y2020m06; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3673 (class 0 OID 61367)
-- Dependencies: 299
-- Data for Name: INFMETA_y2020m07; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3674 (class 0 OID 61371)
-- Dependencies: 300
-- Data for Name: INFMETA_y2020m08; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3680 (class 0 OID 61391)
-- Dependencies: 306
-- Data for Name: CFDICOMPROBANTE; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3681 (class 0 OID 61398)
-- Dependencies: 307
-- Data for Name: CFDICOMPROBANTECOMPLEMENTO; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3682 (class 0 OID 61405)
-- Dependencies: 308
-- Data for Name: CFDICOMPROBANTECOMPLEMENTOPAGOS; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3683 (class 0 OID 61409)
-- Dependencies: 309
-- Data for Name: CFDICOMPROBANTECOMPLEMENTOPAGOSDOCS; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3685 (class 0 OID 61415)
-- Dependencies: 311
-- Data for Name: CFDICOMPROBANTEIMPUESTOSRETENIDOS; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3687 (class 0 OID 61421)
-- Dependencies: 313
-- Data for Name: CFDICOMPROBANTEIMPUESTOSTRASLADOS; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3688 (class 0 OID 61425)
-- Dependencies: 314
-- Data for Name: CFDICOMPROBANTERELACIONADOS; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3690 (class 0 OID 61430)
-- Dependencies: 316
-- Data for Name: CFDICONCEPTOS; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3691 (class 0 OID 61437)
-- Dependencies: 317
-- Data for Name: CFDICONCEPTOSIMPUESTOSRETENCIONES; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3692 (class 0 OID 61440)
-- Dependencies: 318
-- Data for Name: CFDICONCEPTOSIMPUESTOSTRASLADOS; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3694 (class 0 OID 61445)
-- Dependencies: 320
-- Data for Name: CFDICONCEPTOSPARTES; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3698 (class 0 OID 61458)
-- Dependencies: 324
-- Data for Name: CFDITOTAL; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3701 (class 0 OID 61471)
-- Dependencies: 327
-- Data for Name: INF32D; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3675 (class 0 OID 61375)
-- Dependencies: 301
-- Data for Name: INFMETA; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3703 (class 0 OID 65221)
-- Dependencies: 329
-- Data for Name: TEMPORAL; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."TEMPORAL" VALUES (3450, '20191023232804 ', 'c92a01f0-fd2c-4211-bc2c-e8205ebe60d9.xml          ', 35, NULL, '2019-10-25 00:01:21.582304', 1, '20191025000121 ', 1, '201904', 38, '1');


--
-- TOC entry 3720 (class 0 OID 0)
-- Dependencies: 208
-- Name: CATACCIONES_ID_ACCION_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CATACCIONES_ID_ACCION_seq"', 6, true);


--
-- TOC entry 3721 (class 0 OID 0)
-- Dependencies: 211
-- Name: CATPROCESOSSTATUS_ID_STATUS_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CATPROCESOSSTATUS_ID_STATUS_seq"', 12, true);


--
-- TOC entry 3722 (class 0 OID 0)
-- Dependencies: 209
-- Name: CATPROCESOS_ID_PROCESO_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CATPROCESOS_ID_PROCESO_seq"', 14, true);


--
-- TOC entry 3723 (class 0 OID 0)
-- Dependencies: 214
-- Name: CATSTATUS_ID_STATUS_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CATSTATUS_ID_STATUS_seq"', 41, true);


--
-- TOC entry 3724 (class 0 OID 0)
-- Dependencies: 215
-- Name: CFGALMACEN_ID_ALMACEN_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CFGALMACEN_ID_ALMACEN_seq"', 1, false);


--
-- TOC entry 3725 (class 0 OID 0)
-- Dependencies: 218
-- Name: CFGCLTESCREDENCIALES_ID_CRED_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CFGCLTESCREDENCIALES_ID_CRED_seq"', 1, true);


--
-- TOC entry 3726 (class 0 OID 0)
-- Dependencies: 225
-- Name: CFGFILECOLUMNS_ID_COLUMN_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CFGFILECOLUMNS_ID_COLUMN_seq"', 31, true);


--
-- TOC entry 3727 (class 0 OID 0)
-- Dependencies: 228
-- Name: CFGFILEUNLOADS_ID_UNLOAD_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CFGFILEUNLOADS_ID_UNLOAD_seq"', 81, true);


--
-- TOC entry 3728 (class 0 OID 0)
-- Dependencies: 223
-- Name: CFGFILE_ID_FILE_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CFGFILE_ID_FILE_seq"', 16, true);


--
-- TOC entry 3729 (class 0 OID 0)
-- Dependencies: 230
-- Name: CFGPERIODOS_ID_PERIODO_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CFGPERIODOS_ID_PERIODO_seq"', 108, true);


--
-- TOC entry 3730 (class 0 OID 0)
-- Dependencies: 216
-- Name: CLTES_ID_CLTE_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CLTES_ID_CLTE_seq"', 1, true);


--
-- TOC entry 3731 (class 0 OID 0)
-- Dependencies: 233
-- Name: LOGCARGAXML_ID_CARGAXML_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."LOGCARGAXML_ID_CARGAXML_seq"', 1, true);


--
-- TOC entry 3732 (class 0 OID 0)
-- Dependencies: 235
-- Name: LOGDESCARGAWSCABECERA_ID_DESCARGA_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."LOGDESCARGAWSCABECERA_ID_DESCARGA_seq"', 1, true);


--
-- TOC entry 3733 (class 0 OID 0)
-- Dependencies: 237
-- Name: LOGDESCARGAWSPROCESO_ID_DESCARGA_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."LOGDESCARGAWSPROCESO_ID_DESCARGA_seq"', 1, true);


--
-- TOC entry 3734 (class 0 OID 0)
-- Dependencies: 221
-- Name: RFCS_ID_RFC_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."RFCS_ID_RFC_seq"', 1, true);


--
-- TOC entry 3735 (class 0 OID 0)
-- Dependencies: 243
-- Name: SOLCONSULPER_ID_CONSULTA_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."SOLCONSULPER_ID_CONSULTA_seq"', 1, true);


--
-- TOC entry 3736 (class 0 OID 0)
-- Dependencies: 244
-- Name: USRSIST_ID_USR_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."USRSIST_ID_USR_seq"', 1, false);


--
-- TOC entry 3737 (class 0 OID 0)
-- Dependencies: 247
-- Name: INF69B_ID_INF_seq; Type: SEQUENCE SET; Schema: BaseSistemaHistorico; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"', 1, true);


--
-- TOC entry 3738 (class 0 OID 0)
-- Dependencies: 245
-- Name: INF69_ID_INF_seq; Type: SEQUENCE SET; Schema: BaseSistemaHistorico; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistemaHistorico"."INF69_ID_INF_seq"', 1, true);


--
-- TOC entry 3739 (class 0 OID 0)
-- Dependencies: 273
-- Name: INF32D_ID_INF_seq; Type: SEQUENCE SET; Schema: InfHistorica; Owner: postgres
--

SELECT pg_catalog.setval('"InfHistorica"."INF32D_ID_INF_seq"', 1, false);


--
-- TOC entry 3740 (class 0 OID 0)
-- Dependencies: 287
-- Name: INFMETA_ID_INF_seq; Type: SEQUENCE SET; Schema: InfHistorica; Owner: postgres
--

SELECT pg_catalog.setval('"InfHistorica"."INFMETA_ID_INF_seq"', 1, true);


--
-- TOC entry 3741 (class 0 OID 0)
-- Dependencies: 302
-- Name: CFDICOMPLEMENTOSPAGOS_ID_PAGODOCS_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDICOMPLEMENTOSPAGOS_ID_PAGODOCS_seq"', 1, true);


--
-- TOC entry 3742 (class 0 OID 0)
-- Dependencies: 303
-- Name: CFDICOMPLEMENTOSPAGOS_ID_PAGO_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDICOMPLEMENTOSPAGOS_ID_PAGO_seq"', 1, true);


--
-- TOC entry 3743 (class 0 OID 0)
-- Dependencies: 304
-- Name: CFDICOMPLEMENTOS_ID_COMPLEMENTO_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDICOMPLEMENTOS_ID_COMPLEMENTO_seq"', 1, true);


--
-- TOC entry 3744 (class 0 OID 0)
-- Dependencies: 305
-- Name: CFDICOMPROBANTE_ID_COMPROBANTE_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDICOMPROBANTE_ID_COMPROBANTE_seq"', 1, true);


--
-- TOC entry 3745 (class 0 OID 0)
-- Dependencies: 315
-- Name: CFDICONCEPTOS_ID_CONCEPTO_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDICONCEPTOS_ID_CONCEPTO_seq"', 1, true);


--
-- TOC entry 3746 (class 0 OID 0)
-- Dependencies: 321
-- Name: CFDIIMPUESTOS_ID_IMPUESTO_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDIIMPUESTOS_ID_IMPUESTO_seq"', 1, true);


--
-- TOC entry 3747 (class 0 OID 0)
-- Dependencies: 319
-- Name: CFDIPARTES_ID_PARTE_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDIPARTES_ID_PARTE_seq"', 1, false);


--
-- TOC entry 3748 (class 0 OID 0)
-- Dependencies: 322
-- Name: CFDIRELACIONADOS_ID_RELACIONADOS_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDIRELACIONADOS_ID_RELACIONADOS_seq"', 1, true);


--
-- TOC entry 3749 (class 0 OID 0)
-- Dependencies: 323
-- Name: CFDIRETENCIONES_ID_RETENCION_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDIRETENCIONES_ID_RETENCION_seq"', 1, true);


--
-- TOC entry 3750 (class 0 OID 0)
-- Dependencies: 310
-- Name: CFDIRETENIDOS_ID_RETENIDO_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDIRETENIDOS_ID_RETENIDO_seq"', 1, true);


--
-- TOC entry 3751 (class 0 OID 0)
-- Dependencies: 325
-- Name: CFDITOTAL_ID_CFDI_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDITOTAL_ID_CFDI_seq"', 1, false);


--
-- TOC entry 3752 (class 0 OID 0)
-- Dependencies: 312
-- Name: CFDITRASLADOS_ID_TRASLADO_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDITRASLADOS_ID_TRASLADO_seq"', 1, true);


--
-- TOC entry 3452 (class 2606 OID 61484)
-- Name: CFGPERIODOS CFGPERIODOS_pkey; Type: CONSTRAINT; Schema: BaseSistema; Owner: postgres
--

ALTER TABLE ONLY "BaseSistema"."CFGPERIODOS"
    ADD CONSTRAINT "CFGPERIODOS_pkey" PRIMARY KEY ("ID_PERIODO");


--
-- TOC entry 3454 (class 2606 OID 61486)
-- Name: LOGCARGAXML LOGCARGAXML_pkey; Type: CONSTRAINT; Schema: BaseSistema; Owner: postgres
--

ALTER TABLE ONLY "BaseSistema"."LOGCARGAXML"
    ADD CONSTRAINT "LOGCARGAXML_pkey" PRIMARY KEY ("ID_CARGAXML");


--
-- TOC entry 3456 (class 2606 OID 61488)
-- Name: SOLCONSULPER SOLCONSULPER_pkey; Type: CONSTRAINT; Schema: BaseSistema; Owner: postgres
--

ALTER TABLE ONLY "BaseSistema"."SOLCONSULPER"
    ADD CONSTRAINT "SOLCONSULPER_pkey" PRIMARY KEY ("ID_CONSULTA");


--
-- TOC entry 3457 (class 1259 OID 61489)
-- Name: IDX_CFDICOMPROBANTE_1; Type: INDEX; Schema: InfUsuario; Owner: postgres
--

CREATE INDEX "IDX_CFDICOMPROBANTE_1" ON "InfUsuario"."CFDICOMPROBANTE" USING btree ("TIPODECOMPROBANTE", "METODOPAGO", "FORMAPAGO");


--
-- TOC entry 3459 (class 1259 OID 61490)
-- Name: IDX_CFDICONCEPTOSIMPUESTOSTRASLADADOS_1; Type: INDEX; Schema: InfUsuario; Owner: postgres
--

CREATE INDEX "IDX_CFDICONCEPTOSIMPUESTOSTRASLADADOS_1" ON "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" USING btree ("IMPUESTO");


--
-- TOC entry 3458 (class 1259 OID 61491)
-- Name: IDX_CFDICONCEPTOS_1; Type: INDEX; Schema: InfUsuario; Owner: postgres
--

CREATE INDEX "IDX_CFDICONCEPTOS_1" ON "InfUsuario"."CFDICONCEPTOS" USING btree ("CLAVEPRODSERV");


--
-- TOC entry 3618 (class 0 OID 61102)
-- Dependencies: 239 3705
-- Name: PROVEEDORES69; Type: MATERIALIZED VIEW DATA; Schema: BaseSistema; Owner: postgres
--

REFRESH MATERIALIZED VIEW "BaseSistema"."PROVEEDORES69";


--
-- TOC entry 3619 (class 0 OID 61107)
-- Dependencies: 240 3705
-- Name: PROVEEDORES69B; Type: MATERIALIZED VIEW DATA; Schema: BaseSistema; Owner: postgres
--

REFRESH MATERIALIZED VIEW "BaseSistema"."PROVEEDORES69B";


--
-- TOC entry 3702 (class 0 OID 65173)
-- Dependencies: 328 3619 3618 3705
-- Name: CATALOGOPROVEEDORES; Type: MATERIALIZED VIEW DATA; Schema: InfUsuario; Owner: postgres
--

REFRESH MATERIALIZED VIEW "InfUsuario"."CATALOGOPROVEEDORES";


--
-- TOC entry 3700 (class 0 OID 61466)
-- Dependencies: 326 3619 3618 3705
-- Name: CFDIVALIDADOS69Y69B; Type: MATERIALIZED VIEW DATA; Schema: InfUsuario; Owner: postgres
--

REFRESH MATERIALIZED VIEW "InfUsuario"."CFDIVALIDADOS69Y69B";


-- Completed on 2019-10-29 15:51:07 CST

--
-- PostgreSQL database dump complete
--

