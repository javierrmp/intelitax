--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5 (Ubuntu 11.5-1.pgdg19.04+1)
-- Dumped by pg_dump version 11.5 (Ubuntu 11.5-1.pgdg19.04+1)

-- Started on 2019-10-09 09:21:21 CDT

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
-- TOC entry 3719 (class 1262 OID 38275)
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
-- TOC entry 16 (class 2615 OID 38276)
-- Name: BaseSistema; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "BaseSistema";


ALTER SCHEMA "BaseSistema" OWNER TO postgres;

--
-- TOC entry 15 (class 2615 OID 38277)
-- Name: BaseSistemaHistorico; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "BaseSistemaHistorico";


ALTER SCHEMA "BaseSistemaHistorico" OWNER TO postgres;

--
-- TOC entry 5 (class 2615 OID 38278)
-- Name: InfHistorica; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "InfHistorica";


ALTER SCHEMA "InfHistorica" OWNER TO postgres;

--
-- TOC entry 23 (class 2615 OID 38279)
-- Name: InfUsuario; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "InfUsuario";


ALTER SCHEMA "InfUsuario" OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 45384)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 3720 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 391 (class 1255 OID 45459)
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
-- TOC entry 340 (class 1255 OID 42034)
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
-- TOC entry 339 (class 1255 OID 38284)
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
-- TOC entry 392 (class 1255 OID 41874)
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
-- TOC entry 353 (class 1255 OID 42442)
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
		TRUNCATE TABLE "InfUsuario"."INFMETA";

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
-- TOC entry 390 (class 1255 OID 45477)
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
-- TOC entry 393 (class 1255 OID 47419)
-- Name: RecargaResultados(character); Type: PROCEDURE; Schema: BaseSistema; Owner: postgres
--

CREATE PROCEDURE "BaseSistema"."RecargaResultados"(cve_descarga character)
    LANGUAGE plpgsql
    AS $$
DECLARE HayDatos int;
begin

	SELECT COUNT(1) INTO HayDatos FROM "InfUsuario"."CFDICOMPROBANTE" WHERE "CVE_DESCARGA" = cve_descarga;
	
	RAISE NOTICE 'Hay datos XML (%)',HayDatos;
	
	IF HayDatos > 0 THEN
		REFRESH MATERIALIZED VIEW "InfUsuario"."CFDIVALIDADOS69Y69B" WITH DATA;
		REFRESH MATERIALIZED VIEW "InfUsuario"."DET_IVA_ACREDITABLE_APLIC_ANTICIPOS" WITH DATA;
		REFRESH MATERIALIZED VIEW "InfUsuario"."DET_IVA_ACREDITABLE_DEVOLUCIONES" WITH DATA;
		REFRESH MATERIALIZED VIEW "InfUsuario"."DET_IVA_ACREDITABLE_DISMINUCION_APLIC_ANTICIPOS" WITH DATA;
		REFRESH MATERIALIZED VIEW "InfUsuario"."DET_IVA_ACREDITABLE_DISMINUCION_NC" WITH DATA;
		REFRESH MATERIALIZED VIEW "InfUsuario"."DET_IVA_ACREDITABLE_NOTAS_DEBITO" WITH DATA;
		REFRESH MATERIALIZED VIEW "InfUsuario"."DET_IVA_ACREDITABLE_PAGOS_CONTADO" WITH DATA;
		REFRESH MATERIALIZED VIEW "InfUsuario"."DET_IVA_ACREDITABLE_PAGO_ANTICIPO" WITH DATA;
		REFRESH MATERIALIZED VIEW "InfUsuario"."DET_IVA_TRASLADADO_ANTICIPOS" WITH DATA;
		REFRESH MATERIALIZED VIEW "InfUsuario"."DET_IVA_TRASLADADO_APLIC_ANTICIPOS" WITH DATA;
		REFRESH MATERIALIZED VIEW "InfUsuario"."DET_IVA_TRASLADADO_DEVOLUCIONES" WITH DATA;
		REFRESH MATERIALIZED VIEW "InfUsuario"."DET_IVA_TRASLADADO_EGRESO_APLIC_ANTICIPOS" WITH DATA;
		REFRESH MATERIALIZED VIEW "InfUsuario"."DET_IVA_TRASLADADO_EGRESO_DESCUENTOS_NC" WITH DATA;
		REFRESH MATERIALIZED VIEW "InfUsuario"."DET_IVA_TRASLADADO_NOTAS_DEBITO" WITH DATA;
		REFRESH MATERIALIZED VIEW "InfUsuario"."DET_IVA_TRASLADADO_VTAS_CONTADO" WITH DATA;
	END IF;
	
end;
$$;


ALTER PROCEDURE "BaseSistema"."RecargaResultados"(cve_descarga character) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 213 (class 1259 OID 38285)
-- Name: CATACCIONES; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CATACCIONES" (
    "ID_ACCION" integer NOT NULL,
    "DESCRIPCION" character(25)
);


ALTER TABLE "BaseSistema"."CATACCIONES" OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 38288)
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
-- TOC entry 3721 (class 0 OID 0)
-- Dependencies: 214
-- Name: CATACCIONES_ID_ACCION_seq; Type: SEQUENCE OWNED BY; Schema: BaseSistema; Owner: postgres
--

ALTER SEQUENCE "BaseSistema"."CATACCIONES_ID_ACCION_seq" OWNED BY "BaseSistema"."CATACCIONES"."ID_ACCION";


--
-- TOC entry 215 (class 1259 OID 38290)
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
-- TOC entry 216 (class 1259 OID 38292)
-- Name: CATPROCESOS; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CATPROCESOS" (
    "ID_PROCESO" integer DEFAULT nextval('"BaseSistema"."CATPROCESOS_ID_PROCESO_seq"'::regclass) NOT NULL,
    "DESCRIPCION" character(30)
);


ALTER TABLE "BaseSistema"."CATPROCESOS" OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 38296)
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
-- TOC entry 218 (class 1259 OID 38298)
-- Name: CATPROCESOSSTATUS; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CATPROCESOSSTATUS" (
    "ID_PROCESOSTATUS" integer DEFAULT nextval('"BaseSistema"."CATPROCESOSSTATUS_ID_STATUS_seq"'::regclass) NOT NULL,
    "DESCRIPCION" character(20)
);


ALTER TABLE "BaseSistema"."CATPROCESOSSTATUS" OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 38302)
-- Name: CATSTATUS; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."CATSTATUS" (
    "ID_STATUS" integer NOT NULL,
    "ID_PROCESO" bigint NOT NULL,
    "ID_PROCESOSTATUS" bigint NOT NULL
);


ALTER TABLE "BaseSistema"."CATSTATUS" OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 38305)
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
-- TOC entry 3722 (class 0 OID 0)
-- Dependencies: 220
-- Name: CATSTATUS_ID_STATUS_seq; Type: SEQUENCE OWNED BY; Schema: BaseSistema; Owner: postgres
--

ALTER SEQUENCE "BaseSistema"."CATSTATUS_ID_STATUS_seq" OWNED BY "BaseSistema"."CATSTATUS"."ID_STATUS";


--
-- TOC entry 221 (class 1259 OID 38307)
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
-- TOC entry 222 (class 1259 OID 38309)
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
-- TOC entry 223 (class 1259 OID 38311)
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
-- TOC entry 329 (class 1259 OID 45432)
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
-- TOC entry 330 (class 1259 OID 45434)
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
-- TOC entry 224 (class 1259 OID 38326)
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
-- TOC entry 225 (class 1259 OID 38330)
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
-- TOC entry 226 (class 1259 OID 38332)
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
-- TOC entry 227 (class 1259 OID 38336)
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
-- TOC entry 228 (class 1259 OID 38338)
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
-- TOC entry 229 (class 1259 OID 38345)
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
-- TOC entry 230 (class 1259 OID 38347)
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
-- TOC entry 231 (class 1259 OID 38351)
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
-- TOC entry 232 (class 1259 OID 38354)
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
-- TOC entry 3723 (class 0 OID 0)
-- Dependencies: 232
-- Name: CFGFILEUNLOADS_ID_UNLOAD_seq; Type: SEQUENCE OWNED BY; Schema: BaseSistema; Owner: postgres
--

