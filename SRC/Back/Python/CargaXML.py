#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, getopt
import os.path
import datetime
import os
import psycopg2
import shlex
import codecs
import subprocess as sp
from psycopg2 import Error
from xml.dom import minidom
from time import localtime, strftime
from zipfile import ZipFile

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

def CerrarConexionPostgresql(connection):
    if(connection):
        connection.close()
        return True

def getAtributos(connection, nomFileXml, cvedescarga):
    try:

        comando = 'php CargaXML.php -a "' + str(nomFileXml) + '" -c "' + str(cvedescarga) + '"'
        args = shlex.split(comando)         
        p = run(args)
                    
    except (Exception, psycopg2.DatabaseError) as error :
        print ("Error mientras se guardaban los datos", error)

        cursor = connection.cursor()
        consulta = ""
        consulta = "INSERT INTO \"InfUsuario\".\"CFDITOTAL\"( "
        consulta = consulta + "\"ERROR\",  "
        consulta = consulta + "\"UUID\" )"
        
        consulta = consulta + " VALUES( "
        consulta = consulta + "'" + error + "', "
        consulta = consulta + "'" + str(nomFileXml) + "' "
        consulta = consulta + " )"
        
        cursor.execute(consulta)
        connection.commit()
        cursor.close()
        return 0

    finally:
        return 1

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

    opts, args = getopt.getopt(sys.argv[1:], "r:p:")
    msgFormato = "CargaXML.py -r <rfc> -p <periodo>"

    if len(opts) == 0:
        print("INGRESE LOS PARAMETROS")
        print(msgFormato)
        sys.exit()
    
    try:
        strrfc = str(sys.argv[2])
        period = str(sys.argv[4])
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

    try:
        if len(period) < 6:
            raise ValueError('error')
    except (RuntimeError, TypeError, NameError, OSError, ValueError, Exception):
        print('INGRESE EL PERIODO')
        print(msgFormato)
        sys.exit()
        return

    conexion = AbrirConexionPostgresql()

    print(strftime("%a, %d %b %Y %H:%M:%S", localtime()))
    CVE_DESCARGA = strftime("%Y%m%d%H%M%S", localtime())
 
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

            print("**** MARCANDO INFORMACION XML ***")
            cursor = conexion.cursor()
            consulta = "CALL \"BaseSistema\".\"MarcaXML\"('" + str(CVE_DESCARGA) + "', " + str(idrfc) + ", '" + str(period) + "')"
            cursor.execute(consulta)
            conexion.commit()
            cursor.close()

            print("**** BUSCANDO BATCH DE XML A PROCESAR ***")
            cursor = conexion.cursor()
            consulta = "SELECT \"ARCHIVOXML\", \"ID_CARGAXML\" FROM \"BaseSistema\".\"LOGCARGAXML\" WHERE \"CVE_CARGA\" = '" + str(CVE_DESCARGA) + "' AND \"STATUS\" = 35 AND \"PERIODO\" = '" + str(period) + "' "
            cursor.execute(consulta)
            
            if not cursor.rowcount:
                print("NO HAY XML DISPONIBLES PARA PROCESAR")
                return
            else:
                RESULTADOS2 = cursor.fetchall()
                cursor.close()

            for row2 in RESULTADOS2:
                
                try:
                    
                    strArchivotxt = str(row2[0]).strip()
                    strCveCargaXML = str(row2[1]).strip()
                    print (strArchivotxt)

                    stat = getAtributos(conexion, strArchivotxt, str(strCveCargaXML))
                    
                    if stat == 1:
                        print("**** PROCESO COMPLETADO ***")
                        cursor = conexion.cursor()
                        consulta = "UPDATE \"BaseSistema\".\"LOGCARGAXML\" SET \"STATUS\" = 36, \"USAPAGO\" = 1 WHERE \"ID_CARGAXML\" = '" + str(strCveCargaXML) + "' AND \"STATUS\" = 35 AND \"PERIODO\" = '" + str(period) + "' "
                        cursor.execute(consulta)
                        conexion.commit()
                        cursor.close()

                        print("**** LIMPIANDO XML ***")
                        os.remove(strArchivotxt)

                        bError = 0

                except (psycopg2.Error, RuntimeError, TypeError, NameError, OSError, ValueError, Exception) as error :
                    if bError == 1:
                        print("**** ERROR EN LA CARGA DEL XML ***")
                        cursor = conexion.cursor()
                        consulta = "UPDATE \"BaseSistema\".\"LOGCARGAXML\" SET \"STATUS\" = 37, \"MSGERROR\" = '" + str(error) + "' WHERE \"ID_CARGAXML\" = '" + str(strCveCargaXML) + "' AND \"PERIODO\" = '" + str(period) + "'"
                        cursor.execute(consulta)
                        conexion.commit()
                        cursor.close()

                finally:
                    print("**** CARGA FINALIZADA ***")

            print("**** FINALIZA PROCESO ***")
            cursor = conexion.cursor()
            consulta = ""
            consulta = "CALL \"BaseSistema\".\"RecargaResultados\"('" + CVE_DESCARGA + "');"
            cursor.execute(consulta)
            conexion.commit()
            cursor.close()

            print("**** MARCA PAGOS QUE NO ESTAN SUS DOCUMENTOS RELACIONADOS ***")
            cursor = conexion.cursor()
            consulta = ""
            consulta = "CALL \"BaseSistema\".\"MarcaPagosInValidosXdocu\"();"
            cursor.execute(consulta)
            conexion.commit()
            cursor.close()

            print("CIERRA CONEXION")
            statusCerrada = CerrarConexionPostgresql(conexion)

            print(strftime("%a, %d %b %Y %H:%M:%S", localtime()))

            if statusCerrada == True:
                return "ARCHIVOS CARGADOS"

if __name__ == "__main__":
    main()
