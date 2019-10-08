#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, getopt
import os.path
import datetime
import os
import psycopg2
import shlex
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
        
        xmlDoc = minidom.parse(nomFileXml)
        nodes = xmlDoc.childNodes
        comprobante = nodes[0]

        atributos = dict()
        atributos['Version'] = comprobante.getAttribute('Version')
        atributos['Serie'] = comprobante.getAttribute('Serie')
        atributos['Folio'] = comprobante.getAttribute('Folio')
        atributos['Fecha'] = comprobante.getAttribute('Fecha')
        atributos['Sello'] = comprobante.getAttribute('Sello')
        atributos['FormaPago'] = comprobante.getAttribute('FormaPago')
        atributos['NoCertificado'] = comprobante.getAttribute('NoCertificado')
        atributos['Certificado'] = comprobante.getAttribute('Certificado')
        atributos['CondicionesDePago'] = comprobante.getAttribute('CondicionesDePago')
        atributos['Subtotal'] = comprobante.getAttribute('Subtotal')
        atributos['Descuento'] = comprobante.getAttribute('Descuento')
        atributos['Moneda'] = comprobante.getAttribute('Moneda')
        atributos['TipoCambio'] = comprobante.getAttribute('TipoCambio')
        atributos['Total'] = comprobante.getAttribute('Total')
        atributos['TipoDeComprobante'] = comprobante.getAttribute('TipoDeComprobante')
        atributos['MetodoPago'] = comprobante.getAttribute('MetodoPago')
        atributos['LugarExpedicion'] = comprobante.getAttribute('LugarExpedicion')
        atributos['Confirmacion'] = comprobante.getAttribute('Confirmacion')

        emisor = comprobante.getElementsByTagName('cfdi:Emisor')
        atributos['RfcEmisor'] = emisor.getAttribute('Rfc')
        atributos['NombreEmisor'] = emisor.getAttribute('Nombre')
        atributos['RegimenFiscal'] = emisor.getAttribute('RegimenFiscal')

        receptor = comprobante.getElementsByTagName('cfdi:Receptor')
        atributos['RfcReceptor'] = receptor.getAttribute('Rfc')
        atributos['NombreReceptor'] = receptor.getAttribute('Nombre')
        atributos['ResidenciaFiscal'] = receptor.getAttribute('ResidenciaFiscal')
        atributos['NumRegIdTrib'] = receptor.getAttribute('NumRegIdTrib')
        atributos['UsoCFDI'] = receptor.getAttribute('UsoCFDI')

        impuestos = comprobante.getElementsByTagName("cfdi:Impuestos")
        atributos['TotalImpuestosRetenidos'] = impuestos.getAttribute('TotalImpuestosRetenidos')
        atributos['TotalImpuestosTrasladados'] = impuestos.getAttribute('TotalImpuestosTrasladados')

        traslados = impuestos.getElementsByTagName("cfdi:Traslados")
        traslado = traslados.getElementsByTagName("cfdi:Traslado")
        atributos['Impuesto'] = traslado.getAttribute('Impuesto')
        atributos['TipoFactor'] = traslado.getAttribute('TipoFactor')
        atributos['TasaOCuota'] = traslado.getAttribute('TasaOCuota')
        atributos['Importe'] = traslado.getAttribute('Importe')
        
        retenciones = impuestos.getElementsByTagName("cfdi:Retenciones")
        retencion = retenciones.getElementsByTagName("cfdi:Retencion")
        atributos['Impuesto'] = retencion.getAttribute('Impuesto')
        atributos['Importe'] = retencion.getAttribute('Importe')


        relacionados = comprobante.getElementsByTagName('cfdi:CfdiRelacionados')
        atributos['TipoRelacion'] = relacionados[0].getAttribute('TipoRelacion')
        relacionado = relacionados.getElementsByTagName("cfdi:CfdiRelacionado")
        for relacion in relacionado:
            atributos['UUID'] = relacion.getElementsByTagName('UUID')[0]

        conceptos = comprobante.getElementsByTagName('cfdi:Conceptos')
        for concepto in conceptos:
            atributos['ClaveProdServ'] = concepto.getAttribute('ClaveProdServ')
            atributos['NoIdentificacion'] = concepto.getAttribute('NoIdentificacion')
            atributos['Cantidad'] = concepto.getAttribute('Cantidad')
            atributos['ClaveUnidad'] = concepto.getAttribute('ClaveUnidad')
            atributos['Unidad'] = concepto.getAttribute('Unidad')
            atributos['Descripcion'] = concepto.getAttribute('Descripcion')
            atributos['ValorUnitario'] = concepto.getAttribute('ValorUnitario')
            atributos['Importe'] = concepto.getAttribute('Importe')
            atributos['Descuento'] = concepto.getAttribute('Descuento')
            impuestos = conceptos.getElementsByTagName('cfdi:Impuestos')
            for impuesto in impuestos:
                traslados = impuesto.getElementsByTagName("cfdi:Traslados")
                for traslado in traslados:
                    atributos['Base'] = traslado.getAttribute('Base')
                    atributos['Impuesto'] = traslado.getAttribute('Impuesto')
                    atributos['TipoFactor'] = traslado.getAttribute('TipoFactor')
                    atributos['TasaOCuota'] = traslado.getAttribute('TasaOCuota')
                    atributos['Importe'] = traslado.getAttribute('Importe')
                retenciones = impuesto.getElementsByTagName('cfdi:Retenciones')
                for retencion in retenciones:
                    atributos['Base'] = retencion.getAttribute('Base')
                    atributos['Impuesto'] = retencion.getAttribute('Impuesto')
                    atributos['TipoFactor'] = retencion.getAttribute('TipoFactor')
                    atributos['TasaOCuota'] = retencion.getAttribute('TasaOCuota')
                    atributos['Importe'] = retencion.getAttribute('Importe')
                informacionAduaneras = impuesto.getElementsByTagName("cfdi:InformacionAduanera")
                for informacionAduanera in informacionAduaneras:
                    atributos['NumeroPedimento'] = informacionAduanera.getAttribute('NumeroPedimento')
                cuentasPrediales = impuesto.getElementsByTagName("cfdi:CuentaPredial")
                for cuentapredial in cuentasPrediales:
                    atributos['Numero'] = cuentapredial.getAttribute('Numero')
            complementoconceptos = conceptos.getElementsByTagName('cfdi:ComplementoConcepto')
            partes = complementoconceptos.getElementsByTagName("cfdi:Parte")
            for parte in partes:
                atributos['ClaveProdServ'] = parte.getAttribute('ClaveProdServ')
                atributos['NoIdentificacion'] = parte.getAttribute('NoIdentificacion')
                atributos['Cantidad'] = parte.getAttribute('Cantidad')
                atributos['Unidad'] = parte.getAttribute('Unidad')
                atributos['Descripcion'] = parte.getAttribute('Descripcion')
                atributos['ValorUnitario'] = parte.getAttribute('ValorUnitario')
                atributos['Importe'] = parte.getAttribute('Importe')
                atributos['NumeroPedimento'] = parte.getAttribute('NumeroPedimento')
                partes = complementoconceptos.getElementsByTagName("cfdi:Parte")

        Traslados = Impuestos[Impuestos.length-1].getElementsByTagName("cfdi:Traslado")
        for Traslado in Traslados:
            atributos['Impuesto'] = Traslado.getAttribute('Impuesto')
            atributos['TipoFactor'] = Traslado.getAttribute('TipoFactor')
            atributos['TasaOCuota'] = Traslado.getAttribute('TasaOCuota')
            atributos['Importe'] = Traslado.getAttribute('Importe')
        Retenciones = Impuestos[Impuestos.length-1].getElementsByTagName("cfdi:Retencion")
        for Retencion in Retenciones:
            atributos['Base'] = Retencion.getAttribute('Base')
            atributos['Impuesto'] = Retencion.getAttribute('Impuesto')
            atributos['TipoFactor'] = Retencion.getAttribute('TipoFactor')
            atributos['TasaOCuota'] = Retencion.getAttribute('TasaOCuota')
            atributos['Importe'] = Retencion.getAttribute('Importe')
   




        # Conceptos = comprobante.getElementsByTagName("cfdi:Concepto")
        # for Concepto in Conceptos:
        #     atributos['ClaveProdServ'] = Concepto.getAttribute('ClaveProdServ')
        #     atributos['NoIdentificacion'] = Concepto.getAttribute('NoIdentificacion')
        #     atributos['Cantidad'] = Concepto.getAttribute('Cantidad')
        #     atributos['ClaveUnidad'] = Concepto.getAttribute('ClaveUnidad')
        #     atributos['Unidad'] = Concepto.getAttribute('Unidad')
        #     atributos['Descripcion'] = Concepto.getAttribute('Descripcion')
        #     atributos['ValorUnitario'] = Concepto.getAttribute('ValorUnitario')
        #     atributos['Importe'] = Concepto.getAttribute('Importe')
        #     atributos['Descuento'] = Concepto.getAttribute('Descuento')
        #     Traslados = Concepto.getElementsByTagName("cfdi:Traslado")
        #     for Traslado in Traslados:
        #         atributos['Base'] = Traslado.getAttribute('Base')
        #         atributos['Impuesto'] = Traslado.getAttribute('Impuesto')
        #         atributos['TipoFactor'] = Traslado.getAttribute('TipoFactor')
        #         atributos['TasaOCuota'] = Traslado.getAttribute('TasaOCuota')
        #         atributos['Importe'] = Traslado.getAttribute('Importe')
            


        # cursor = connection.cursor()
        # cursor.callproc('CargaCfdiComprobante',[
        #     atributos['Version'],
        #     atributos['Serie'],
        #     atributos['Folio'],
        #     atributos['Fecha'],
        #     atributos['Sello'],
        #     atributos['FormaPago'],
        #     atributos['NoCertificado'],
        #     atributos['Certificado'],
        #     atributos['CondicionesDePago'],
        #     atributos['Subtotal'],
        #     atributos['Descuento'],
        #     atributos['Moneda'],
        #     atributos['TipoCambio'],
        #     atributos['Total'],
        #     atributos['TipoDeComprobante'],
        #     atributos['MetodoPago'],
        #     atributos['LugarExpedicion'],
        #     atributos['Confirmacion'],
        #     atributos['RfcEmisor'],
        #     atributos['NombreEmisor'],
        #     atributos['RegimenFiscal'],
        #     atributos['RfcReceptor'],
        #     atributos['NombreReceptor'],
        #     atributos['ResidenciaFiscal'],
        #     atributos['NumRegIdTrib'],
        #     atributos['UsoCFDI'],
        #     atributos['TotalImpuestosRetenidos'],
        #     atributos['TotalImpuestosTrasladados'],
        #     cvedescarga,
        #             ])
        # result = cursor.fetchall()
        # for row in result:
        #     Id_Comprobante = row[0]
        #     print(Id_Comprobante)        

        
        
        

    except (Exception, psycopg2.DatabaseError) as error :
        print ("Error mientras se guardaban los datos", error)

    finally:
        return atributos

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
    msgFormato = "CargaXML.py -r <rfc>"

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
            CVE_DESCARGA = strftime("%Y%m%d%H%M%S", localtime())

            print("**** VALIDANDO INFORMACION XML ***")

            cursor = conexion.cursor()
            consulta = "UPDATE \"BaseSistema\".\"LOGDESCARGAWSAUTH\" SET \"CVE_CARGA\" = '" + str(CVE_DESCARGA) + "' "
            consulta = consulta + "WHERE \"ID_DESCARGAWS\" = ( "
            consulta = consulta + "SELECT \"ID_DESCARGAWS\" FROM \"BaseSistema\".\"LOGDESCARGAWSAUTH\" "
            consulta = consulta + "WHERE \"ID_RFC\" = '" + str(idrfc) + "' AND \"TIPO\" = 'CFDI' AND \"STATUS\" = 31 AND \"MSGERROR\" <> '' AND \"CVE_CARGA\" IS NULL "
            consulta = consulta + "ORDER BY \"ID_DESCARGAWS\" LIMIT 2 "
            consulta = consulta + ")"
            cursor.execute(consulta)
            conexion.commit()
            cursor.close()

            cursor = conexion.cursor()
            consulta = "SELECT \"ID_DESCARGAWS\", \"MSGERROR\" FROM \"BaseSistema\".\"LOGDESCARGAWSAUTH\" "
            consulta = consulta + "WHERE \"ID_RFC\" = '" + str(idrfc) + "' AND \"TIPO\" = 'CFDI' AND \"STATUS\" = 31 AND \"MSGERROR\" <> '' AND \"CVE_CARGA\" = '" + str(CVE_DESCARGA) + "'  "
            consulta = consulta + "ORDER BY \"ID_DESCARGAWS\" "
            cursor.execute(consulta)
            if not cursor.rowcount:
                print("NO SE ENCONTRO EL REGISTRO DEL XML")
                return
            else:
                RESULTADOS2 = cursor.fetchall()
                cursor.close()

            for row2 in RESULTADOS2:
                try:
                    #idDescarga = str(row2[0])
                    strArchivo = str(row2[1]) + '.zip'

                    comando = 'unzip -o ' + str(strArchivo) 
                    args = shlex.split(comando)
                    run(args)

                    with ZipFile(str(strArchivo), 'r') as zipObj:
                        listOfiles = zipObj.namelist()
                        for elem in listOfiles:
                            strArchivotxt = elem
                            
                            print("**** PROCESANDO ***", strArchivotxt)

                            stat = getAtributos(conexion, strArchivotxt, str(CVE_DESCARGA))

                            print("**** LIMPIANDO TEMPORALES ***")
                            os.remove(strArchivotxt)

                    if stat == 1:
                        bError = 0

                except (psycopg2.Error, RuntimeError, TypeError, NameError, OSError, ValueError, Exception) as error :
                    if bError == 1:
                        print("**** ERROR EN LA CARGA DEL XML ***")    
                        print(error)

                finally:
                    statusCerrada = CerrarConexionPostgresql(conexion)

                    print(strftime("%a, %d %b %Y %H:%M:%S", localtime()))

                    if statusCerrada == True:
                        return "ARCHIVOS CARGADOS"

if __name__ == "__main__":
    main()
