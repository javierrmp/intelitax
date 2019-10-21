#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys, getopt
import os.path
import datetime
import os
import psycopg2
import codecs
import subprocess as sp
import shlex
import functools                
from psycopg2 import Error
from time import localtime, strftime
from datetime import datetime, timedelta, time

CONF_FILE = os.path.expanduser('~/.config/pag')

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

def DescargaFile(connection, Nombre, idRFC, Campo):
    cursor = connection.cursor()
    consulta = "SELECT \"" + Campo + "\" FROM \"BaseSistema\".\"CFGCLTESCREDENCIALES\" WHERE \"ID_RFC\" = " + idRFC + " AND \"STATUS\" = 7 "
    cursor.execute(consulta)

    blob = cursor.fetchone()
    open(Nombre, 'wb').write(blob[0])
    cursor.close()

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

    opts, args = getopt.getopt(sys.argv[1:], "r:t:")
    msgFormato = "Descarga.py -r <rfc> -t <tipo>"

    if len(opts) == 0:
        print("INGRESE LOS PARAMETROS")
        print(msgFormato)
        sys.exit()
    
    try:
        
        strrfc = str(sys.argv[2])
        strtipo = str(sys.argv[4])
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
        if len(strtipo) == 0:
            raise ValueError('error')
    except (RuntimeError, TypeError, NameError, OSError, ValueError, Exception):
        print('INGRESE EL TIPO DE SOLICITUD')
        print(msgFormato)
        sys.exit()
        return

    fechaInicio = datetime.now()
    fechaFin = fechaInicio + timedelta(minutes=5)

    fechaInicio = fechaInicio.strftime("%Y-%m-%dT%H:%M:%S")
    fechaFin = fechaFin.strftime("%Y-%m-%dT%H:%M:%S")

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
            idrfc = str(row[0])

            print("**** VALIDANDO CREDENCIALES ***")

            cursor = conexion.cursor() 
            consulta = ""
            consulta = "SELECT \"PASS\" FROM \"BaseSistema\".\"CFGCLTESCREDENCIALES\" WHERE \"ID_RFC\" = '" + str(idrfc) + "' AND \"STATUS\" = 7;"
            cursor.execute(consulta)
            if not cursor.rowcount:
                print("NO SE ENCONTRO EL PASSWORD ASOCIADO")
                return
            else:
                RESULTADOS2 = cursor.fetchall()
                cursor.close()

            for row2 in RESULTADOS2:

                try:
                    
                    CVE_DESCARGA = strftime("%Y%m%d%H%M%S", localtime())
                    strPwd = row2[0]

                    print("**** VALIDANDO AUTORIZACION ***")

                    cursor = conexion.cursor()
                    consulta = "SELECT \"TOKEN\", \"ID_DESCARGAWS\" FROM \"BaseSistema\".\"LOGDESCARGAWSAUTH\" "
                    consulta = consulta + "WHERE \"ID_RFC\" = '" + str(idrfc) + "' AND  \"TIPO\" = '"  + str(strtipo) +  "' AND \"STATUS\" = 28 "
                    consulta = consulta + "ORDER BY \"ID_DESCARGAWS\" DESC LIMIT 1 "
                    cursor.execute(consulta)
                    if not cursor.rowcount:
                        print("NO SE ENCONTRO LA AUTORIZACION NECESARIA")
                        strToken = ""
                        return
                    else:
                        RESULTADOS3 = cursor.fetchall()
                        cursor.close()

                    for row3 in RESULTADOS3:
                        strToken = str(row3[0])
                        strIdDescarga = str(row3[1])
                    
                        print("**** VALIDANDO SOLICITUD ***")

                        cursor = conexion.cursor()
                        consulta = "SELECT \"IDPROCESO\", \"ID_PROCESOWS\" FROM \"BaseSistema\".\"LOGDESCARGAWSPROCESO\" "
                        consulta = consulta + "WHERE \"ID_RFC\" = '" + str(idrfc) + "' AND  \"TIPO\" = '"  + str(strtipo) +  "' AND \"STATUS\" = 28"
                        consulta = consulta + "ORDER BY \"ID_PROCESOWS\" DESC LIMIT 1 "
                        cursor.execute(consulta)
                        if not cursor.rowcount:
                            print("NO SE ENCONTRO LA SOLICITUD REQUERIDA")
                            strToken = ""
                            return
                        else:
                            RESULTADOS4 = cursor.fetchall()
                            cursor.close()

                        for row4 in RESULTADOS4:
                            strsolicitud = str(row4[0])
                            strIdSolicitud = str(row4[1])

                            print("**** PREPARANDO REGISTRO ***")

                            cursor = conexion.cursor()
                            consulta = ""
                            consulta = "INSERT INTO \"BaseSistema\".\"LOGDESCARGAWSPROCESO\"(\"CVE_DESCARGA\", \"ID_RFC\", \"TIPO\", \"STATUS\")"
                            consulta = consulta + " VALUES(%s,%s,%s,%s)"
                            valores = (str(CVE_DESCARGA), str(idrfc), str(strtipo), 27)
                            cursor.execute(consulta, valores)
                            conexion.commit()
                            cursor.close()

                            paswd1 = codecs.decode(strPwd, 'Hex')
                            paswd2 = paswd1.decode('utf-8')
                            
                            TokenAutoriza1 = codecs.decode(strToken, 'Hex')
                            TokenAutoriza2 = TokenAutoriza1.decode('utf-8')

                            Solicitud1 = codecs.decode(strsolicitud, 'Hex')
                            Solicitud2 = Solicitud1.decode('utf-8')

                            print("**** PREPARANDO CREDENCIALES ***")
                            DescargaFile(conexion, "Llave.key", str(idrfc), "LLAVE")
                            DescargaFile(conexion, "Cert.cer", str(idrfc), "CERTIF")

                            comando = 'openssl pkcs8 -inform DER -in Llave.key -out Llave.key.pem -passin pass:' + str(paswd2)
                            args = shlex.split(comando)
                            p = run(args)

                            print("**** SOLICITANDO AUTORIZACIONES ***")
                            comando = 'php Descarga.php -c "Cert.cer" -k "Llave.key.pem" -r "' + str(strrfc) + '" -a "' + str(TokenAutoriza2) + '" -v "' + str(Solicitud2) + '"'
                            args = shlex.split(comando)
                            p = run(args)

                            print("**** ACTUALIZANDO EL SISTEMA ***")
                            cursor = conexion.cursor()
                            consulta = ""
                            consulta = "UPDATE \"BaseSistema\".\"LOGDESCARGAWSPROCESO\" SET \"FH_INI\" = '" + str(fechaInicio) + "', \"FH_FIN\" = '" + str(fechaFin) + "', \"MSGERROR\" = 'DESCARGA COMPLETA', \"STATUS\" = 31 "
                            consulta = consulta + "WHERE \"CVE_DESCARGA\" = '" + str(CVE_DESCARGA) + "' AND  \"ID_RFC\" = '" + str(idrfc) + "' AND  \"TIPO\" = '" + str(strtipo) + "'"
                            cursor.execute(consulta)
                            conexion.commit()
                            cursor.close()

                            cursor = conexion.cursor()
                            consulta = ""
                            consulta = "UPDATE \"BaseSistema\".\"LOGDESCARGAWSAUTH\" SET \"STATUS\" = 31, \"MSGERROR\" = '" + str(Solicitud2) + "' "
                            consulta = consulta + " WHERE \"ID_DESCARGAWS\" = '" + str(strIdDescarga) + "'"
                            cursor.execute(consulta)
                            conexion.commit()
                            cursor.close()

                            bError = 0
                    
                except (psycopg2.Error, RuntimeError, TypeError, NameError, OSError, ValueError, Exception) as error :
                        if bError == 1:
                            error = str(error).replace("'", "")

                            print("ERROR GUARDANDO LOG")
                            cursor = conexion.cursor()
                            consulta = ""
                            consulta = "UPDATE \"BaseSistema\".\"LOGDESCARGAWSPROCESO\" SET \"STATUS\" = 32, \"MSGERROR\" = '" + str(error) + "'"
                            consulta = consulta + " WHERE \"CVE_DESCARGA\" = '" + str(CVE_DESCARGA) + "' AND  \"ID_RFC\" = '" + str(idrfc) + "' AND  \"TIPO\" = '" + str(strtipo) + "'"
                            cursor.execute(consulta)
                            conexion.commit()
                            cursor.close()

                            cursor = conexion.cursor()
                            consulta = ""
                            consulta = "UPDATE \"BaseSistema\".\"LOGDESCARGAWSPROCESO\" SET \"STATUS\" = 32, \"MSGERROR\" = '" + str(error) + "'"
                            consulta = consulta + " WHERE \"ID_PROCESOWS\" = '" + str(strIdSolicitud) + "' AND  \"ID_RFC\" = '" + str(idrfc) + "' AND  \"TIPO\" = '" + str(strtipo) + "'"
                            cursor.execute(consulta)
                            conexion.commit()
                            cursor.close()

                            cursor = conexion.cursor()
                            consulta = ""
                            consulta = "UPDATE \"BaseSistema\".\"LOGDESCARGAWSAUTH\" SET \"STATUS\" = 32, \"MSGERROR\" = '" + str(error) + "'"
                            consulta = consulta + " WHERE \"ID_DESCARGAWS\" = '" + str(strIdDescarga) + "'"
                            cursor.execute(consulta)
                            conexion.commit()
                            cursor.close()

                            print ("ERROR DURANTE EL PROCESO : ", error)

                finally:

                    if len(strToken) > 0:
                        print("**** LIMPIANDO TEMPORALES ***")
                        os.remove("Llave.key")
                        os.remove("Llave.key.pem")
                        os.remove("Cert.cer")

                    print("**** CERRANDO CONEXIONES ***")
                    statusCerrada = CerrarConexionPostgresql(conexion)

                    print(strftime("%a, %d %b %Y %H:%M:%S", localtime()))

                    if statusCerrada == True:
                        return "AUTORIZACIONES REALIZADAS"

if __name__ == "__main__":
  main()