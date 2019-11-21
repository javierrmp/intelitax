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
from time import localtime, strftime, sleep
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
    opts, args = getopt.getopt(sys.argv[1:], "r:t:")
    msgFormato = "Autoriza.py -r <rfc> -t <tipo>"

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

    try:
        if not strtipo.upper() in ("CFDI", "METADATA"):
            raise ValueError('error')
    except (RuntimeError, TypeError, NameError, OSError, ValueError, Exception):
        print('NO EXISTE EL TIPO DE SOLICITUD')
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

            print("**** VALIDANDO CREDENCIALES ***")

            cursor = conexion.cursor() 
            consulta = ""
            consulta = "SELECT \"PASS\" FROM \"BaseSistema\".\"CFGCLTESCREDENCIALES\" WHERE \"ID_RFC\" = '" + str(idrfc) + "' AND \"STATUS\" = 7;"
            cursor.execute(consulta)
            if not cursor.rowcount:
                print("NO SE ENCONTRO EL CERTIFICADO ASOCIADO")
                strPwd = ""
                return
            else:
                RESULTADOS2 = cursor.fetchall()
                cursor.close()

            for row2 in RESULTADOS2:

                try:
                    
                    CVE_DESCARGA = strftime("%Y%m%d%H%M%S", localtime())
                    strPwd = row2[0]

                    print("**** PREPARANDO REGISTRO ***")

                    cursor = conexion.cursor()
                    consulta = ""
                    consulta = "INSERT INTO \"BaseSistema\".\"LOGDESCARGAWSAUTH\"(\"CVE_DESCARGA\", \"ID_RFC\", \"TIPO\", \"STATUS\")"
                    consulta = consulta + " VALUES(%s,%s,%s,%s)"
                    valores = (str(CVE_DESCARGA), str(idrfc), str(strtipo), 27)
                    cursor.execute(consulta, valores)
                    conexion.commit()
                    cursor.close()

                    fini = datetime.now()
                    ffin = fini + timedelta(minutes=5)

                    fini = fini.strftime("%Y-%m-%dT%H:%M:%S")
                    ffin = ffin.strftime("%Y-%m-%dT%H:%M:%S")

                    paswd1 = codecs.decode(strPwd, 'Hex')
                    paswd2 = paswd1.decode('utf-8')

                    print("**** PREPARANDO CREDENCIALES ***")
                    DescargaFile(conexion, "Llave.key", str(idrfc), "LLAVE")
                    DescargaFile(conexion, "Cert.cer", str(idrfc), "CERTIF")
                    
                    comando = 'openssl pkcs8 -inform DER -in Llave.key -out Llave.key.pem -passin pass:' + str(paswd2)
                    args = shlex.split(comando)
                    p = run(args)

                    print("**** SOLICITANDO AUTORIZACIONES ***")
                    comando = 'php Autoriza.php -c Cert.cer -k Llave.key.pem'
                    args = shlex.split(comando)
                    p = run(args)
                    valor = p[1]
                    # print(valor)

                    print("**** ACTUALIZANDO EL SISTEMA ***")
                    hexlify = codecs.getencoder('hex')
                    encvalor = str(valor).encode('utf-8')
                    token = str(hexlify(encvalor)[0])[0:5000]

                    cursor = conexion.cursor()
                    consulta = ""
                    consulta = "UPDATE \"BaseSistema\".\"LOGDESCARGAWSAUTH\" SET \"FH_INI\" = %s, \"FH_FIN\" = %s, \"TOKEN\" = %s, \"STATUS\" = %s "
                    consulta = consulta + "WHERE \"CVE_DESCARGA\" = '" + str(CVE_DESCARGA) + "' AND  \"ID_RFC\" = '" + str(idrfc) + "' AND  \"TIPO\" = '" + str(strtipo) + "'"
                    valores = (fini, ffin, token, 28)
                    cursor.execute(consulta, valores)
                    conexion.commit()
                    cursor.close()

                except (Exception, psycopg2.Error, RuntimeError, TypeError, NameError, OSError, ValueError) as error :

                    cursor = conexion.cursor()
                    consulta = ""
                    consulta = "UPDATE \"BaseSistema\".\"LOGDESCARGAWSAUTH\" SET \"STATUS\" = 32, \"MSGERROR\" = " + str(error)
                    consulta = consulta + " WHERE \"CVE_DESCARGA\" = '" + str(CVE_DESCARGA) + "' AND  \"ID_RFC\" = '" + str(idrfc) + "' AND  \"TIPO\" = '" + str(strtipo) + "'"
                    cursor.execute(consulta)
                    conexion.commit()
                    cursor.close()

                    print ("ERROR DURANTE EL PROCESO : ", error)

                finally:

                    if len(strPwd) > 0:
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