ALTER SEQUENCE "BaseSistema"."CFGFILEUNLOADS_ID_UNLOAD_seq" OWNED BY "BaseSistema"."LOGDESCARGAFILE"."ID_DESCARGA";


--
-- TOC entry 233 (class 1259 OID 38356)
-- Name: INF69; Type: TABLE; Schema: BaseSistema; Owner: postgres
--

CREATE TABLE "BaseSistema"."INF69" (
    "ID_INF" integer,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(20),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "AGRUPACION" character(20),
    "SELECCION" bigint
);


ALTER TABLE "BaseSistema"."INF69" OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 38359)
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
-- TOC entry 331 (class 1259 OID 45490)
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
-- TOC entry 332 (class 1259 OID 45499)
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
    "CVE_CARGA" character(15)
);


ALTER TABLE "BaseSistema"."LOGDESCARGAWSAUTH" OWNER TO postgres;

--
-- TOC entry 333 (class 1259 OID 45527)
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
-- TOC entry 334 (class 1259 OID 45529)
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
    "MSGERROR" text
);


ALTER TABLE "BaseSistema"."LOGDESCARGAWSPROCESO" OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 38373)
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
-- TOC entry 236 (class 1259 OID 38378)
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
-- TOC entry 237 (class 1259 OID 38383)
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
-- TOC entry 238 (class 1259 OID 38387)
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
-- TOC entry 239 (class 1259 OID 38389)
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
-- TOC entry 240 (class 1259 OID 38391)
-- Name: INF69; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(20),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(20),
    "SELECCION" bigint
)
PARTITION BY RANGE ("FH_HIST");


