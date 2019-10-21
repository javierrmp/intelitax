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
        if len(comprobante.getAttribute('Subtotal')) == 0: 
            Subtotal = "0" 
        else: 
            Subtotal = comprobante.getAttribute('Subtotal')
        atributos['Subtotal'] = Subtotal
        if len(comprobante.getAttribute('Descuento')) == 0: 
            Descuento = "0" 
        else: 
            Descuento = comprobante.getAttribute('Descuento')
        atributos['Descuento'] = Descuento
        atributos['Moneda'] = comprobante.getAttribute('Moneda')
        if len(comprobante.getAttribute('TipoCambio')) == 0: 
            TipoCambio = "0" 
        else: 
            TipoCambio = comprobante.getAttribute('TipoCambio')
        atributos['TipoCambio'] = TipoCambio
        if len(comprobante.getAttribute('Total')) == 0: 
            Total = "0" 
        else: 
            Total = comprobante.getAttribute('Total')
        atributos['Total'] = Total
        atributos['TipoDeComprobante'] = comprobante.getAttribute('TipoDeComprobante')
        atributos['MetodoPago'] = comprobante.getAttribute('MetodoPago')
        atributos['LugarExpedicion'] = comprobante.getAttribute('LugarExpedicion')
        atributos['Confirmacion'] = comprobante.getAttribute('Confirmacion')

        emisores = comprobante.getElementsByTagName('cfdi:Emisor')
        for emisor in emisores:
            atributos['RfcEmisor'] = emisor.getAttribute('Rfc')
            atributos['NombreEmisor'] = emisor.getAttribute('Nombre')
            atributos['RegimenFiscal'] = emisor.getAttribute('RegimenFiscal')
        
        receptores = comprobante.getElementsByTagName('cfdi:Receptor')
        for receptor in receptores:
            atributos['RfcReceptor'] = receptor.getAttribute('Rfc')
            atributos['NombreReceptor'] = receptor.getAttribute('Nombre')
            atributos['ResidenciaFiscal'] = receptor.getAttribute('ResidenciaFiscal')
            atributos['NumRegIdTrib'] = receptor.getAttribute('NumRegIdTrib')
            atributos['UsoCFDI'] = receptor.getAttribute('UsoCFDI')

        hexlify = codecs.getencoder('hex')
        atributos['Certificado'] = str(hexlify(str(atributos['Certificado']).encode('utf-8'))[0])[0:5000]
        
        hexlify = codecs.getencoder('hex')
        atributos['Sello'] = str(hexlify(str(atributos['Sello']).encode('utf-8'))[0])[0:5000]

        print("**** GUARDANDO COMPROBANTE ***")
        cursor = connection.cursor()
        consulta = ""
        consulta = "INSERT INTO \"InfUsuario\".\"CFDICOMPROBANTE\"( "
        consulta = consulta + "\"VERSION\", \"SERIE\", \"FOLIO\", \"FECHA\", \"SELLO\", "
        consulta = consulta + "\"FORMAPAGO\", \"NOCERTIFICADO\", \"CERTIFICADO\", \"CONDICIONESDEPAGO\", \"SUBTOTAL\", "
        consulta = consulta + "\"DESCUENTO\", \"MONEDA\", \"TIPOCAMBIO\", \"TOTAL\", \"TIPODECOMPROBANTE\", "
        consulta = consulta + "\"METODOPAGO\", \"LUGAREXPEDICION\", \"CONFIRMACION\", \"RFCEMISOR\", \"NOMBREEMISOR\", "
        consulta = consulta + "\"REGIMENFISCAL\", \"RFCRECEPTOR\", \"NOMBRERECEPTOR\", \"RESIDENCIAFISICARECEPTOR\", \"NUMREGIDTRIBRECEPTOR\", "
        consulta = consulta + "\"USOCFDI\", \"CVE_DESCARGA\" )"

        consulta = consulta + " VALUES( "
        consulta = consulta + "'" + atributos['Version'] + "', '" + atributos['Serie'] + "' ,'" + atributos['Folio'] + "' ,'" + atributos['Fecha'] + "' ,'" + atributos['Sello'] + "', "
        consulta = consulta + "'" + atributos['FormaPago'] + "', '" + atributos['NoCertificado'] + "', '" + atributos['Certificado'] + "', '" + atributos['CondicionesDePago'] + "', '" + atributos['Subtotal'] + "', "
        consulta = consulta + "'" + atributos['Descuento'] + "', '" + atributos['Moneda'] + "', '" + atributos['TipoCambio'] + "', '" + atributos['Total'] + "', '" + atributos['TipoDeComprobante'] + "', "
        consulta = consulta + "'" + atributos['MetodoPago'] + "', '" + atributos['LugarExpedicion'] + "', '" + atributos['Confirmacion'] + "', '" + atributos['RfcEmisor'] + "', '" + atributos['NombreEmisor'] + "', "
        consulta = consulta + "'" + atributos['RegimenFiscal'] + "', '" + atributos['RfcReceptor'] + "', '" + atributos['NombreReceptor'] + "', '" + atributos['ResidenciaFiscal'] + "', '" + atributos['NumRegIdTrib'] + "', "
        consulta = consulta + "'" + atributos['UsoCFDI'] + "', '" + str(cvedescarga) + "'"
        consulta = consulta + ")"

        # print(consulta)
        cursor.execute(consulta)
        connection.commit()
        cursor.close()

        cursor = connection.cursor()
        consulta = ""
        consulta = "SELECT \"ID_COMPROBANTE\" FROM \"InfUsuario\".\"CFDICOMPROBANTE\" WHERE \"CVE_DESCARGA\" = '" + cvedescarga + "' AND \"NOCERTIFICADO\" = '" + atributos['NoCertificado'] + "' "
        cursor.execute(consulta)
        if not cursor.rowcount:
            print("FALLO LA CABECERA DEL COMPROBANTE")
            return
        else:
            RESULTADOS = cursor.fetchall()
            cursor.close()

        for row in RESULTADOS:
            if row[0] > 0:
                idcomprobante = row[0]

                conceptosPrincipal = comprobante.getElementsByTagName('cfdi:Conceptos')
                for conceptosNodo in conceptosPrincipal:
                    conceptos = conceptosNodo.getElementsByTagName('cfdi:Concepto')
                    for concepto in conceptos:
                        atributos['ClaveProdServ'] = concepto.getAttribute('ClaveProdServ')
                        atributos['NoIdentificacion'] = concepto.getAttribute('NoIdentificacion')
                        atributos['Cantidad'] = concepto.getAttribute('Cantidad')
                        atributos['ClaveUnidad'] = concepto.getAttribute('ClaveUnidad')
                        atributos['Unidad'] = concepto.getAttribute('Unidad')
                        atributos['Descripcion'] = concepto.getAttribute('Descripcion')
                        if len(concepto.getAttribute('ValorUnitario')) == 0: 
                            ValorUnitario = "0" 
                        else: 
                            ValorUnitario = concepto.getAttribute('ValorUnitario')
                        atributos['ValorUnitario'] = ValorUnitario
                        if len(concepto.getAttribute('Importe')) == 0: 
                            Importe = "0" 
                        else: 
                            Importe = concepto.getAttribute('Importe')
                        atributos['Importe'] = Importe
                        if len(concepto.getAttribute('Descuento')) == 0: 
                            Descuento = "0" 
                        else: 
                            Descuento = concepto.getAttribute('Descuento')
                        atributos['Descuento'] = Descuento

                        print("**** GUARDANDO CONCEPTOS ***")
                        cursor = connection.cursor()
                        consulta = ""
                        consulta = "INSERT INTO \"InfUsuario\".\"CFDICONCEPTOS\"( "
                        consulta = consulta + "\"CLAVEPRODSERV\", \"NOIDENTIFICACION\", \"CANTIDAD\", \"CLAVEUNIDAD\", \"UNIDAD\", "
                        consulta = consulta + "\"DESCRIPCION\", \"VALORUNITARIO\", \"IMPORTE\", \"DESCUENTO\", \"ID_COMPROBANTE\" )"
                        
                        consulta = consulta + " VALUES( "
                        consulta = consulta + "'" + atributos['ClaveProdServ'] + "', '" + atributos['NoIdentificacion'] + "', '" + atributos['Cantidad'] + "', '" + atributos['ClaveUnidad'] + "', '" + atributos['Unidad'] + "', "
                        consulta = consulta + "'" + atributos['Descripcion'] + "', '" + atributos['ValorUnitario'] + "', '" + atributos['Importe'] + "', '" + atributos['Descuento'] + "', '" + str(idcomprobante) + "'"
                        consulta = consulta + " )"
                        
                        #print(consulta)
                        cursor.execute(consulta)
                        connection.commit()
                        cursor.close()

                        cursor = connection.cursor()
                        consulta = ""
                        consulta = "SELECT \"ID_CONCEPTO\" FROM \"InfUsuario\".\"CFDICONCEPTOS\" WHERE \"ID_COMPROBANTE\" = '" + str(idcomprobante) + "' AND \"CLAVEPRODSERV\" = '" + atributos['ClaveProdServ'] + "' "
                        cursor.execute(consulta)
                        if not cursor.rowcount:
                            print("FALLO LA CABECERA DEL CONCEPTO")
                            return
                        else:
                            RESULTADOS = cursor.fetchall()
                            cursor.close()

                        for row in RESULTADOS:
                            if row[0] > 0:
                                idconcepto = row[0]

                                impuestosPrincipal = concepto.getElementsByTagName('cfdi:Impuestos')
                                for impuestosNodo in impuestosPrincipal:
                                    HayTraslados = 0
                                    HayRetenciones = 0

                                    trasladosPrincipal = impuestosNodo.getElementsByTagName('cfdi:Traslados')
                                    for trasladosNodo in trasladosPrincipal:
                                        traslados = trasladosNodo.getElementsByTagName('cfdi:Traslado')
                                        for traslado in traslados:
                                            HayTraslados = 1
                                            if len(traslado.getAttribute('Base')) == 0: 
                                                Base = "0" 
                                            else: 
                                                Base = traslado.getAttribute('Base')
                                            atributos['Base'] = Base
                                            atributos['Impuesto'] = traslado.getAttribute('Impuesto')
                                            atributos['TipoFactor'] = traslado.getAttribute('TipoFactor')
                                            if len(traslado.getAttribute('TasaOCuota')) == 0: 
                                                TasaOCuota = "0" 
                                            else: 
                                                TasaOCuota = traslado.getAttribute('TasaOCuota')
                                            atributos['TasaOCuota'] = TasaOCuota
                                            if len(traslado.getAttribute('Importe')) == 0: 
                                                Importe = "0" 
                                            else: 
                                                Importe = traslado.getAttribute('Importe')
                                            atributos['Importe'] = Importe

                                            print("**** GUARDANDO IMPUESTOS TRASLADADOS ***")
                                            cursor = connection.cursor()
                                            consulta = ""
                                            consulta = "INSERT INTO \"InfUsuario\".\"CFDICONCEPTOSIMPUESTOSTRASLADOS\"( "
                                            consulta = consulta + "\"BASE\", \"IMPUESTO\", \"TIPOFACTOR\", "
                                            consulta = consulta + "\"TASAOCUOTA\", \"IMPORTE\", \"ID_CONCEPTO\" )"
                                            
                                            consulta = consulta + " VALUES( "
                                            consulta = consulta + "'" + atributos['Base'] + "', '" + atributos['Impuesto'] + "', '" + atributos['TipoFactor'] + "', "
                                            consulta = consulta + "'" + atributos['TasaOCuota'] + "', '" + atributos['Importe'] + "', '" + str(idconcepto) + "' "
                                            consulta = consulta + " )"
                                            
                                            cursor.execute(consulta)
                                            connection.commit()
                                            cursor.close()

                                    retencionesPrincipal = impuestosNodo.getElementsByTagName('cfdi:Retenciones')
                                    for retencionesNodo in retencionesPrincipal:
                                        retenciones = retencionesNodo.getElementsByTagName('cfdi:Retencion')
                                        for retencion in retenciones:
                                            HayRetenciones = 1
                                            if len(retencion.getAttribute('Base')) == 0: 
                                                Base = "0" 
                                            else: 
                                                Base = retencion.getAttribute('Base')
                                            atributos['Base'] = Base
                                            atributos['Impuesto'] = retencion.getAttribute('Impuesto')
                                            atributos['TipoFactor'] = retencion.getAttribute('TipoFactor')
                                            if len(retencion.getAttribute('TasaOCuota')) == 0: 
                                                TasaOCuota = "0" 
                                            else: 
                                                TasaOCuota = retencion.getAttribute('TasaOCuota')
                                            atributos['TasaOCuota'] = TasaOCuota
                                            if len(retencion.getAttribute('Importe')) == 0: 
                                                Importe = "0" 
                                            else: 
                                                Importe = retencion.getAttribute('Importe')
                                            atributos['Importe'] = Importe

                                            print("**** GUARDANDO IMPUESTOS RETENCIONES ***")
                                            cursor = connection.cursor()
                                            consulta = ""
                                            consulta = "INSERT INTO \"InfUsuario\".\"CFDICONCEPTOSIMPUESTOSRETENCIONES\"( "
                                            consulta = consulta + "\"BASE\", \"IMPUESTO\", \"TIPOFACTOR\", "
                                            consulta = consulta + "\"TASAOCUOTA\", \"IMPORTE\", \"ID_CONCEPTO\" )"
                                            
                                            consulta = consulta + " VALUES( "
                                            consulta = consulta + "'" + atributos['Base'] + "', '" + atributos['Impuesto'] + "', '" + atributos['TipoFactor'] + "', "
                                            consulta = consulta + "'" + atributos['TasaOCuota'] + "', '" + atributos['Importe'] + "', '" + str(idconcepto) + "' "
                                            consulta = consulta + " )"

                                            cursor.execute(consulta)
                                            connection.commit()
                                            cursor.close()

                                    if HayTraslados == 1:
                                        impuestosNodo.parentNode.removeChild(impuestosNodo)
                                    if HayRetenciones == 1:
                                        retencionesNodo.parentNode.removeChild(retencionesNodo)

                impuestosPrincipal = comprobante.getElementsByTagName('cfdi:Impuestos')
                for impuestosNodo in impuestosPrincipal:
                    atributos['TotalImpuestosTrasladados'] = impuestosNodo.getAttribute('TotalImpuestosTrasladados')
                    trasladosPrincipal = impuestosNodo.getElementsByTagName('cfdi:Traslados')
                    for trasladosNodo in trasladosPrincipal:
                        traslados = trasladosNodo.getElementsByTagName('cfdi:Traslado')
                        for traslado in traslados:
                            atributos['Impuesto'] = traslado.getAttribute('Impuesto')
                            atributos['TipoFactor'] = traslado.getAttribute('TipoFactor')
                            if len(traslado.getAttribute('TasaOCuota')) == 0: 
                                TasaOCuota = "0" 
                            else: 
                                TasaOCuota = traslado.getAttribute('TasaOCuota')
                            atributos['TasaOCuota'] = TasaOCuota
                            if len(traslado.getAttribute('Importe')) == 0: 
                                Importe = "0" 
                            else: 
                                Importe = traslado.getAttribute('Importe')
                            atributos['Importe'] = Importe

                            print("**** GUARDANDO COMPROBANTE IMPUESTOS TRASLADADOS ***")
                            cursor = connection.cursor()
                            consulta = ""
                            consulta = "INSERT INTO \"InfUsuario\".\"CFDICOMPROBANTEIMPUESTOSTRASLADOS\"( "
                            consulta = consulta + "\"IMPUESTO\", \"TIPOFACTOR\", "
                            consulta = consulta + "\"TASAOCUOTA\", \"IMPORTE\", \"ID_COMPROBANTE\" )"
                            
                            consulta = consulta + " VALUES( "
                            consulta = consulta + "'" + atributos['Impuesto'] + "', '" + atributos['TipoFactor'] + "', "
                            consulta = consulta + "'" + atributos['TasaOCuota'] + "', '" + atributos['Importe'] + "', '" + str(idcomprobante) + "' "
                            consulta = consulta + " )"

                            cursor.execute(consulta)
                            connection.commit()
                            cursor.close()

                impuestosPrincipal = comprobante.getElementsByTagName('cfdi:Impuestos')
                for impuestosNodo in impuestosPrincipal:
                    atributos['TotalImpuestosRetenidos'] = impuestosNodo.getAttribute('TotalImpuestosRetenidos')
                    retencionesPrincipal = impuestosNodo.getElementsByTagName('cfdi:Retenciones')
                    for retencionesNodo in retencionesPrincipal:
                        retenciones = retencionesNodo.getElementsByTagName('cfdi:Retencion')
                        for retencion in retenciones:
                            atributos['Impuesto'] = retencion.getAttribute('Impuesto')
                            if len(retencion.getAttribute('Importe')) == 0: 
                                Importe = "0" 
                            else: 
                                Importe = retencion.getAttribute('Importe')
                            atributos['Importe'] = Importe

                            print("**** GUARDANDO COMPROBANTE IMPUESTOS RETENIDOS ***")
                            cursor = connection.cursor()
                            consulta = ""
                            consulta = "INSERT INTO \"InfUsuario\".\"CFDICOMPROBANTEIMPUESTOSRETENIDOS\"( "
                            consulta = consulta + "\"IMPUESTO\", "
                            consulta = consulta + "\"IMPORTE\", \"ID_COMPROBANTE\" )"
                            
                            consulta = consulta + " VALUES( "
                            consulta = consulta + "'" + atributos['Impuesto'] + "', "
                            consulta = consulta + "'" + atributos['Importe'] + "', '" + str(idcomprobante) + "' "
                            consulta = consulta + " )"

                            cursor.execute(consulta)
                            connection.commit()
                            cursor.close()

                complementosPrincipal = comprobante.getElementsByTagName('cfdi:Complemento')
                for complementoNodo in complementosPrincipal:
                    complementos = complementoNodo.getElementsByTagName('tfd:TimbreFiscalDigital')
                    for complemento in complementos:
                        atributos['Version'] = complemento.getAttribute('Version')
                        atributos['SelloCFD'] = complemento.getAttribute('SelloCFD')
                        atributos['NoCertificadoSAT'] = complemento.getAttribute('NoCertificadoSAT')
                        atributos['RfcProvCertif'] = complemento.getAttribute('RfcProvCertif')
                        atributos['UUID'] = complemento.getAttribute('UUID')
                        atributos['FechaTimbrado'] = complemento.getAttribute('FechaTimbrado')
                        atributos['SelloSAT'] = complemento.getAttribute('SelloSAT')

                        hexlify = codecs.getencoder('hex')
                        atributos['SelloCFD'] = str(hexlify(str(atributos['SelloCFD']).encode('utf-8'))[0])[0:5000]

                        hexlify = codecs.getencoder('hex')
                        atributos['SelloSAT'] = str(hexlify(str(atributos['SelloSAT']).encode('utf-8'))[0])[0:5000]

                        print("**** GUARDANDO COMPROBANTE COMPLEMENTOS ***")
                        cursor = connection.cursor()
                        consulta = ""
                        consulta = "INSERT INTO \"InfUsuario\".\"CFDICOMPROBANTECOMPLEMENTO\"( "
                        consulta = consulta + "\"SELLOCFD\", \"NOCERTIFICADOSAT\", \"RFCPROVCERTIF\", \"UUID\", \"FECHATIMBRADO\", "
                        consulta = consulta + "\"SELLOSAT\", \"VERSION\", \"ID_COMPROBANTE\" )"
                        
                        consulta = consulta + " VALUES( "
                        consulta = consulta + "'" + atributos['SelloCFD'] + "', '" + atributos['NoCertificadoSAT'] + "', '" + atributos['RfcProvCertif'] + "', '" + atributos['UUID'] + "', '" + atributos['FechaTimbrado'] + "', "
                        consulta = consulta + "'" + atributos['SelloSAT'] + "', '" + atributos['Version'] + "', '" + str(idcomprobante) + "' "
                        consulta = consulta + " )"
                        
                        #print(consulta)
                        cursor.execute(consulta)
                        connection.commit()
                        cursor.close()
                    
                    pagosPrincipal = complementoNodo.getElementsByTagName('pago10:Pagos')
                    for pagosNodo in pagosPrincipal:
                        atributos['Version'] = pagosNodo.getAttribute('Version')
                        
                        pagos = pagosNodo.getElementsByTagName('pago10:Pago')
                        for pago in pagos:
                            atributos['FechaPago'] = pago.getAttribute('FechaPago')
                            atributos['FormaDePagoP'] = pago.getAttribute('FormaDePagoP')
                            atributos['MonedaP'] = pago.getAttribute('MonedaP')
                            atributos['Monto'] = pago.getAttribute('Monto')
                            atributos['RfcEmisorCtaBen'] = pago.getAttribute('RfcEmisorCtaBen')
                            atributos['CtaBeneficiario'] = pago.getAttribute('CtaBeneficiario')

                            print("**** GUARDANDO COMPROBANTE PAGOS ***")
                            cursor = connection.cursor()
                            consulta = ""
                            consulta = "INSERT INTO \"InfUsuario\".\"CFDICOMPROBANTECOMPLEMENTOPAGOS\"( "
                            consulta = consulta + "\"FECHAPAGO\", \"FORMADEPAGOP\", \"MONEDAP\", \"MONTO\", \"RFCEMISORCTABEN\", "
                            consulta = consulta + "\"CTABENEFICIARIO\", \"ID_COMPROBANTE\" )"
                            
                            consulta = consulta + " VALUES( "
                            consulta = consulta + "'" + atributos['FechaPago'] + "', '" + atributos['FormaDePagoP'] + "', '" + atributos['MonedaP'] + "', '" + atributos['Monto'] + "', '" + atributos['RfcEmisorCtaBen'] + "', "
                            consulta = consulta + "'" + atributos['CtaBeneficiario'] + "', '" + str(idcomprobante) + "' "
                            consulta = consulta + " )"
                            
                            #print(consulta)
                            cursor.execute(consulta)
                            connection.commit()
                            cursor.close()

                            cursor = connection.cursor()
                            consulta = ""
                            consulta = "SELECT \"ID_PAGO\" FROM \"InfUsuario\".\"CFDICOMPROBANTECOMPLEMENTOPAGOS\" WHERE \"ID_COMPROBANTE\" = '" + str(idcomprobante) + "' AND \"RFCEMISORCTABEN\" = '" + atributos['RfcEmisorCtaBen'] + "' "
                            cursor.execute(consulta)
                            if not cursor.rowcount:
                                print("FALLO LA CABECERA DEL PAGO")
                                return
                            else:
                                RESULTADOS = cursor.fetchall()
                                cursor.close()

                            for row in RESULTADOS:
                                if row[0] > 0:
                                    idpago = row[0]

                                    docrelacionados = pago.getElementsByTagName('pago10:DoctoRelacionado')
                                    for docrelacionado in docrelacionados:
                                        atributos['IdDocumento'] = docrelacionado.getAttribute('IdDocumento')
                                        atributos['Serie'] = docrelacionado.getAttribute('Serie')
                                        atributos['Folio'] = docrelacionado.getAttribute('Folio')
                                        atributos['MonedaDR'] = docrelacionado.getAttribute('MonedaDR')
                                        atributos['MetodoDePagoDR'] = docrelacionado.getAttribute('MetodoDePagoDR')
                                        atributos['NumParcialidad'] = docrelacionado.getAttribute('NumParcialidad')
                                        atributos['ImpSaldoAnt'] = docrelacionado.getAttribute('ImpSaldoAnt')
                                        atributos['ImpPagado'] = docrelacionado.getAttribute('ImpPagado')
                                        atributos['ImpSaldoInsoluto'] = docrelacionado.getAttribute('ImpSaldoInsoluto')

                                        print("**** GUARDANDO COMPROBANTE PAGOS ***")
                                        cursor = connection.cursor()
                                        consulta = ""
                                        consulta = "INSERT INTO \"InfUsuario\".\"CFDICOMPROBANTECOMPLEMENTOPAGOSDOCS\"( "
                                        consulta = consulta + "\"IDDOCUMENTO\", \"SERIE\", \"FOLIO\", \"MONEDADR\", \"METODODEPAGODR\", "
                                        consulta = consulta + "\"NUMPARCIALIDAD\", \"IMPSALDOANT\",\"IMPPAGADO\",\"IMPSALDOINSOLUTO\", \"ID_PAGO\" )"
                                        
                                        consulta = consulta + " VALUES( "
                                        consulta = consulta + "'" + atributos['IdDocumento'] + "', '" + atributos['Serie'] + "', '" + atributos['Folio'] + "', '" + atributos['MonedaDR'] + "', '" + atributos['MetodoDePagoDR'] + "', "
                                        consulta = consulta + "'" + atributos['NumParcialidad'] + "', '" + atributos['ImpSaldoAnt'] + "', '" + atributos['ImpPagado'] + "', '" + atributos['ImpSaldoInsoluto'] + "', '" + str(idpago) + "' "
                                        consulta = consulta + " )"
                                        
                                        #print(consulta)
                                        cursor.execute(consulta)
                                        connection.commit()
                                        cursor.close()



                relacionadosPrincipal = comprobante.getElementsByTagName('cfdi:CfdiRelacionados')
                for relacionadosNodo in relacionadosPrincipal:
                    atributos['TipoRelacion'] = relacionadosNodo.getAttribute('TipoRelacion')
                    relacionados = relacionadosNodo.getElementsByTagName('fdi:CfdiRelacionado')
                    for relacionado in relacionados:
                        atributos['UUID'] = relacionado.getAttribute('UUID')
                        
                        print("**** GUARDANDO COMPROBANTE COMPLEMENTOS ***")
                        cursor = connection.cursor()
                        consulta = ""
                        consulta = "INSERT INTO \"InfUsuario\".\"CFDICOMPROBANTERELACIONADOS\"( "
                        consulta = consulta + "\"TIPORELACION\", \"UUID\", "
                        consulta = consulta + "\"ID_COMPROBANTE\" )"
                        
                        consulta = consulta + " VALUES( "
                        consulta = consulta + "'" + atributos['TipoRelacion'] + "', '" + atributos['UUID'] + "', "
                        consulta = consulta + "'" + str(idcomprobante) + "' "
                        consulta = consulta + " )"
                        
                        #print(consulta)
                        cursor.execute(consulta)
                        connection.commit()
                        cursor.close()

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
        
        #print(consulta)
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

            print("**** INHABILITA PERIODOS POSIBLEMENTE REPETIDOS ***")
            cursor = conexion.cursor()
            consulta = "UPDATE \"BaseSistema\".\"LOGCARGAXML\" SET \"STATUSPERIODO\" = 39 WHERE \"STATUS\" = 36 AND \"STATUSPERIODO\" = 38 AND \"PERIODO\" = '" + str(period) + "' "
            cursor.execute(consulta)
            conexion.commit()
            cursor.close()

            # print("**** MARCANDO INFORMACION XML ***")
            # cursor = conexion.cursor()
            # consulta = "CALL \"BaseSistema\".\"MarcaXML\"('" + str(CVE_DESCARGA) + "', " + str(idrfc) + ", '" + str(period) + "')"
            # cursor.execute(consulta)
            # conexion.commit()
            # cursor.close()

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
