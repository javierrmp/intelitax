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
from datetime import datetime, timedelta

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
    opts, args = getopt.getopt(sys.argv[1:], "r:p:t:u:")
    msgFormato = "ProcesaInsumos.py -r <rfc> -p <periodo YYYYMM> -t <tipo> -u <emisor, receptor>"

    if len(opts) == 0:
        print("INGRESE LOS PARAMETROS")
        print(msgFormato)
        sys.exit()
    
    try:
        strrfc = str(sys.argv[2])
        period = str(sys.argv[4])
        strtipo = str(sys.argv[6])
        sfunc = str(sys.argv[8])
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

    try:
        if not sfunc.strip() in ("emisor", "receptor"):
            raise ValueError('error')
    except (RuntimeError, TypeError, NameError, OSError, ValueError, Exception):
        print('INDIQUE LA FUNCION')
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
            idrfc = str(row[0])

            print("**** AUTORIZANDO ***")

            comando = 'python Autoriza.py -r "' + str(strrfc)  + '" -t "' + str(strtipo) + '" '
            args = shlex.split(comando)
            p = run(args)

            print("**** VERIFICANDO AUTORIZACION ***")

            cursor = conexion.cursor()
            consulta = "SELECT \"TOKEN\", \"ID_DESCARGAWS\" FROM \"BaseSistema\".\"LOGDESCARGAWSAUTH\" "
            consulta = consulta + "WHERE \"ID_RFC\" = '" + str(idrfc) + "' AND  \"TIPO\" = '"  + str(strtipo) +  "' AND \"STATUS\" = 28 AND NOW() BETWEEN \"FH_INI\" AND \"FH_FIN\" AND \"TOKEN\" IS NOT NULL AND \"MSGERROR\" IS NULL AND \"EMISOR_RECEPTOR\" IS NULL AND \"PERIODO\" IS NULL "
            consulta = consulta + "ORDER BY \"ID_DESCARGAWS\" DESC LIMIT 1 "

            # print(consulta)
            cursor.execute(consulta)
            if not cursor.rowcount:
                print("NO SE ENCONTRO LA AUTORIZACION")
                return
            else:
                RESULTADOS3 = cursor.fetchall()
                cursor.close()

            for row3 in RESULTADOS3:

                print("**** SOLICITANDO ***")

                mins = 0
                while mins != 1:
                    sleep(60)
                    mins += 1

                comando = 'python Solicita.py -r "' + str(strrfc)  + '" -p "' + str(period) + '" -t "' + str(strtipo) + '" -u "' + str(sfunc) + '" '
                args = shlex.split(comando)
                p = run(args)

                print("**** VERIFICANDO SOLICITUD ***")

                cursor = conexion.cursor()
                consulta = "SELECT \"IDPROCESO\", \"ID_PROCESOWS\" FROM \"BaseSistema\".\"LOGDESCARGAWSPROCESO\" "
                consulta = consulta + "WHERE \"ID_RFC\" = '" + str(idrfc) + "' AND  \"TIPO\" = '"  + str(strtipo) +  "' AND \"STATUS\" = 28 AND \"EMISOR_RECEPTOR\" = '"  + str(sfunc) +  "' AND \"PERIODO\" = '"  + str(period) +  "' AND \"IDPROCESO\" IS NOT NULL AND \"MSGERROR\" IS NULL AND \"ACCION\" = 'SOLICITA' "
                consulta = consulta + "ORDER BY \"ID_PROCESOWS\" DESC LIMIT 1 "

                # print(consulta)
                cursor.execute(consulta)
                if not cursor.rowcount:
                    print("NO SE ENCONTRO LA SOLICITUD REQUERIDA")
                    return
                else:
                    RESULTADOS4 = cursor.fetchall()
                    cursor.close()

                for row4 in RESULTADOS4:

                    bVerificado = 0
                    intento = 1

                    while bVerificado != 1:
                        
                        mins = 0
                        while mins != 1:
                            sleep(60)
                            mins += 1

                        print("**** VALIDANDO *** Intento: ", intento)

                        intento += 1

                        comando = 'python Verifica.py -r "' + str(strrfc)  + '" -p "' + str(period) + '" -t "' + str(strtipo) + '" -u "' + str(sfunc) + '" '
                        args = shlex.split(comando)
                        p = run(args)

                        print("**** VERIFICANDO VALIDACION ***")

                        cursor = conexion.cursor()
                        consulta = "SELECT \"IDPROCESO\", \"ID_PROCESOWS\" FROM \"BaseSistema\".\"LOGDESCARGAWSPROCESO\" "
                        consulta = consulta + "WHERE \"ID_RFC\" = '" + str(idrfc) + "' AND  \"TIPO\" = '"  + str(strtipo) +  "' AND \"STATUS\" = 28 AND \"EMISOR_RECEPTOR\" = '"  + str(sfunc) +  "' AND \"PERIODO\" = '"  + str(period) +  "' AND \"IDPROCESO\" IS NOT NULL AND \"MSGERROR\" IS NULL AND \"ACCION\" = 'VERIFICA' "
                        consulta = consulta + "ORDER BY \"ID_PROCESOWS\" DESC LIMIT 1 "

                        cursor.execute(consulta)
                        if not cursor.rowcount:
                            bVerificado = 0
                        else:
                            RESULTADOS4 = cursor.fetchall()
                            cursor.close()

                            for row4 in RESULTADOS4:
                                bVerificado = 1
                    
                    print("**** DESCARGANDO ***")
                    comando = 'python Descarga.py -r "' + str(strrfc)  + '" -p "' + str(period) + '" -t "' + str(strtipo) + '" -u "' + str(sfunc) + '" '
                    args = shlex.split(comando)
                    p = run(args)

                    print("**** VERIFICANDO DESCARGA ***")

                    cursor = conexion.cursor()
                    consulta = "SELECT \"IDPROCESO\", \"ID_PROCESOWS\" FROM \"BaseSistema\".\"LOGDESCARGAWSPROCESO\" "
                    consulta = consulta + "WHERE \"ID_RFC\" = '" + str(idrfc) + "' AND  \"TIPO\" = '"  + str(strtipo) +  "' AND \"STATUS\" = 31 AND \"EMISOR_RECEPTOR\" = '"  + str(sfunc) +  "' AND \"PERIODO\" = '"  + str(period) +  "' AND \"IDPROCESO\" IS NULL AND \"MSGERROR\" = 'DESCARGA COMPLETA' AND \"ACCION\" = 'DESCARGA' "
                    consulta = consulta + "ORDER BY \"ID_PROCESOWS\" DESC LIMIT 1 "

                    # print(consulta)
                    cursor.execute(consulta)
                    if not cursor.rowcount:
                        print("NO SE DESCARGO CORRECTAMENTE EL ARCHIVO")

                    else:
                        RESULTADOS4 = cursor.fetchall()
                        cursor.close()

                        for row4 in RESULTADOS4:

                            if strtipo.upper() in ("METADATA"):
                                print("**** CARGANDO METADATA ***")

                                comando = 'python CargaArchivosMETA.py -r "' + str(strrfc)  + '" -u "' + str(sfunc) + '" '
                                args = shlex.split(comando)
                                p = run(args)

                            if strtipo.upper() in ("CFDI"):
                                print("**** CARGANDO CFDI ***")

                                comando = 'python CargaXML.py -r "' + str(strrfc)  + '" -p "' + str(period) + '" '
                                args = shlex.split(comando)
                                p = run(args)

    print("**** PROCESO TERMINADO ***")
    print(strftime("%a, %d %b %Y %H:%M:%S", localtime()))

if __name__ == "__main__":
  main()