ALTER TABLE "BaseSistemaHistorico"."INF69" OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 38395)
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
-- TOC entry 242 (class 1259 OID 38397)
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
-- TOC entry 243 (class 1259 OID 38401)
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
-- TOC entry 244 (class 1259 OID 38408)
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
-- TOC entry 245 (class 1259 OID 38415)
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
-- TOC entry 246 (class 1259 OID 38422)
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
-- TOC entry 247 (class 1259 OID 38429)
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
-- TOC entry 248 (class 1259 OID 38436)
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
-- TOC entry 249 (class 1259 OID 38443)
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
-- TOC entry 250 (class 1259 OID 38450)
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
-- TOC entry 251 (class 1259 OID 38457)
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
-- TOC entry 252 (class 1259 OID 38464)
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
-- TOC entry 253 (class 1259 OID 38471)
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
-- TOC entry 254 (class 1259 OID 38478)
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
-- TOC entry 255 (class 1259 OID 38485)
-- Name: INF69_y2019m09; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2019m09" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(20),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(20),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2019m09" FOR VALUES FROM ('2019-09-01') TO ('2019-10-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2019m09" OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 38489)
-- Name: INF69_y2019m10; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2019m10" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(20),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(20),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2019m10" FOR VALUES FROM ('2019-10-01') TO ('2019-11-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2019m10" OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 38493)
-- Name: INF69_y2019m11; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2019m11" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(20),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(20),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2019m11" FOR VALUES FROM ('2019-11-01') TO ('2019-12-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2019m11" OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 38497)
-- Name: INF69_y2019m12; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2019m12" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(20),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(20),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2019m12" FOR VALUES FROM ('2019-12-01') TO ('2020-01-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2019m12" OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 38501)
-- Name: INF69_y2020m01; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m01" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(20),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(20),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m01" FOR VALUES FROM ('2020-01-01') TO ('2020-02-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m01" OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 38505)
-- Name: INF69_y2020m02; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m02" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(20),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(20),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m02" FOR VALUES FROM ('2020-02-01') TO ('2020-03-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m02" OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 38509)
-- Name: INF69_y2020m03; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m03" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(20),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(20),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m03" FOR VALUES FROM ('2020-03-01') TO ('2020-04-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m03" OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 38513)
-- Name: INF69_y2020m04; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m04" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(20),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(20),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m04" FOR VALUES FROM ('2020-04-01') TO ('2020-05-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m04" OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 38517)
-- Name: INF69_y2020m05; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m05" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(20),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(20),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m05" FOR VALUES FROM ('2020-05-01') TO ('2020-06-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m05" OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 38521)
-- Name: INF69_y2020m06; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m06" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(20),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(20),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m06" FOR VALUES FROM ('2020-06-01') TO ('2020-07-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m06" OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 38525)
-- Name: INF69_y2020m07; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m07" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(20),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(20),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m07" FOR VALUES FROM ('2020-07-01') TO ('2020-08-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m07" OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 38529)
-- Name: INF69_y2020m08; Type: TABLE; Schema: BaseSistemaHistorico; Owner: postgres
--

CREATE TABLE "BaseSistemaHistorico"."INF69_y2020m08" (
    "ID_INF" integer DEFAULT nextval('"BaseSistemaHistorico"."INF69_ID_INF_seq"'::regclass) NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255),
    "TPO_PERS" character(1),
    "SUPUESTO" character(20),
    "FH_PRIM_PUB" timestamp with time zone,
    "MNTO" character(30),
    "FH_PUB" timestamp without time zone,
    "CVE_DESCARGA" character(15),
    "FH_HIST" date NOT NULL,
    "AGRUPACION" character(20),
    "SELECCION" bigint
);
ALTER TABLE ONLY "BaseSistemaHistorico"."INF69" ATTACH PARTITION "BaseSistemaHistorico"."INF69_y2020m08" FOR VALUES FROM ('2020-08-01') TO ('2020-09-01');


ALTER TABLE "BaseSistemaHistorico"."INF69_y2020m08" OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 38533)
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
-- TOC entry 268 (class 1259 OID 38535)
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
-- TOC entry 269 (class 1259 OID 38539)
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
-- TOC entry 270 (class 1259 OID 38543)
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
-- TOC entry 271 (class 1259 OID 38547)
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
-- TOC entry 272 (class 1259 OID 38551)
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
-- TOC entry 273 (class 1259 OID 38555)
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
-- TOC entry 274 (class 1259 OID 38559)
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
-- TOC entry 275 (class 1259 OID 38563)
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
-- TOC entry 276 (class 1259 OID 38567)
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
-- TOC entry 277 (class 1259 OID 38571)
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
-- TOC entry 278 (class 1259 OID 38575)
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
-- TOC entry 279 (class 1259 OID 38579)
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
-- TOC entry 280 (class 1259 OID 38583)
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
-- TOC entry 281 (class 1259 OID 38587)
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
-- TOC entry 282 (class 1259 OID 38589)
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
-- TOC entry 283 (class 1259 OID 38593)
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
-- TOC entry 284 (class 1259 OID 38597)
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
-- TOC entry 285 (class 1259 OID 38601)
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
-- TOC entry 286 (class 1259 OID 38605)
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
-- TOC entry 287 (class 1259 OID 38609)
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
-- TOC entry 288 (class 1259 OID 38613)
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
-- TOC entry 289 (class 1259 OID 38617)
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
-- TOC entry 290 (class 1259 OID 38621)
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
-- TOC entry 291 (class 1259 OID 38625)
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
-- TOC entry 292 (class 1259 OID 38629)
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
-- TOC entry 293 (class 1259 OID 38633)
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
-- TOC entry 294 (class 1259 OID 38637)
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
-- TOC entry 295 (class 1259 OID 38641)
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
-- TOC entry 296 (class 1259 OID 38644)
-- Name: CATALOGOPROVEEDORES; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."CATALOGOPROVEEDORES" AS
 SELECT tb."RFC_CLTE",
    tb."RFC_ASOC",
    tb."RFC_EMISOR",
    tb."NAME_EMISOR",
    tb."ESTATUS_69",
    tb."FH_PUB_69",
    tb."ESTATUS_69B",
    tb."FH_PUB_69B"
   FROM ( SELECT te."RFC" AS "RFC_CLTE",
            td."RFC" AS "RFC_ASOC",
            ta."RFC_EMISOR",
            ta."NAME_EMISOR",
            tb_1."ESTATUS_69",
            tb_1."FH_PUB_69",
            tf."ESTATUS_69B",
            tf."FH_PUB_69B"
           FROM ((((("InfUsuario"."INFMETA" ta
             LEFT JOIN "BaseSistema"."PROVEEDORES69" tb_1 ON ((tb_1."RFC" = ta."RFC_EMISOR")))
             LEFT JOIN "BaseSistema"."PROVEEDORES69B" tf ON ((tf."RFC" = ta."RFC_EMISOR")))
             LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = ta."CVE_DESCARGA")))
             LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
             LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))) tb
  GROUP BY tb."RFC_CLTE", tb."RFC_ASOC", tb."RFC_EMISOR", tb."NAME_EMISOR", tb."ESTATUS_69", tb."FH_PUB_69", tb."ESTATUS_69B", tb."FH_PUB_69B"
  WITH NO DATA;


ALTER TABLE "InfUsuario"."CATALOGOPROVEEDORES" OWNER TO postgres;

--
-- TOC entry 337 (class 1259 OID 47141)
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
-- TOC entry 297 (class 1259 OID 38649)
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
-- TOC entry 298 (class 1259 OID 38651)
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
-- TOC entry 338 (class 1259 OID 47143)
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
-- TOC entry 335 (class 1259 OID 47135)
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
-- TOC entry 336 (class 1259 OID 47137)
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
-- TOC entry 299 (class 1259 OID 38658)
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
-- TOC entry 300 (class 1259 OID 38660)
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
-- TOC entry 301 (class 1259 OID 38664)
-- Name: CFDICOMPROBANTERELACIONADOS; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICOMPROBANTERELACIONADOS" (
    "ID_RELACIONADOS" integer NOT NULL,
    "TIPORELACION" character(2),
    "UUID" character(30),
    "ID_COMPROBANTE" bigint
);


ALTER TABLE "InfUsuario"."CFDICOMPROBANTERELACIONADOS" OWNER TO postgres;

--
-- TOC entry 302 (class 1259 OID 38667)
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
-- TOC entry 303 (class 1259 OID 38669)
-- Name: CFDICONCEPTOS; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICONCEPTOS" (
    "ID_CONCEPTO" integer DEFAULT nextval('"InfUsuario"."CFDICONCEPTOS_ID_CONCEPTO_seq"'::regclass) NOT NULL,
    "CLAVEPRODSERV" character(10),
    "NOIDENTIFICACION" character(100),
    "CANTIDAD" double precision,
    "CLAVEUNIDAD" character(5),
    "UNIDAD" character(10),
    "DESCRIPCION" character(1000),
    "VALORUNITARIO" double precision,
    "IMPORTE" double precision,
    "DESCUENTO" double precision,
    "NUMEROPEDIM" character(20),
    "NUMEROCUENTAPREDIAL" character(150),
    "ID_COMPROBANTE" bigint
);


ALTER TABLE "InfUsuario"."CFDICONCEPTOS" OWNER TO postgres;

--
-- TOC entry 304 (class 1259 OID 38676)
-- Name: CFDICONCEPTOSIMPUESTOSRETENCIONES; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICONCEPTOSIMPUESTOSRETENCIONES" (
    "ID_RETENCION" integer NOT NULL,
    "BASE" double precision,
    "IMPUESTO" character(3),
    "TIPOFACTOR" character(8),
    "TASAOCUOTA" double precision,
    "IMPORTE" double precision,
    "ID_CONCEPTO" bigint
);


ALTER TABLE "InfUsuario"."CFDICONCEPTOSIMPUESTOSRETENCIONES" OWNER TO postgres;

--
-- TOC entry 305 (class 1259 OID 38679)
-- Name: CFDICONCEPTOSIMPUESTOSTRASLADOS; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" (
    "ID_IMPUESTO" integer NOT NULL,
    "BASE" double precision,
    "IMPUESTO" character(3),
    "TIPOFACTOR" character(8),
    "TASAOCUOTA" double precision,
    "IMPORTE" double precision,
    "ID_CONCEPTO" bigint
);


ALTER TABLE "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" OWNER TO postgres;

--
-- TOC entry 306 (class 1259 OID 38682)
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
-- TOC entry 307 (class 1259 OID 38684)
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
-- TOC entry 308 (class 1259 OID 38691)
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
-- TOC entry 3724 (class 0 OID 0)
-- Dependencies: 308
-- Name: CFDIIMPUESTOS_ID_IMPUESTO_seq; Type: SEQUENCE OWNED BY; Schema: InfUsuario; Owner: postgres
--

ALTER SEQUENCE "InfUsuario"."CFDIIMPUESTOS_ID_IMPUESTO_seq" OWNED BY "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS"."ID_IMPUESTO";


--
-- TOC entry 309 (class 1259 OID 38693)
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
-- TOC entry 3725 (class 0 OID 0)
-- Dependencies: 309
-- Name: CFDIRELACIONADOS_ID_RELACIONADOS_seq; Type: SEQUENCE OWNED BY; Schema: InfUsuario; Owner: postgres
--

ALTER SEQUENCE "InfUsuario"."CFDIRELACIONADOS_ID_RELACIONADOS_seq" OWNED BY "InfUsuario"."CFDICOMPROBANTERELACIONADOS"."ID_RELACIONADOS";


--
-- TOC entry 310 (class 1259 OID 38695)
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
-- TOC entry 3726 (class 0 OID 0)
-- Dependencies: 310
-- Name: CFDIRETENCIONES_ID_RETENCION_seq; Type: SEQUENCE OWNED BY; Schema: InfUsuario; Owner: postgres
--

ALTER SEQUENCE "InfUsuario"."CFDIRETENCIONES_ID_RETENCION_seq" OWNED BY "InfUsuario"."CFDICONCEPTOSIMPUESTOSRETENCIONES"."ID_RETENCION";


--
-- TOC entry 311 (class 1259 OID 38697)
-- Name: CFDITOTAL; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."CFDITOTAL" (
    "ID_CFDI" integer NOT NULL,
    "TEXTOCFDI" xml,
    "CVE_DESCARGA" character(15)
);


ALTER TABLE "InfUsuario"."CFDITOTAL" OWNER TO postgres;

--
-- TOC entry 312 (class 1259 OID 38703)
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
-- TOC entry 3727 (class 0 OID 0)
-- Dependencies: 312
-- Name: CFDITOTAL_ID_CFDI_seq; Type: SEQUENCE OWNED BY; Schema: InfUsuario; Owner: postgres
--

ALTER SEQUENCE "InfUsuario"."CFDITOTAL_ID_CFDI_seq" OWNED BY "InfUsuario"."CFDITOTAL"."ID_CFDI";


--
-- TOC entry 313 (class 1259 OID 38705)
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
     LEFT JOIN "BaseSistema"."PROVEEDORES69" tf ON ((tf."RFC" = ta."RFCRECEPTOR")))
     LEFT JOIN "BaseSistema"."PROVEEDORES69B" tg ON ((tg."RFC" = ta."RFCRECEPTOR")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WITH NO DATA;


ALTER TABLE "InfUsuario"."CFDIVALIDADOS69Y69B" OWNER TO postgres;

--
-- TOC entry 314 (class 1259 OID 38710)
-- Name: DET_IVA_ACREDITABLE_APLIC_ANTICIPOS; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."DET_IVA_ACREDITABLE_APLIC_ANTICIPOS" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCRECEPTOR",
    ta."TIPODECOMPROBANTE",
    ta."METODOPAGO",
    tf."TIPORELACION",
    tg."IMPUESTO",
    tg."IMPORTE"
   FROM (((((("InfUsuario"."CFDICOMPROBANTE" ta
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTERELACIONADOS" tf ON ((tf."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTEIMPUESTOSTRASLADOS" tg ON ((tg."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WHERE (
        CASE
            WHEN ((ta."TIPODECOMPROBANTE" = 'I'::bpchar) AND (ta."METODOPAGO" = 'PUE'::bpchar) AND (tf."TIPORELACION" = '07'::bpchar) AND (tg."IMPUESTO" = '002'::bpchar)) THEN 1
            ELSE 0
        END = 1)
  WITH NO DATA;


ALTER TABLE "InfUsuario"."DET_IVA_ACREDITABLE_APLIC_ANTICIPOS" OWNER TO postgres;

--
-- TOC entry 315 (class 1259 OID 38715)
-- Name: DET_IVA_ACREDITABLE_DEVOLUCIONES; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."DET_IVA_ACREDITABLE_DEVOLUCIONES" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCRECEPTOR",
    ta."TIPODECOMPROBANTE",
    ta."METODOPAGO",
    ta."FORMAPAGO",
    th."TIPORELACION",
    tg."IMPUESTO",
    tg."IMPORTE"
   FROM (((((("InfUsuario"."CFDICOMPROBANTE" ta
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTEIMPUESTOSTRASLADOS" tg ON ((tg."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTERELACIONADOS" th ON ((th."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WHERE (
        CASE
            WHEN ((ta."TIPODECOMPROBANTE" = 'E'::bpchar) AND (ta."METODOPAGO" = 'PUE'::bpchar) AND (ta."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND (th."TIPORELACION" = '03'::bpchar) AND (tg."IMPUESTO" = '002'::bpchar)) THEN 1
            ELSE 0
        END = 1)
  WITH NO DATA;


ALTER TABLE "InfUsuario"."DET_IVA_ACREDITABLE_DEVOLUCIONES" OWNER TO postgres;

--
-- TOC entry 316 (class 1259 OID 38720)
-- Name: DET_IVA_ACREDITABLE_DISMINUCION_APLIC_ANTICIPOS; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."DET_IVA_ACREDITABLE_DISMINUCION_APLIC_ANTICIPOS" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCRECEPTOR",
    ta."TIPODECOMPROBANTE",
    ta."METODOPAGO",
    ta."FORMAPAGO",
    th."TIPORELACION",
    ti."CLAVEPRODSERV",
    tg."IMPUESTO",
    tg."IMPORTE"
   FROM ((((((("InfUsuario"."CFDICOMPROBANTE" ta
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTEIMPUESTOSTRASLADOS" tg ON ((tg."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTERELACIONADOS" th ON ((th."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICONCEPTOS" ti ON ((ti."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WHERE (
        CASE
            WHEN ((ta."TIPODECOMPROBANTE" = 'E'::bpchar) AND (ta."METODOPAGO" = 'PUE'::bpchar) AND (ta."FORMAPAGO" = '30'::bpchar) AND (th."TIPORELACION" = '07'::bpchar) AND (ti."CLAVEPRODSERV" = '84111506'::bpchar) AND (tg."IMPUESTO" = '002'::bpchar)) THEN 1
            ELSE 0
        END = 1)
  WITH NO DATA;


ALTER TABLE "InfUsuario"."DET_IVA_ACREDITABLE_DISMINUCION_APLIC_ANTICIPOS" OWNER TO postgres;

--
-- TOC entry 317 (class 1259 OID 38725)
-- Name: DET_IVA_ACREDITABLE_DISMINUCION_NC; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."DET_IVA_ACREDITABLE_DISMINUCION_NC" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCRECEPTOR",
    ta."TIPODECOMPROBANTE",
    ta."METODOPAGO",
    ta."FORMAPAGO",
    th."TIPORELACION",
    tg."IMPUESTO",
    tg."IMPORTE"
   FROM (((((("InfUsuario"."CFDICOMPROBANTE" ta
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTEIMPUESTOSTRASLADOS" tg ON ((tg."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTERELACIONADOS" th ON ((th."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WHERE (
        CASE
            WHEN ((ta."TIPODECOMPROBANTE" = 'E'::bpchar) AND (ta."METODOPAGO" = 'PUE'::bpchar) AND (ta."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND (th."TIPORELACION" = '01'::bpchar) AND (tg."IMPUESTO" = '002'::bpchar)) THEN 1
            ELSE 0
        END = 1)
  WITH NO DATA;


ALTER TABLE "InfUsuario"."DET_IVA_ACREDITABLE_DISMINUCION_NC" OWNER TO postgres;

--
-- TOC entry 318 (class 1259 OID 38730)
-- Name: DET_IVA_ACREDITABLE_NOTAS_DEBITO; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."DET_IVA_ACREDITABLE_NOTAS_DEBITO" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCRECEPTOR",
    ta."TIPODECOMPROBANTE",
    ta."METODOPAGO",
    ta."FORMAPAGO",
    th."TIPORELACION",
    tg."IMPUESTO",
    tg."IMPORTE"
   FROM (((((("InfUsuario"."CFDICOMPROBANTE" ta
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTEIMPUESTOSTRASLADOS" tg ON ((tg."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTERELACIONADOS" th ON ((th."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WHERE (
        CASE
            WHEN ((ta."TIPODECOMPROBANTE" = 'E'::bpchar) AND (ta."METODOPAGO" = 'PUE'::bpchar) AND (ta."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND (th."TIPORELACION" = '02'::bpchar) AND (tg."IMPUESTO" = '002'::bpchar)) THEN 1
            ELSE 0
        END = 1)
  WITH NO DATA;


ALTER TABLE "InfUsuario"."DET_IVA_ACREDITABLE_NOTAS_DEBITO" OWNER TO postgres;

--
-- TOC entry 319 (class 1259 OID 38735)
-- Name: DET_IVA_ACREDITABLE_PAGOS_CONTADO; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."DET_IVA_ACREDITABLE_PAGOS_CONTADO" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCRECEPTOR",
    ta."TIPODECOMPROBANTE",
    ta."METODOPAGO",
    ta."FORMAPAGO",
    tf."CLAVEPRODSERV",
    tg."IMPUESTO",
    tg."IMPORTE"
   FROM (((((("InfUsuario"."CFDICOMPROBANTE" ta
     LEFT JOIN "InfUsuario"."CFDICONCEPTOS" tf ON ((tf."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" tg ON ((tg."ID_CONCEPTO" = tf."ID_CONCEPTO")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WHERE (
        CASE
            WHEN ((ta."TIPODECOMPROBANTE" = 'I'::bpchar) AND (ta."METODOPAGO" = 'PUE'::bpchar) AND (ta."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND (tf."CLAVEPRODSERV" <> '84111506'::bpchar) AND (tg."IMPUESTO" = '002'::bpchar)) THEN 1
            ELSE 0
        END = 1)
  WITH NO DATA;


ALTER TABLE "InfUsuario"."DET_IVA_ACREDITABLE_PAGOS_CONTADO" OWNER TO postgres;

--
-- TOC entry 320 (class 1259 OID 38740)
-- Name: DET_IVA_ACREDITABLE_PAGO_ANTICIPO; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."DET_IVA_ACREDITABLE_PAGO_ANTICIPO" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCRECEPTOR",
    ta."TIPODECOMPROBANTE",
    ta."METODOPAGO",
    ta."FORMAPAGO",
    tf."CLAVEPRODSERV",
    tg."IMPUESTO",
    tg."IMPORTE"
   FROM (((((("InfUsuario"."CFDICOMPROBANTE" ta
     LEFT JOIN "InfUsuario"."CFDICONCEPTOS" tf ON ((tf."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" tg ON ((tg."ID_CONCEPTO" = tf."ID_CONCEPTO")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WHERE (
        CASE
            WHEN ((ta."TIPODECOMPROBANTE" = 'I'::bpchar) AND (ta."METODOPAGO" = 'PUE'::bpchar) AND (ta."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND (tf."CLAVEPRODSERV" = '84111506'::bpchar) AND (tg."IMPUESTO" = '002'::bpchar)) THEN 1
            ELSE 0
        END = 1)
  WITH NO DATA;


ALTER TABLE "InfUsuario"."DET_IVA_ACREDITABLE_PAGO_ANTICIPO" OWNER TO postgres;

--
-- TOC entry 321 (class 1259 OID 38745)
-- Name: DET_IVA_TRASLADADO_ANTICIPOS; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."DET_IVA_TRASLADADO_ANTICIPOS" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCEMISOR",
    ta."TIPODECOMPROBANTE",
    ta."METODOPAGO",
    ta."FORMAPAGO",
    tf."CLAVEPRODSERV",
    tg."IMPUESTO",
    tg."IMPORTE"
   FROM (((((("InfUsuario"."CFDICOMPROBANTE" ta
     LEFT JOIN "InfUsuario"."CFDICONCEPTOS" tf ON ((tf."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" tg ON ((tg."ID_CONCEPTO" = tf."ID_CONCEPTO")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WHERE (
        CASE
            WHEN ((ta."TIPODECOMPROBANTE" = 'I'::bpchar) AND (ta."METODOPAGO" = 'PUE'::bpchar) AND (ta."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND (tf."CLAVEPRODSERV" = '84111506'::bpchar) AND (tg."IMPUESTO" = '002'::bpchar)) THEN 1
            ELSE 0
        END = 1)
  WITH NO DATA;


ALTER TABLE "InfUsuario"."DET_IVA_TRASLADADO_ANTICIPOS" OWNER TO postgres;

--
-- TOC entry 322 (class 1259 OID 38750)
-- Name: DET_IVA_TRASLADADO_APLIC_ANTICIPOS; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."DET_IVA_TRASLADADO_APLIC_ANTICIPOS" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCEMISOR",
    ta."TIPODECOMPROBANTE",
    ta."METODOPAGO",
    tf."TIPORELACION",
    tg."IMPUESTO",
    tg."IMPORTE"
   FROM (((((("InfUsuario"."CFDICOMPROBANTE" ta
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTERELACIONADOS" tf ON ((tf."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTEIMPUESTOSTRASLADOS" tg ON ((tg."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WHERE (
        CASE
            WHEN ((ta."TIPODECOMPROBANTE" = 'I'::bpchar) AND (ta."METODOPAGO" = 'PUE'::bpchar) AND (tf."TIPORELACION" = '07'::bpchar) AND (tg."IMPUESTO" = '002'::bpchar)) THEN 1
            ELSE 0
        END = 1)
  WITH NO DATA;


ALTER TABLE "InfUsuario"."DET_IVA_TRASLADADO_APLIC_ANTICIPOS" OWNER TO postgres;

--
-- TOC entry 323 (class 1259 OID 38755)
-- Name: DET_IVA_TRASLADADO_DEVOLUCIONES; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."DET_IVA_TRASLADADO_DEVOLUCIONES" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCEMISOR",
    ta."TIPODECOMPROBANTE",
    ta."METODOPAGO",
    ta."FORMAPAGO",
    th."TIPORELACION",
    tg."IMPUESTO",
    tg."IMPORTE"
   FROM (((((("InfUsuario"."CFDICOMPROBANTE" ta
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTEIMPUESTOSTRASLADOS" tg ON ((tg."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTERELACIONADOS" th ON ((th."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WHERE (
        CASE
            WHEN ((ta."TIPODECOMPROBANTE" = 'E'::bpchar) AND (ta."METODOPAGO" = 'PUE'::bpchar) AND (ta."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND (th."TIPORELACION" = '03'::bpchar) AND (tg."IMPUESTO" = '002'::bpchar)) THEN 1
            ELSE 0
        END = 1)
  WITH NO DATA;


ALTER TABLE "InfUsuario"."DET_IVA_TRASLADADO_DEVOLUCIONES" OWNER TO postgres;

--
-- TOC entry 324 (class 1259 OID 38760)
-- Name: DET_IVA_TRASLADADO_EGRESO_APLIC_ANTICIPOS; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."DET_IVA_TRASLADADO_EGRESO_APLIC_ANTICIPOS" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCEMISOR",
    ta."TIPODECOMPROBANTE",
    ta."METODOPAGO",
    ta."FORMAPAGO",
    th."TIPORELACION",
    ti."CLAVEPRODSERV",
    tg."IMPUESTO",
    tg."IMPORTE"
   FROM ((((((("InfUsuario"."CFDICOMPROBANTE" ta
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTEIMPUESTOSTRASLADOS" tg ON ((tg."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTERELACIONADOS" th ON ((th."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICONCEPTOS" ti ON ((ti."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WHERE (
        CASE
            WHEN ((ta."TIPODECOMPROBANTE" = 'E'::bpchar) AND (ta."METODOPAGO" = 'PUE'::bpchar) AND (ta."FORMAPAGO" = '30'::bpchar) AND (th."TIPORELACION" = '07'::bpchar) AND (ti."CLAVEPRODSERV" = '84111506'::bpchar) AND (tg."IMPUESTO" = '002'::bpchar)) THEN 1
            ELSE 0
        END = 1)
  WITH NO DATA;


ALTER TABLE "InfUsuario"."DET_IVA_TRASLADADO_EGRESO_APLIC_ANTICIPOS" OWNER TO postgres;

--
-- TOC entry 325 (class 1259 OID 38765)
-- Name: DET_IVA_TRASLADADO_EGRESO_DESCUENTOS_NC; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."DET_IVA_TRASLADADO_EGRESO_DESCUENTOS_NC" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCEMISOR",
    ta."TIPODECOMPROBANTE",
    ta."METODOPAGO",
    ta."FORMAPAGO",
    th."TIPORELACION",
    tg."IMPUESTO",
    tg."IMPORTE"
   FROM (((((("InfUsuario"."CFDICOMPROBANTE" ta
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTEIMPUESTOSTRASLADOS" tg ON ((tg."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTERELACIONADOS" th ON ((th."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WHERE (
        CASE
            WHEN ((ta."TIPODECOMPROBANTE" = 'E'::bpchar) AND (ta."METODOPAGO" = 'PUE'::bpchar) AND (ta."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND (th."TIPORELACION" = '01'::bpchar) AND (tg."IMPUESTO" = '002'::bpchar)) THEN 1
            ELSE 0
        END = 1)
  WITH NO DATA;


ALTER TABLE "InfUsuario"."DET_IVA_TRASLADADO_EGRESO_DESCUENTOS_NC" OWNER TO postgres;

--
-- TOC entry 326 (class 1259 OID 38770)
-- Name: DET_IVA_TRASLADADO_NOTAS_DEBITO; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."DET_IVA_TRASLADADO_NOTAS_DEBITO" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCEMISOR",
    ta."TIPODECOMPROBANTE",
    ta."METODOPAGO",
    ta."FORMAPAGO",
    th."TIPORELACION",
    tg."IMPUESTO",
    tg."IMPORTE"
   FROM (((((("InfUsuario"."CFDICOMPROBANTE" ta
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTEIMPUESTOSTRASLADOS" tg ON ((tg."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICOMPROBANTERELACIONADOS" th ON ((th."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WHERE (
        CASE
            WHEN ((ta."TIPODECOMPROBANTE" = 'E'::bpchar) AND (ta."METODOPAGO" = 'PUE'::bpchar) AND (ta."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND (th."TIPORELACION" = '02'::bpchar) AND (tg."IMPUESTO" = '002'::bpchar)) THEN 1
            ELSE 0
        END = 1)
  WITH NO DATA;


ALTER TABLE "InfUsuario"."DET_IVA_TRASLADADO_NOTAS_DEBITO" OWNER TO postgres;

--
-- TOC entry 327 (class 1259 OID 38775)
-- Name: DET_IVA_TRASLADADO_VTAS_CONTADO; Type: MATERIALIZED VIEW; Schema: InfUsuario; Owner: postgres
--

CREATE MATERIALIZED VIEW "InfUsuario"."DET_IVA_TRASLADADO_VTAS_CONTADO" AS
 SELECT te."RFC" AS "RFC_CLTE",
    td."RFC" AS "RFC_ASOC",
    ta."RFCEMISOR",
    ta."TIPODECOMPROBANTE",
    ta."METODOPAGO",
    ta."FORMAPAGO",
    tf."CLAVEPRODSERV",
    tg."IMPUESTO",
    tg."IMPORTE"
   FROM (((((("InfUsuario"."CFDICOMPROBANTE" ta
     LEFT JOIN "InfUsuario"."CFDICONCEPTOS" tf ON ((tf."ID_COMPROBANTE" = ta."ID_COMPROBANTE")))
     LEFT JOIN "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" tg ON ((tg."ID_CONCEPTO" = tf."ID_CONCEPTO")))
     LEFT JOIN "InfUsuario"."CFDITOTAL" tb ON ((tb."ID_CFDI" = ta."ID_CFDI")))
     LEFT JOIN "BaseSistema"."LOGDESCARGAFILE" tc ON ((tc."CVE_DESCARGA" = tb."CVE_DESCARGA")))
     LEFT JOIN "BaseSistema"."CFGCLTESRFC" td ON ((td."ID_RFC" = tc."ID_RFC")))
     LEFT JOIN "BaseSistema"."CFGCLTES" te ON ((te."ID_CLTE" = td."ID_CLTE")))
  WHERE (
        CASE
            WHEN ((ta."TIPODECOMPROBANTE" = 'I'::bpchar) AND (ta."METODOPAGO" = 'PUE'::bpchar) AND (ta."FORMAPAGO" = ANY (ARRAY['01'::bpchar, '02'::bpchar, '03'::bpchar, '04'::bpchar, '05'::bpchar, '06'::bpchar, '08'::bpchar, '28'::bpchar, '29'::bpchar])) AND (tf."CLAVEPRODSERV" <> '84111506'::bpchar) AND (tg."IMPUESTO" = '002'::bpchar)) THEN 1
            ELSE 0
        END = 1)
  WITH NO DATA;


ALTER TABLE "InfUsuario"."DET_IVA_TRASLADADO_VTAS_CONTADO" OWNER TO postgres;

--
-- TOC entry 328 (class 1259 OID 38780)
-- Name: INF32D; Type: TABLE; Schema: InfUsuario; Owner: postgres
--

CREATE TABLE "InfUsuario"."INF32D" (
    "ID_INF" integer NOT NULL,
    "RFC" character(13),
    "RAZON_SOC" character(255)
);


ALTER TABLE "InfUsuario"."INF32D" OWNER TO postgres;

--
-- TOC entry 3378 (class 2604 OID 38897)
-- Name: CATACCIONES ID_ACCION; Type: DEFAULT; Schema: BaseSistema; Owner: postgres
--

ALTER TABLE ONLY "BaseSistema"."CATACCIONES" ALTER COLUMN "ID_ACCION" SET DEFAULT nextval('"BaseSistema"."CATACCIONES_ID_ACCION_seq"'::regclass);


--
-- TOC entry 3381 (class 2604 OID 38898)
-- Name: CATSTATUS ID_STATUS; Type: DEFAULT; Schema: BaseSistema; Owner: postgres
--

ALTER TABLE ONLY "BaseSistema"."CATSTATUS" ALTER COLUMN "ID_STATUS" SET DEFAULT nextval('"BaseSistema"."CATSTATUS_ID_STATUS_seq"'::regclass);


--
-- TOC entry 3387 (class 2604 OID 38900)
-- Name: LOGDESCARGAFILE ID_DESCARGA; Type: DEFAULT; Schema: BaseSistema; Owner: postgres
--

ALTER TABLE ONLY "BaseSistema"."LOGDESCARGAFILE" ALTER COLUMN "ID_DESCARGA" SET DEFAULT nextval('"BaseSistema"."CFGFILEUNLOADS_ID_UNLOAD_seq"'::regclass);


--
-- TOC entry 3442 (class 2604 OID 38902)
-- Name: CFDICOMPROBANTERELACIONADOS ID_RELACIONADOS; Type: DEFAULT; Schema: InfUsuario; Owner: postgres
--

ALTER TABLE ONLY "InfUsuario"."CFDICOMPROBANTERELACIONADOS" ALTER COLUMN "ID_RELACIONADOS" SET DEFAULT nextval('"InfUsuario"."CFDIRELACIONADOS_ID_RELACIONADOS_seq"'::regclass);


--
-- TOC entry 3444 (class 2604 OID 38903)
-- Name: CFDICONCEPTOSIMPUESTOSRETENCIONES ID_RETENCION; Type: DEFAULT; Schema: InfUsuario; Owner: postgres
--

ALTER TABLE ONLY "InfUsuario"."CFDICONCEPTOSIMPUESTOSRETENCIONES" ALTER COLUMN "ID_RETENCION" SET DEFAULT nextval('"InfUsuario"."CFDIRETENCIONES_ID_RETENCION_seq"'::regclass);


--
-- TOC entry 3445 (class 2604 OID 38904)
-- Name: CFDICONCEPTOSIMPUESTOSTRASLADOS ID_IMPUESTO; Type: DEFAULT; Schema: InfUsuario; Owner: postgres
--

ALTER TABLE ONLY "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS" ALTER COLUMN "ID_IMPUESTO" SET DEFAULT nextval('"InfUsuario"."CFDIIMPUESTOS_ID_IMPUESTO_seq"'::regclass);


--
-- TOC entry 3447 (class 2604 OID 38905)
-- Name: CFDITOTAL ID_CFDI; Type: DEFAULT; Schema: InfUsuario; Owner: postgres
--

ALTER TABLE ONLY "InfUsuario"."CFDITOTAL" ALTER COLUMN "ID_CFDI" SET DEFAULT nextval('"InfUsuario"."CFDITOTAL_ID_CFDI_seq"'::regclass);


--
-- TOC entry 3593 (class 0 OID 38285)
-- Dependencies: 213
-- Data for Name: CATACCIONES; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--

INSERT INTO "BaseSistema"."CATACCIONES" VALUES (1, 'SOLICITA                 ');
INSERT INTO "BaseSistema"."CATACCIONES" VALUES (2, 'VALIDA                   ');
INSERT INTO "BaseSistema"."CATACCIONES" VALUES (3, 'DESCARGA                 ');
INSERT INTO "BaseSistema"."CATACCIONES" VALUES (4, 'CARGA                    ');
INSERT INTO "BaseSistema"."CATACCIONES" VALUES (5, 'TERMINA                  ');
INSERT INTO "BaseSistema"."CATACCIONES" VALUES (6, 'AUTORIZA                 ');


--
-- TOC entry 3596 (class 0 OID 38292)
-- Dependencies: 216
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


--
-- TOC entry 3598 (class 0 OID 38298)
-- Dependencies: 218
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
-- TOC entry 3599 (class 0 OID 38302)
-- Dependencies: 219
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


--
-- TOC entry 3603 (class 0 OID 38311)
-- Dependencies: 223
-- Data for Name: CFGCLTES; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3705 (class 0 OID 45434)
-- Dependencies: 330
-- Data for Name: CFGCLTESCREDENCIALES; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3604 (class 0 OID 38326)
-- Dependencies: 224
-- Data for Name: CFGCLTESREPOSITORIOS; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--

INSERT INTO "BaseSistema"."CFGCLTESREPOSITORIOS" VALUES (2, 'InfUsuario     ', 'Informacion del Usuario                                                                                                                               ', '2019-09-05 16:11:58.939296', NULL, 0, NULL, 1);


--
-- TOC entry 3606 (class 0 OID 38332)
-- Dependencies: 226
-- Data for Name: CFGCLTESRFC; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3608 (class 0 OID 38338)
-- Dependencies: 228
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
-- TOC entry 3610 (class 0 OID 38347)
-- Dependencies: 230
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
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (4, 'supuesto                                                                                            ', '"SUPUESTO" character(20) COLLATE pg_catalog."default"                                               ', NULL, NULL, NULL, NULL, 12, '"SUPUESTO"                                                                                          ', 'TRIM(BOTH FROM "SUPUESTO") AS "SUPUESTO"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (5, 'fechas de primera publicacion                                                                       ', '"FH_PRIM_PUB" character(30) COLLATE pg_catalog."default"                                            ', NULL, NULL, NULL, NULL, 12, '"FH_PRIM_PUB"                                                                                       ', 'to_date("FH_PRIM_PUB",''DD/MM/YYYY'') AS "FH_PRIM_PUB"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (6, 'monto                                                                                               ', '"MNTO" character(30) COLLATE pg_catalog."default"                                                   ', NULL, NULL, NULL, NULL, 12, '"MNTO"                                                                                              ', '"MNTO"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (7, 'fecha de publicación (con monto de acuerdo a la ley de transparencia                                ', '"FH_PUB" character(30) COLLATE pg_catalog."default"                                                 ', NULL, NULL, NULL, NULL, 12, '"FH_PUB"                                                                                            ', 'to_date("FH_PUB",''DD/MM/YYYY'') as "FH_PUB"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (12, 'no                                                                                                  ', '"NO" character(70) COLLATE pg_catalog."default"                                                     ', NULL, NULL, NULL, NULL, 12, '"NO"                                                                                                ', 'TO_NUMBER("NO",''999999999'') AS "NO"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (13, 'nombre del contribuyente                                                                            ', '"NAME_CONTR" character(500) COLLATE pg_catalog."default"                                            ', NULL, NULL, NULL, NULL, 12, '"NAME_CONTR"                                                                                        ', 'TRIM(BOTH FROM "NAME_CONTR") AS "NAME_CONTR"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (16, 'publicación página sat presuntos                                                                    ', '"FH_PUB_PRESUN_SAT" character(150) COLLATE pg_catalog."default"                                     ', NULL, NULL, NULL, NULL, 12, '"FH_PUB_PRESUN_SAT"                                                                                 ', 'to_date("FH_PUB_PRESUN_SAT", ''DD/MM/YYYY'') AS "FH_PUB_PRESUN_SAT"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (17, 'número y fecha de oficio global de presunción.1                                                     ', '"FH_OFIC_GLO_PRESUN_DOF" character(150) COLLATE pg_catalog."default"                                ', NULL, NULL, NULL, NULL, 12, '"FH_OFIC_GLO_PRESUN_DOF"                                                                            ', 'TRIM(BOTH FROM "FH_OFIC_GLO_PRESUN_DOF") AS "FH_OFIC_GLO_PRESUN_DOF"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    ');
INSERT INTO "BaseSistema"."CFGFILECOLUMNS" VALUES (18, 'publicación dof presuntos                                                                           ', '"FH_PUB_PRESUN_DOF" character(150) COLLATE pg_catalog."default"                                     ', NULL, NULL, NULL, NULL, 12, '"FH_PUB_PRESUN_DOF"                                                                                 ', 'to_date("FH_PUB_PRESUN_DOF", ''DD/MM/YYYY'') AS "FH_PUB_PRESUN_DOF"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ');
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
-- TOC entry 3613 (class 0 OID 38356)
-- Dependencies: 233
-- Data for Name: INF69; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3614 (class 0 OID 38359)
-- Dependencies: 234
-- Data for Name: INF69B; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3611 (class 0 OID 38351)
-- Dependencies: 231
-- Data for Name: LOGDESCARGAFILE; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3707 (class 0 OID 45499)
-- Dependencies: 332
-- Data for Name: LOGDESCARGAWSAUTH; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3709 (class 0 OID 45529)
-- Dependencies: 334
-- Data for Name: LOGDESCARGAWSPROCESO; Type: TABLE DATA; Schema: BaseSistema; Owner: postgres
--



--
-- TOC entry 3620 (class 0 OID 38401)
-- Dependencies: 243
-- Data for Name: INF69B_y2019m09; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3621 (class 0 OID 38408)
-- Dependencies: 244
-- Data for Name: INF69B_y2019m10; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3622 (class 0 OID 38415)
-- Dependencies: 245
-- Data for Name: INF69B_y2019m11; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3623 (class 0 OID 38422)
-- Dependencies: 246
-- Data for Name: INF69B_y2019m12; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3624 (class 0 OID 38429)
-- Dependencies: 247
-- Data for Name: INF69B_y2020m01; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3625 (class 0 OID 38436)
-- Dependencies: 248
-- Data for Name: INF69B_y2020m02; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3626 (class 0 OID 38443)
-- Dependencies: 249
-- Data for Name: INF69B_y2020m03; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3627 (class 0 OID 38450)
-- Dependencies: 250
-- Data for Name: INF69B_y2020m04; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3628 (class 0 OID 38457)
-- Dependencies: 251
-- Data for Name: INF69B_y2020m05; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3629 (class 0 OID 38464)
-- Dependencies: 252
-- Data for Name: INF69B_y2020m06; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3630 (class 0 OID 38471)
-- Dependencies: 253
-- Data for Name: INF69B_y2020m07; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3631 (class 0 OID 38478)
-- Dependencies: 254
-- Data for Name: INF69B_y2020m08; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3632 (class 0 OID 38485)
-- Dependencies: 255
-- Data for Name: INF69_y2019m09; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3633 (class 0 OID 38489)
-- Dependencies: 256
-- Data for Name: INF69_y2019m10; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3634 (class 0 OID 38493)
-- Dependencies: 257
-- Data for Name: INF69_y2019m11; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3635 (class 0 OID 38497)
-- Dependencies: 258
-- Data for Name: INF69_y2019m12; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3636 (class 0 OID 38501)
-- Dependencies: 259
-- Data for Name: INF69_y2020m01; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3637 (class 0 OID 38505)
-- Dependencies: 260
-- Data for Name: INF69_y2020m02; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3638 (class 0 OID 38509)
-- Dependencies: 261
-- Data for Name: INF69_y2020m03; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3639 (class 0 OID 38513)
-- Dependencies: 262
-- Data for Name: INF69_y2020m04; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3640 (class 0 OID 38517)
-- Dependencies: 263
-- Data for Name: INF69_y2020m05; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3641 (class 0 OID 38521)
-- Dependencies: 264
-- Data for Name: INF69_y2020m06; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3642 (class 0 OID 38525)
-- Dependencies: 265
-- Data for Name: INF69_y2020m07; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3643 (class 0 OID 38529)
-- Dependencies: 266
-- Data for Name: INF69_y2020m08; Type: TABLE DATA; Schema: BaseSistemaHistorico; Owner: postgres
--



--
-- TOC entry 3645 (class 0 OID 38539)
-- Dependencies: 269
-- Data for Name: INF32D_y2019m09; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3646 (class 0 OID 38543)
-- Dependencies: 270
-- Data for Name: INF32D_y2019m10; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3647 (class 0 OID 38547)
-- Dependencies: 271
-- Data for Name: INF32D_y2019m11; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3648 (class 0 OID 38551)
-- Dependencies: 272
-- Data for Name: INF32D_y2019m12; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3649 (class 0 OID 38555)
-- Dependencies: 273
-- Data for Name: INF32D_y2020m01; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3650 (class 0 OID 38559)
-- Dependencies: 274
-- Data for Name: INF32D_y2020m02; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3651 (class 0 OID 38563)
-- Dependencies: 275
-- Data for Name: INF32D_y2020m03; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3652 (class 0 OID 38567)
-- Dependencies: 276
-- Data for Name: INF32D_y2020m04; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3653 (class 0 OID 38571)
-- Dependencies: 277
-- Data for Name: INF32D_y2020m05; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3654 (class 0 OID 38575)
-- Dependencies: 278
-- Data for Name: INF32D_y2020m06; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3655 (class 0 OID 38579)
-- Dependencies: 279
-- Data for Name: INF32D_y2020m07; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3656 (class 0 OID 38583)
-- Dependencies: 280
-- Data for Name: INF32D_y2020m08; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3658 (class 0 OID 38593)
-- Dependencies: 283
-- Data for Name: INFMETA_y2019m09; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3659 (class 0 OID 38597)
-- Dependencies: 284
-- Data for Name: INFMETA_y2019m10; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3660 (class 0 OID 38601)
-- Dependencies: 285
-- Data for Name: INFMETA_y2019m11; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3661 (class 0 OID 38605)
-- Dependencies: 286
-- Data for Name: INFMETA_y2019m12; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3662 (class 0 OID 38609)
-- Dependencies: 287
-- Data for Name: INFMETA_y2020m01; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3663 (class 0 OID 38613)
-- Dependencies: 288
-- Data for Name: INFMETA_y2020m02; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3664 (class 0 OID 38617)
-- Dependencies: 289
-- Data for Name: INFMETA_y2020m03; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3665 (class 0 OID 38621)
-- Dependencies: 290
-- Data for Name: INFMETA_y2020m04; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3666 (class 0 OID 38625)
-- Dependencies: 291
-- Data for Name: INFMETA_y2020m05; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3667 (class 0 OID 38629)
-- Dependencies: 292
-- Data for Name: INFMETA_y2020m06; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3668 (class 0 OID 38633)
-- Dependencies: 293
-- Data for Name: INFMETA_y2020m07; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3669 (class 0 OID 38637)
-- Dependencies: 294
-- Data for Name: INFMETA_y2020m08; Type: TABLE DATA; Schema: InfHistorica; Owner: postgres
--



--
-- TOC entry 3673 (class 0 OID 38651)
-- Dependencies: 298
-- Data for Name: CFDICOMPROBANTE; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3713 (class 0 OID 47143)
-- Dependencies: 338
-- Data for Name: CFDICOMPROBANTECOMPLEMENTO; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3711 (class 0 OID 47137)
-- Dependencies: 336
-- Data for Name: CFDICOMPROBANTEIMPUESTOSRETENIDOS; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3675 (class 0 OID 38660)
-- Dependencies: 300
-- Data for Name: CFDICOMPROBANTEIMPUESTOSTRASLADOS; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3676 (class 0 OID 38664)
-- Dependencies: 301
-- Data for Name: CFDICOMPROBANTERELACIONADOS; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3678 (class 0 OID 38669)
-- Dependencies: 303
-- Data for Name: CFDICONCEPTOS; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3679 (class 0 OID 38676)
-- Dependencies: 304
-- Data for Name: CFDICONCEPTOSIMPUESTOSRETENCIONES; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3680 (class 0 OID 38679)
-- Dependencies: 305
-- Data for Name: CFDICONCEPTOSIMPUESTOSTRASLADOS; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3682 (class 0 OID 38684)
-- Dependencies: 307
-- Data for Name: CFDICONCEPTOSPARTES; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3686 (class 0 OID 38697)
-- Dependencies: 311
-- Data for Name: CFDITOTAL; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3703 (class 0 OID 38780)
-- Dependencies: 328
-- Data for Name: INF32D; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3670 (class 0 OID 38641)
-- Dependencies: 295
-- Data for Name: INFMETA; Type: TABLE DATA; Schema: InfUsuario; Owner: postgres
--



--
-- TOC entry 3728 (class 0 OID 0)
-- Dependencies: 214
-- Name: CATACCIONES_ID_ACCION_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CATACCIONES_ID_ACCION_seq"', 1, true);


--
-- TOC entry 3729 (class 0 OID 0)
-- Dependencies: 217
-- Name: CATPROCESOSSTATUS_ID_STATUS_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CATPROCESOSSTATUS_ID_STATUS_seq"', 1, false);


--
-- TOC entry 3730 (class 0 OID 0)
-- Dependencies: 215
-- Name: CATPROCESOS_ID_PROCESO_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CATPROCESOS_ID_PROCESO_seq"', 1, false);


--
-- TOC entry 3731 (class 0 OID 0)
-- Dependencies: 220
-- Name: CATSTATUS_ID_STATUS_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CATSTATUS_ID_STATUS_seq"', 1, true);


--
-- TOC entry 3732 (class 0 OID 0)
-- Dependencies: 221
-- Name: CFGALMACEN_ID_ALMACEN_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CFGALMACEN_ID_ALMACEN_seq"', 1, false);


--
-- TOC entry 3733 (class 0 OID 0)
-- Dependencies: 329
-- Name: CFGCLTESCREDENCIALES_ID_CRED_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CFGCLTESCREDENCIALES_ID_CRED_seq"', 1, true);


--
-- TOC entry 3734 (class 0 OID 0)
-- Dependencies: 229
-- Name: CFGFILECOLUMNS_ID_COLUMN_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CFGFILECOLUMNS_ID_COLUMN_seq"', 1, false);


--
-- TOC entry 3735 (class 0 OID 0)
-- Dependencies: 232
-- Name: CFGFILEUNLOADS_ID_UNLOAD_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CFGFILEUNLOADS_ID_UNLOAD_seq"', 207, true);


--
-- TOC entry 3736 (class 0 OID 0)
-- Dependencies: 227
-- Name: CFGFILE_ID_FILE_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CFGFILE_ID_FILE_seq"', 1, false);


--
-- TOC entry 3737 (class 0 OID 0)
-- Dependencies: 222
-- Name: CLTES_ID_CLTE_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."CLTES_ID_CLTE_seq"', 1, false);


--
-- TOC entry 3738 (class 0 OID 0)
-- Dependencies: 331
-- Name: LOGDESCARGAWSCABECERA_ID_DESCARGA_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."LOGDESCARGAWSCABECERA_ID_DESCARGA_seq"', 3, true);


--
-- TOC entry 3739 (class 0 OID 0)
-- Dependencies: 333
-- Name: LOGDESCARGAWSPROCESO_ID_DESCARGA_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."LOGDESCARGAWSPROCESO_ID_DESCARGA_seq"', 7, true);


--
-- TOC entry 3740 (class 0 OID 0)
-- Dependencies: 225
-- Name: RFCS_ID_RFC_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."RFCS_ID_RFC_seq"', 1, false);


--
-- TOC entry 3741 (class 0 OID 0)
-- Dependencies: 238
-- Name: USRSIST_ID_USR_seq; Type: SEQUENCE SET; Schema: BaseSistema; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistema"."USRSIST_ID_USR_seq"', 1, false);


--
-- TOC entry 3742 (class 0 OID 0)
-- Dependencies: 241
-- Name: INF69B_ID_INF_seq; Type: SEQUENCE SET; Schema: BaseSistemaHistorico; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistemaHistorico"."INF69B_ID_INF_seq"', 10602, true);


--
-- TOC entry 3743 (class 0 OID 0)
-- Dependencies: 239
-- Name: INF69_ID_INF_seq; Type: SEQUENCE SET; Schema: BaseSistemaHistorico; Owner: postgres
--

SELECT pg_catalog.setval('"BaseSistemaHistorico"."INF69_ID_INF_seq"', 468728, true);


--
-- TOC entry 3744 (class 0 OID 0)
-- Dependencies: 267
-- Name: INF32D_ID_INF_seq; Type: SEQUENCE SET; Schema: InfHistorica; Owner: postgres
--

SELECT pg_catalog.setval('"InfHistorica"."INF32D_ID_INF_seq"', 1, false);


--
-- TOC entry 3745 (class 0 OID 0)
-- Dependencies: 281
-- Name: INFMETA_ID_INF_seq; Type: SEQUENCE SET; Schema: InfHistorica; Owner: postgres
--

SELECT pg_catalog.setval('"InfHistorica"."INFMETA_ID_INF_seq"', 2, true);


--
-- TOC entry 3746 (class 0 OID 0)
-- Dependencies: 337
-- Name: CFDICOMPLEMENTOS_ID_COMPLEMENTO_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDICOMPLEMENTOS_ID_COMPLEMENTO_seq"', 3, true);


--
-- TOC entry 3747 (class 0 OID 0)
-- Dependencies: 297
-- Name: CFDICOMPROBANTE_ID_COMPROBANTE_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDICOMPROBANTE_ID_COMPROBANTE_seq"', 13, true);


--
-- TOC entry 3748 (class 0 OID 0)
-- Dependencies: 302
-- Name: CFDICONCEPTOS_ID_CONCEPTO_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDICONCEPTOS_ID_CONCEPTO_seq"', 6, true);


--
-- TOC entry 3749 (class 0 OID 0)
-- Dependencies: 308
-- Name: CFDIIMPUESTOS_ID_IMPUESTO_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDIIMPUESTOS_ID_IMPUESTO_seq"', 1, false);


--
-- TOC entry 3750 (class 0 OID 0)
-- Dependencies: 306
-- Name: CFDIPARTES_ID_PARTE_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDIPARTES_ID_PARTE_seq"', 1, false);


--
-- TOC entry 3751 (class 0 OID 0)
-- Dependencies: 309
-- Name: CFDIRELACIONADOS_ID_RELACIONADOS_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDIRELACIONADOS_ID_RELACIONADOS_seq"', 1, false);


--
-- TOC entry 3752 (class 0 OID 0)
-- Dependencies: 310
-- Name: CFDIRETENCIONES_ID_RETENCION_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDIRETENCIONES_ID_RETENCION_seq"', 5, true);


--
-- TOC entry 3753 (class 0 OID 0)
-- Dependencies: 335
-- Name: CFDIRETENIDOS_ID_RETENIDO_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDIRETENIDOS_ID_RETENIDO_seq"', 5, true);


--
-- TOC entry 3754 (class 0 OID 0)
-- Dependencies: 312
-- Name: CFDITOTAL_ID_CFDI_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDITOTAL_ID_CFDI_seq"', 1, false);


--
-- TOC entry 3755 (class 0 OID 0)
-- Dependencies: 299
-- Name: CFDITRASLADOS_ID_TRASLADO_seq; Type: SEQUENCE SET; Schema: InfUsuario; Owner: postgres
--

SELECT pg_catalog.setval('"InfUsuario"."CFDITRASLADOS_ID_TRASLADO_seq"', 1, false);


-- Completed on 2019-10-09 09:21:21 CDT

--
-- PostgreSQL database dump complete
--

