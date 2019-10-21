#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os.path
import datetime
import os
import psycopg2
import pandas as pd
from psycopg2 import Error
from time import localtime, strftime

def AbrirConexionPostgresql():
    try:
        connection = psycopg2.connect(user = "postgres",
                                    password = "SaraDan1",
                                    host = "127.0.0.1",
                                    port = "5432",
                                    database = "BaseGrit")

    except (Exception, psycopg2.Error) as error :
        print ("Error de conexión a PostgreSQL", error)

    finally:
        return connection

def CerrarConexionPostgresql(connection, cve_descarga):
    if(connection):

        cursor = connection.cursor()
        consulta = ""
        consulta = "CALL \"BaseSistema\".\"CopiaINFO69y69B\"('" + cve_descarga + "');"
        print("**** MATERIALIZANDO 69 Y 69B ***")
        cursor.execute(consulta)
        connection.commit()
        cursor.close()
        
        connection.close()
        return True

def main(argv):
    conexion = AbrirConexionPostgresql()

    Ruta = os.getcwd()
    Archivos = os.listdir(Ruta)

    print("**** CARGANDO ARCHIVOS ***")
    print(strftime("%a, %d %b %Y %H:%M:%S", localtime()))


    CVE_DESCARGA = strftime("%Y%m%d%H%M%S", localtime())
    print("CARGA:",CVE_DESCARGA)

    for file in Archivos:
        Archivo = file
        
        if Archivo.endswith('.csv') == True:
            
            cursor = conexion.cursor()
            consulta = ""
            consulta = "SELECT \"ID_FILE\", TRIM(BOTH FROM \"TEMPORAL\" ) AS \"TEMPORAL\", \"TYP_FILE\" FROM \"BaseSistema\".\"CFGFILE\" WHERE \"FILE_NAME\" = '" + Archivo + "' AND \"STATUS\" = 10;"
            cursor.execute(consulta)
            RESULTADOS = cursor.fetchall()
            cursor.close()

            for row in RESULTADOS:

                RESULT = row
                ahora = strftime("%c")
                strtablatemp = RESULT[1]

                cursor = conexion.cursor()
                consulta = ""
                consulta = "INSERT INTO \"BaseSistema\".\"LOGDESCARGAFILE\"(\"CVE_DESCARGA\", \"FH_DESCARGA\", \"FH_PUB\", \"ID_FILE\", \"ID_RFC\", \"STATUS\")"
                consulta = consulta + " VALUES(%s,%s,%s,%s,%s,%s)"
                valores = (CVE_DESCARGA, ahora, ahora, RESULT[0], 0, 21)
                cursor.execute(consulta, valores)
                conexion.commit()
                count = cursor.rowcount
                cursor.close()
                
                if count > 0:
                    print("**** PROCESANDO ARCHIVO ***", Archivo)
                    
                    tipo = RESULT[2]
                    tipo = tipo.strip()
                    consulta = ""

                    print("**** OBTENIENDO ESTRUCTURAS TEMPORALES ***")

                    if str(tipo) == "69":
                        df = pd.read_csv(Archivo)
                    if str(tipo) == "69B":
                        df = pd.read_csv(Archivo, header=2)

                    df.columns = [c.lower() for c in df.columns]
                    strcampostabla = ""
                    strcamposinsercion = ""
                    strvalorinsercion = ""
                    for column in df.columns:
                        cursor = conexion.cursor()        
                        consulta =  "SELECT TRIM(BOTH FROM \"CAMPO\" ) AS CAMPO, TRIM(BOTH FROM \"REG\") AS REG, TRIM(BOTH FROM \"VALOR\") AS VALOR FROM \"BaseSistema\".\"CFGFILECOLUMNS\" WHERE \"COLUMNA\" = '" + str(column) + "' AND \"STATUS\" = 12"
                        cursor.execute(consulta)
                        RESULTADOS2 = cursor.fetchall()
                        cursor.close()

                        for row in RESULTADOS2:
                            strcampo = row[0]
                            strcampoins = row[1]
                            strvalorins = row[2]
                            if strcampo == None:
                                print("NO HAY COINCIDENCIAS EN LA ESTRUCTURA, VALIDE DE NUEVO")
                                sys.exit()
                                return
                            else:
                                strcampostabla = strcampostabla + str(strcampo) + ', '
                                if strcampoins != None:
                                    strcamposinsercion = strcamposinsercion + str(strcampoins) + ', '
                                    strvalorinsercion = strvalorinsercion + str(strvalorins) + ', '

                    print("**** LIMPIANDO TEMPORAL ***")
                    consulta = ""
                    cursor = conexion.cursor()
                    consulta = "DROP TABLE IF EXISTS \"BaseSistema\".\"" + str(strtablatemp) + "\""
                    # print(consulta)
                    # print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
                    # return
                    cursor.execute(consulta)
                    cursor.close()

                    print("**** CREANDO TEMPORAL ***")
                    consulta = ""
                    cursor = conexion.cursor()
                    consulta = "CREATE TABLE \"BaseSistema\".\"" + str(strtablatemp) + "\" ( "
                    consulta = consulta + strcampostabla[0:-2]
                    consulta = consulta + " )"
                    # print(consulta)
                    # print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
                    # return
                    cursor.execute(consulta)
                    cursor.close()

                    print("**** IMPORTANDO DATOS ***")
                    consulta = ""
                    cursor = conexion.cursor()
                    fullpath = Ruta + "/" + Archivo 
                    consulta = "COPY \"BaseSistema\".\"" + str(strtablatemp) + "\" from '" + fullpath + "' delimiter ',' csv header"
                    # print(consulta)
                    # print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
                    # return
                    cursor.execute(consulta)
                    cursor.close()

                    print("**** RESPALDANDO CONTENIDO ***")
                    
                    if str(tipo) == "69":
                        if str(Archivo) == "Condonadosart146BCFF.csv":
                            consulta = ""
                            cursor = conexion.cursor()
                            consulta = "UPDATE \"BaseSistema\".\"" + str(strtablatemp) + "\" SET \"SUPUESTO\" = 'CONDONADO CONCURSO MERCANTIL' "
                            consulta = consulta + "WHERE TRIM(\"SUPUESTO\") = 'CONDONADOS' "
                            # print(consulta)
                            # print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
                            # return
                            cursor.execute(consulta)
                            cursor.close()

                            consulta = ""
                            cursor = conexion.cursor()
                            strcamposinsercion = strcamposinsercion + "\"CVE_DESCARGA\", \"FH_HIST\", \"AGRUPACION\", \"SELECCION\""
                            strvalorinsercion = strvalorinsercion + "'" + CVE_DESCARGA + "' AS \"CVE_DESCARGA\", "
                            strvalorinsercion = strvalorinsercion + "NOW() AS \"FH_HIST\", "
                            strvalorinsercion = strvalorinsercion + "CASE WHEN \"SUPUESTO\" = 'NO LOCALIZADOS' THEN 'NO LOCALIZADO' WHEN \"SUPUESTO\" = 'SENTENCIAS' THEN 'DELITO FISCAL' ELSE \"SUPUESTO\" END AS \"AGRUPACION\", "
                            strvalorinsercion = strvalorinsercion + "CASE WHEN \"SUPUESTO\" = 'NO LOCALIZADOS' THEN 1 WHEN \"SUPUESTO\" = 'SENTENCIAS' THEN 2 WHEN \"SUPUESTO\" = 'FIRMES' THEN 3 "
                            strvalorinsercion = strvalorinsercion + "WHEN \"SUPUESTO\" = 'EXIGIBLES' THEN 4 WHEN \"SUPUESTO\" = 'RETORNO INVERSIONES' THEN 5 WHEN \"SUPUESTO\" = 'CONDONADO CONCURSO MERCANTIL' THEN 6 WHEN \"SUPUESTO\" = 'CONDONADOS' THEN 7 "
                            strvalorinsercion = strvalorinsercion + "WHEN \"SUPUESTO\" = 'CANCELADOS' THEN 8 END AS \"SELECCION\""
                            consulta = "INSERT INTO \"BaseSistemaHistorico\".\"INF69\"( "
                            consulta = consulta + strcamposinsercion + " ) SELECT "
                            consulta = consulta + strvalorinsercion + " FROM \"BaseSistema\".\"" + str(strtablatemp) + "\" "
                            consulta = consulta + "WHERE \"RFC\" IS NOT NULL "
                            # print(consulta)
                            # print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
                            # return
                            cursor.execute(consulta)
                            cursor.close()
                        else:
                            consulta = ""
                            cursor = conexion.cursor()
                            strcamposinsercion = strcamposinsercion + "\"CVE_DESCARGA\", \"FH_HIST\", \"AGRUPACION\", \"SELECCION\""
                            strvalorinsercion = strvalorinsercion + "'" + CVE_DESCARGA + "' AS \"CVE_DESCARGA\", "
                            strvalorinsercion = strvalorinsercion + "NOW() AS \"FH_HIST\", "
                            strvalorinsercion = strvalorinsercion + "CASE WHEN \"SUPUESTO\" = 'NO LOCALIZADOS' THEN 'NO LOCALIZADO' WHEN \"SUPUESTO\" = 'SENTENCIAS' THEN 'DELITO FISCAL' ELSE \"SUPUESTO\" END AS \"AGRUPACION\", "
                            strvalorinsercion = strvalorinsercion + "CASE WHEN \"SUPUESTO\" = 'NO LOCALIZADOS' THEN 1 WHEN \"SUPUESTO\" = 'SENTENCIAS' THEN 2 WHEN \"SUPUESTO\" = 'FIRMES' THEN 3 "
                            strvalorinsercion = strvalorinsercion + "WHEN \"SUPUESTO\" = 'EXIGIBLES' THEN 4 WHEN \"SUPUESTO\" = 'RETORNO INVERSIONES' THEN 5 WHEN \"SUPUESTO\" = 'CONDONADO CONCURSO MERCANTIL' THEN 6 WHEN \"SUPUESTO\" = 'CONDONADOS' THEN 7 "
                            strvalorinsercion = strvalorinsercion + "WHEN \"SUPUESTO\" = 'CANCELADOS' THEN 8 END AS \"SELECCION\""
                            consulta = "INSERT INTO \"BaseSistemaHistorico\".\"INF69\"( "
                            consulta = consulta + strcamposinsercion + " ) SELECT "
                            consulta = consulta + strvalorinsercion + " FROM \"BaseSistema\".\"" + str(strtablatemp) + "\" "
                            consulta = consulta + "WHERE \"RFC\" IS NOT NULL "
                            # print(consulta)
                            # print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
                            # return
                            cursor.execute(consulta)
                            cursor.close()

                        print("**** REMOVIENDO FUENTE ***")
                        os.remove(Archivo)
                    
                    if str(tipo) == "69B":
                        consulta = ""
                        cursor = conexion.cursor()
                        strcamposinsercion = strcamposinsercion + "\"CVE_DESCARGA\", \"FH_HIST\", \"FH_PUB_69B\""
                        strvalorinsercion = strvalorinsercion + "'" + CVE_DESCARGA + "' AS \"CVE_DESCARGA\", "
                        strvalorinsercion = strvalorinsercion + "NOW() AS \"FH_HIST\", "
                        strvalorinsercion = strvalorinsercion + "CASE WHEN \"SITUACION_CONTR\" = 'Presunto' THEN to_date(\"FH_PUB_PRESUN_SAT\", 'DD/MM/YYYY') WHEN \"SITUACION_CONTR\" = 'Desvirtuado' THEN to_date(\"FH_PUB_DESV_SAT\", 'DD/MM/YYYY') "
                        strvalorinsercion = strvalorinsercion + "WHEN \"SITUACION_CONTR\" = 'Definitivo' THEN to_date(\"FH_PUB_SAT_DEF\", 'DD/MM/YYYY') WHEN \"SITUACION_CONTR\" = 'Sentencia Favorable' THEN to_date(\"FH_OFIC_GLO_SENT_FAV_SAT\", 'DD/MM/YYYY') END AS \"FH_PUB_69B\" "
                        consulta = "INSERT INTO \"BaseSistemaHistorico\".\"INF69B\"( "
                        consulta = consulta + strcamposinsercion + " ) SELECT "
                        consulta = consulta + strvalorinsercion + " FROM \"BaseSistema\".\"" + str(strtablatemp) + "\" WHERE (\"NO\" ~ '^[0-9]') = TRUE AND \"RFC\" IS NOT NULL  AND TRIM(\"RFC\") <> 'XXXXXXXXXXXX' "
                        # print(consulta)
                        # print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
                        # return
                        cursor.execute(consulta)
                        cursor.close()

                        print("**** REMOVIENDO FUENTE ***")
                        os.remove(Archivo)

                    print("**** LIMPIANDO TEMPORAL ***")
                    consulta = ""
                    cursor = conexion.cursor()
                    consulta = "DROP TABLE IF EXISTS \"BaseSistema\".\"" + str(strtablatemp) + "\""
                    # print(consulta)
                    # print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
                    # return
                    cursor.execute(consulta)
                    cursor.close()

                    print("**** ACTUALIZANDO BITACORA ***")
                    cursor = conexion.cursor()
                    consulta = ""
                    consulta = "UPDATE \"BaseSistema\".\"LOGDESCARGAFILE\" SET \"STATUS\" = 22 WHERE \"CVE_DESCARGA\" = '" + str(CVE_DESCARGA) + "' AND \"ID_FILE\" = '" + str(RESULT[0]) + "';"
                    cursor.execute(consulta)
                    conexion.commit()
                    cursor.close()

    statusCerrada = CerrarConexionPostgresql(conexion, CVE_DESCARGA)

    print(strftime("%a, %d %b %Y %H:%M:%S", localtime()))

    if statusCerrada == True:
        return "ARCHIVOS CARGADOS"

if __name__ == "__main__":
  main(sys.argv[1:])