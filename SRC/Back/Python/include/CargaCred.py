#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os.path
import datetime
import os
import psycopg2
import hashlib
import codecs
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

def CerrarConexionPostgresql(connection):
    if(connection):

        connection.close()
        return True

def main(argv):
    
    if len(sys.argv) < 3:
        print("INGRESE ENTRE COMILLAS DOBLES, EL NUMERO DE RFC ASOCIADO QUE VA A SUBIR SUS CREDENCIALES Y EL PASSWORD")
        return

    if sys.argv[1] == "":
        print("INGRESE ENTRE COMILLAS DOBLES, EL NUMERO DE RFC ASOCIADO QUE VA A SUBIR SUS CREDENCIALES")
        return

    if sys.argv[2] == "":
        print("INGRESE ENTRE COMILLAS DOBLES, EL PASSWORD")
        return

    hexlify = codecs.getencoder('hex')
    sys.argv[2] = str(hexlify(str(sys.argv[2]).encode('utf-8'))[0])[0:5000]

    Ruta = os.getcwd()
    Archivos = os.listdir(Ruta)

    print("**** VALIDANDO ARCHIVOS ***")

    bExisteCer = False
    bExisteKey = False

    for file in Archivos:
        Archivo = file

        if True in (Archivo.endswith('.cer'), Archivo.endswith('.cer')):
            sNombreCer = Archivo
            bExisteCer = True
            break

    for file in Archivos:
        Archivo = file

        if True in (Archivo.endswith('.key'), Archivo.endswith('.key')):
            sNombreKey = Archivo
            bExisteKey = True
            break

    if bExisteCer == False:
        print("FALTA EL CERTIFICADO")
        return

    if bExisteKey == False:
        print("FALTA LA LLAVE")
        return

    conexion = AbrirConexionPostgresql()

    cursor = conexion.cursor()
    consulta = ""
    consulta = "SELECT \"ID_RFC\" FROM \"BaseSistema\".\"CFGCLTESRFC\" WHERE \"RFC\" = '" + sys.argv[1] + "' AND \"STATUS\" = 5;"
    cursor.execute(consulta)
    if not cursor.rowcount:
        print("EL RFC QUE INGRESO NO EXISTE O ESTA CANCELADO")
        return
    else:
        RESULTADOS = cursor.fetchall()
        cursor.close()

    for row in RESULTADOS:
        idrfc = row

    msg = "Archivos: %s y %s" % (sNombreCer, sNombreKey)
    print(msg)

    msg = "Los siguientes archivos van a ser cargados al RFC: %s" % sys.argv[1]
    # msg = msg + " es correcto (y/n)"
    # resp = input(msg)

    # if resp == "n":
    #     return

    print("**** CARGANDO CREDENCIALES ***")
    print(strftime("%a, %d %b %Y %H:%M:%S", localtime()))

    cursor = conexion.cursor()
    consulta = ""
    consulta = "CALL \"BaseSistema\".\"CargaCredenciales\" ('" 
    consulta = consulta + str(idrfc[0]) + "', '" + sys.argv[2] + "', '" + Ruta + "', '" + sNombreKey + "', '" + sNombreCer + "', '" + "7" +  "')"
    cursor.execute(consulta)
    conexion.commit()
    cursor.close()
    
    cursor = conexion.cursor()
    consulta = ""
    consulta = "SELECT \"ID_CRED\" FROM \"BaseSistema\".\"CFGCLTESCREDENCIALES\" WHERE \"ID_RFC\" = '" + str(idrfc[0]) + "' AND \"PASS\" = '" + sys.argv[2]+ "';"
    cursor.execute(consulta)
    RESULTADOS = cursor.fetchall()
    cursor.close()

    if RESULTADOS[0][0] > 0:
        print('CARGA DE ARCHIVOS EXITOSA')
        os.remove(sNombreCer)
        os.remove(sNombreKey)

    statusCerrada = CerrarConexionPostgresql(conexion)

    print(strftime("%a, %d %b %Y %H:%M:%S", localtime()))

    if statusCerrada == True:
        return "CREDENCIALES CARGADAS"

if __name__ == "__main__":
  main(sys.argv[1:])