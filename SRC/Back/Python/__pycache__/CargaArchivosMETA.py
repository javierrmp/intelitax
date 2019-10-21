#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys, getopt
import os.path
import datetime
import os
import psycopg2
import shlex
import subprocess as sp
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
        print ("Error while connecting to PostgreSQL", error)

    finally:
        return connection

def CerrarConexionPostgresql(connection, cve_descarga):
    if(connection):

        cursor = connection.cursor()
        consulta = ""
        consulta = "CALL \"BaseSistema\".\"CopiaINFOMETA\"('" + cve_descarga + "');"
        print("**** MATERIALIZANDO METADATA ***")
        cursor.execute(consulta)
        connection.commit()
        cursor.close()

        connection.close()
        return True

def run(cmd, echo=True, graceful=True):            
    proc = sp.Popen(cmd, stdout=sp.PIPE, stderr=sp.STDOUT)            
    output, _ = proc.communicate()            
    output = output.decode('utf-8')            
    if echo:            
        print('EJECUTANDO PROCESO')
    if not graceful and proc.returncode != 0:            
        sys.exit(1)            
    return proc.returncode, output

def main():
    bError = 1

    opts, args = getopt.getopt(sys.argv[1:], "r:")
    msgFormato = "CargaArchivosMETA.py -r <rfc>"

    if len(opts) == 0:
        print("INGRESE LOS PARAMETROS")
        print(msgFormato)
        sys.exit()
    
    try:
        strrfc = str(sys.argv[2])
    except (RuntimeError, TypeError, NameError, OSError, ValueError, Exception):
        print("ERROR EN LOS DATOS INGRESADOS")
        print(msgFormato)
        sys.exit()
        return

    try:
        if len(strrfc) == 0:
            raise ValueError('error')
    except (RuntimeError, TypeError, NameError, OSError, ValueError, Exception):
        print('INGRESE EL RFC')
        print(msgFormato)
        sys.exit()
        return

    conexion = AbrirConexionPostgresql()

    print(strftime("%a, %d %b %Y %H:%M:%S", localtime()))
 
    print("**** VALIDANDO RFC ***")

    cursor = conexion.cursor()
    consulta = ""
    consulta = "SELECT \"ID_RFC\" FROM \"BaseSistema\".\"CFGCLTESRFC\" WHERE \"RFC\" = '" + str(strrfc) + "' AND \"STATUS\" = 5;"
    cursor.execute(consulta)
    if not cursor.rowcount:
        print("EL RFC QUE INGRESO NO EXISTE O ESTA CANCELADO")
        return
    else:
        RESULTADOS = cursor.fetchall()
        cursor.close()

    for row in RESULTADOS:
        if row[0] > 0:

            idrfc = row[0]

            print("**** VALIDANDO INFORMACION METADATA ***")

            cursor = conexion.cursor()
            consulta = "SELECT \"ID_DESCARGAWS\", \"MSGERROR\" FROM \"BaseSistema\".\"LOGDESCARGAWSAUTH\" "
            consulta = consulta + "WHERE \"ID_RFC\" = '" + str(idrfc) + "' AND  \"TIPO\" = 'Metadata' AND \"STATUS\" = 31 AND \"MSGERROR\" <> '' "
            consulta = consulta + "ORDER BY \"ID_DESCARGAWS\" DESC LIMIT 1 "
            cursor.execute(consulta)
            if not cursor.rowcount:
                print("NO SE ENCONTRO EL REGISTRO DE LA METADATA")
                return
            else:
                RESULTADOS2 = cursor.fetchall()
                cursor.close()

            for row2 in RESULTADOS2:
                #idDescarga = str(row2[0])
                strArchivo = str(row2[1])

                comando = 'unzip -o ' + str(strArchivo) + '.zip' 
                args = shlex.split(comando)
                run(args)

                strArchivotxt = str(strArchivo) + '.txt'

                Ruta = os.getcwd()
                Archivos = os.listdir(Ruta)

                print("**** BUSCANDO ARCHIVOS ***")

                CVE_DESCARGA = strftime("%Y%m%d%H%M%S", localtime())
                # print("CARGA:",CVE_DESCARGA)
                # print(strArchivotxt)

                for file in Archivos:
                    Archivo = file
                    
                    if Archivo.strip() == strArchivotxt.strip():

                        print("**** BUSCANDO CONFIGURACION ARCHIVOS ***")
                        cursor = conexion.cursor()
                        consulta = ""
                        consulta = "SELECT \"ID_FILE\", \"TEMPORAL\", \"TYP_FILE\" FROM \"BaseSistema\".\"CFGFILE\" WHERE \"TYP_FILE\" = 'MET' AND \"DESCARGA_WEBS_CARGA\" = '2' AND \"STATUS\" = 10;"

                        cursor.execute(consulta)
                        if not cursor.rowcount:
                            print("NO SE ENCONTRO LA CONFIGURACION DEL ARCHIVO")
                            return
                        else:
                            RESULTADOS3 = cursor.fetchall()
                            cursor.close()

                        for row3 in RESULTADOS3:

                            idFile = row3[0]
                            strTemporal = row3[1]
                            strTipo = row3[2]

                            ahora = strftime("%c")

                            try:
                                cursor = conexion.cursor()
                                consulta = ""
                                consulta = "INSERT INTO \"BaseSistema\".\"LOGDESCARGAFILE\"(\"CVE_DESCARGA\", \"FH_DESCARGA\", \"FH_PUB\", \"ID_FILE\", \"ID_RFC\", \"STATUS\")"
                                consulta = consulta + " VALUES(%s,%s,%s,%s,%s,%s)"
                                valores = (CVE_DESCARGA, ahora, ahora, idFile, idrfc, 21)
                                cursor.execute(consulta, valores)
                                conexion.commit()
                                count = cursor.rowcount
                                cursor.close()
                                
                                if count > 0:
                                    print("**** PROCESANDO ARCHIVO ***", Archivo)
                                    
                                    cursor = conexion.cursor()
                                    tipo = strTipo
                                    tipo = tipo.strip()
                                    consulta = ""
                                    if str(tipo) == "MET":
                                        consulta = "CALL \"BaseSistema\".\"CargaINFOMETA\" ('" 
                                    consulta = consulta + CVE_DESCARGA + "', '" + Archivo + "', '" + strTemporal + "', '" + Ruta + "/')"
                                    cursor.execute(consulta)
                                    cursor.close()

                                    print("**** ACTUALIZANDO REGISTRO ***")
                                    consulta = ""
                                    consulta = "UPDATE \"BaseSistema\".\"LOGDESCARGAFILE\" SET \"STATUS\" = 22 WHERE \"CVE_DESCARGA\" = '" + str(CVE_DESCARGA) + "' AND \"ID_FILE\" = '" + str(idFile) + "';"
                                    cursor.execute(consulta)
                                    conexion.commit()
                                    cursor.close()

                                    print("**** COPIANDO INFORMACION HISTORICA ***")
                                    cursor = conexion.cursor()
                                    consulta = ""
                                    if str(tipo) == "MET":
                                        consulta = "CALL \"BaseSistema\".\"CopiaINFOMETA\" ('" 
                                    consulta = consulta + CVE_DESCARGA + "' )"
                                    cursor.execute(consulta)
                                    cursor.close()

                                    bError = 0

                            except (psycopg2.Error, RuntimeError, TypeError, NameError, OSError, ValueError, Exception) as error :
                                if bError == 1:
                                    
                                    consulta = ""
                                    consulta = "UPDATE \"BaseSistema\".\"LOGDESCARGAFILE\" SET \"STATUS\" = 33 WHERE \"CVE_DESCARGA\" = '" + str(CVE_DESCARGA) + "' AND \"ID_FILE\" = '" + str(idFile) + "';"
                                    cursor.execute(consulta)
                                    conexion.commit()
                                    cursor.close()
                                    print(error)

                            finally:
                                statusCerrada = CerrarConexionPostgresql(conexion, CVE_DESCARGA)

                                print("**** LIMPIANDO TEMPORALES ***")
                                os.remove(strArchivotxt)

                                print(strftime("%a, %d %b %Y %H:%M:%S", localtime()))

                                if statusCerrada == True:
                                    return "ARCHIVOS CARGADOS"

if __name__ == "__main__":
  main()