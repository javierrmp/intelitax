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
from zipfile import ZipFile

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

def main():
    opts, args = getopt.getopt(sys.argv[1:], "r:i:f:t:")
    msgFormato = "Solicita.py -r <rfc> -i <finicial YYYY-MM-DD> -f <ffinal YYYY-MM-DD> -t <tipo>"

    if len(opts) == 0:
        print("INGRESE LOS PARAMETROS")
        print(msgFormato)
        sys.exit()
    
    try:
        
        strrfc = str(sys.argv[2])
        finicio = str(sys.argv[4])
        ffin = str(sys.argv[6])
        strtipo = str(sys.argv[8])
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
        if len(finicio) == 0:
            raise ValueError('error')
    except (RuntimeError, TypeError, NameError, OSError, ValueError, Exception):
        print('INGRESE EL LA FECHA DE INICIO')
        print(msgFormato)
        sys.exit()
        return

    try:
        if len(ffin) == 0:
            raise ValueError('error')
    except (RuntimeError, TypeError, NameError, OSError, ValueError, Exception):
        print('INGRESE EL LA FECHA DE FIN')
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
        fechaInicio = datetime.strptime(finicio, '%Y-%m-%d')
        fechaFin = datetime.strptime(ffin, '%Y-%m-%d')
    except (RuntimeError, TypeError, NameError, OSError, ValueError, Exception):
        print("FORMATO DE FECHA INCORRECTO")
        print(msgFormato)
        sys.exit()
        return

    conexion = AbrirConexionPostgresql()
    strArchivo = '2E6EA894-EAE4-4264-8807-BE8EE3845850_01.zip'

    numPagina = 1
    cont=1
    with ZipFile(str(strArchivo), 'r') as zipObj:
        listOfiles = zipObj.namelist()
        for elem in listOfiles:
            strArchivotxt = elem

            print(strArchivotxt)
            cursor = conexion.cursor()
            consulta = ""
            consulta = "INSERT INTO \"BaseSistema\".\"LOGCARGAXML\" (\"CVE_DESCARGA\", \"ARCHIVOXML\", \"STATUS\", \"PAGINA\" ) "
            consulta = consulta + "VALUES ('20191012153728', '" + str(strArchivotxt) + "', 34, '" + str(numPagina) + "')"
            cursor.execute(consulta)
            conexion.commit()
            cursor.close()

            cont = cont + 1
            if cont >= 101:
                numPagina = numPagina + 1
                cont = 1
    
    CerrarConexionPostgresql(conexion)
    return

if __name__ == "__main__":
  main()