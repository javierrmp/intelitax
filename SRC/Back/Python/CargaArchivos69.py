#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os.path
import datetime
import os
import psycopg2
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
        
        # cursor = connection.cursor()
        # consulta = ""
        # consulta = "CALL \"BaseSistema\".\"CopiaINFOMETA\"('" + cve_descarga + "');"
        # print("**** MATERIALIZANDO METADATA ***")
        # cursor.execute(consulta)
        # connection.commit()
        # cursor.close()

        connection.close()
        return True

def main(argv):
    conexion = AbrirConexionPostgresql()

    # if len(sys.argv) < 2:
    #     print("INGRESE EL NUMERO DE RFC ASOCIADO QUE VA PROCESAR DE LA METADATA")
    #     return

    # if sys.argv[1] == "":
    #     print("INGRESE EL NUMERO DE RFC ASOCIADO QUE VA PROCESAR DE LA METADATA")
    #     return

    Ruta = os.getcwd()
    Archivos = os.listdir(Ruta)

    print("**** CARGANDO ARCHIVOS ***")
    print(strftime("%a, %d %b %Y %H:%M:%S", localtime()))


    CVE_DESCARGA = strftime("%Y%m%d%H%M%S", localtime())
    print("CARGA:",CVE_DESCARGA)

    for file in Archivos:
        Archivo = file
        
        #if True in (Archivo.endswith('.csv'), Archivo.endswith('.txt')):
        if True in (Archivo.endswith('.csv')):
            
            cursor = conexion.cursor()
            consulta = ""
            consulta = "SELECT \"ID_FILE\", \"TEMPORAL\", \"TYP_FILE\" FROM \"BaseSistema\".\"CFGFILE\" WHERE \"FILE_NAME\" = '" + Archivo + "' AND \"STATUS\" = 10;"
            cursor.execute(consulta)
            RESULTADOS = cursor.fetchall()
            cursor.close()

            for row in RESULTADOS:

                RESULT = row
                ahora = strftime("%c")

                cursor = conexion.cursor()
                consulta = ""
                consulta = "INSERT INTO \"BaseSistema\".\"LOGDESCARGAFILE\"(\"CVE_DESCARGA\", \"FH_DESCARGA\", \"FH_PUB\", \"ID_FILE\", \"ID_RFC\", \"STATUS\")"
                consulta = consulta + " VALUES(%s,%s,%s,%s,%s,%s)"
                #valores = (CVE_DESCARGA, ahora, ahora, RESULT[0], 2, 21)
                valores = (CVE_DESCARGA, ahora, ahora, RESULT[0], 0, 21)
                cursor.execute(consulta, valores)
                conexion.commit()
                count = cursor.rowcount
                cursor.close()
                
                if count > 0:
                    print("**** PROCESANDO ARCHIVO ***", Archivo)
                    
                    cursor = conexion.cursor()
                    tipo = RESULT[2]
                    tipo = tipo.strip()
                    consulta = ""
                    if str(tipo) == "69":
                        consulta = "CALL \"BaseSistema\".\"CargaINFO69\" ('" 
                    if str(tipo) == "69B":
                        consulta = "CALL \"BaseSistema\".\"CargaINFO69B\" ('" 
                    # if str(tipo) == "MET":
                    #     consulta = "CALL \"BaseSistema\".\"CargaINFOMETA\" ('" 
                    consulta = consulta + CVE_DESCARGA + "', '" + Archivo + "', '" + RESULT[1] + "', '" + Ruta + "/')"
                    cursor.execute(consulta)

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