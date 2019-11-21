<?php
function Car() {
    $argumentos = getopt("a:c:", array(
        "archivo:",
        "clave:",
        ));

    if (
        !isset($argumentos["a"]) || isset($argumentos["archivo"])
        ||
        !isset($argumentos["c"]) || isset($argumentos["clave"])
    )   {
        exit("Modo de uso:
            -a --archivo   archivo
            -c --clave  clave
            ");
        }

    $archivo = isset($argumentos["a"]) ? $argumentos["a"] : $argumentos["archivo"];
    $clave = isset($argumentos["c"]) ? $argumentos["c"] : $argumentos["clave"];

    if (file_exists($archivo)) {
        $xml = simplexml_load_file($archivo);
    } else {
        exit('Error abriendo factura');
    }

    $dbconn = pg_connect("host=127.0.0.1 dbname=BaseGrit user=postgres password=SaraDan1")
    or die('No se ha podido conectar: ' . pg_last_error());    

    $ns = $xml->getNamespaces(true);
    $xml->registerXPathNamespace('t', $ns['tfd']);
    $xml->registerXPathNamespace('p', $ns['pago10']);

    foreach ($xml->xpath('//cfdi:Comprobante') as $Datos){ 
        $val1 = $Datos['Descuento'] ?? '0';
        $val2 = $Datos['TipoCambio'] ?? '0';

        $query = 'INSERT INTO "InfUsuario"."CFDICOMPROBANTE"( ';
        $query = $query.'"LUGAREXPEDICION", "METODOPAGO", "TIPODECOMPROBANTE", "TOTAL", "MONEDA", ';
        $query = $query.'"CERTIFICADO", "SUBTOTAL", "CONDICIONESDEPAGO", "NOCERTIFICADO", ';
        $query = $query.'"FORMAPAGO", "SELLO", "FECHA", "VERSION", "SERIE", "FOLIO", "TIPOCAMBIO", "DESCUENTO", "CVE_DESCARGA" ) ';
        $query = $query.'VALUES( ';

        $query = $query.'\''.$Datos['LugarExpedicion'].'\', ';
        $query = $query.'\''.$Datos['MetodoPago'].'\', ';
        $query = $query.'\''.$Datos['TipoDeComprobante'].'\', ';
        $query = $query.'\''.$Datos['Total'].'\', ';
        $query = $query.'\''.$Datos['Moneda'].'\', ';
        $query = $query.'\''.$Datos['Certificado'].'\', ';
        $query = $query.'\''.$Datos['SubTotal'].'\', ';
        $query = $query.'\''.$Datos['CondicionesDePago'].'\', ';
        $query = $query.'\''.$Datos['NoCertificado'].'\', ';
        $query = $query.'\''.$Datos['FormaPago'].'\', ';
        $query = $query.'\''.$Datos['Sello'].'\', ';
        $query = $query.'\''.$Datos['Fecha'].'\', ';
        $query = $query.'\''.$Datos['Version'].'\', ';
        $query = $query.'\''.$Datos['Serie'].'\', ';
        $query = $query.'\''.$Datos['Folio'].'\', ';
        $query = $query.'\''.$val2.'\', ';
        $query = $query.'\''.$val1.'\', ';
        $query = $query.'\''.$clave.'\' ';

        $query = $query.' ) ';

        // echo '**************** CFDICOMPROBANTE *************************';
        // echo '\n';
        // echo $query;
        // echo '\n';

        $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
        pg_free_result($result);

        $query = 'SELECT "ID_COMPROBANTE" FROM "InfUsuario"."CFDICOMPROBANTE" WHERE "CVE_DESCARGA" = ';
        $query = $query.'\''.$clave.'\' AND "NOCERTIFICADO" = ';
        $query = $query.'\''.$Datos['NoCertificado'].'\' ';

        $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
        while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
            foreach ($line as $col_value) {
                $ID_COMPROBANTE = $col_value;
            }
        }

        foreach ($xml->xpath('//cfdi:Comprobante//cfdi:Emisor') as $Datos){ 
            $query = 'UPDATE "InfUsuario"."CFDICOMPROBANTE" SET ';
            $query = $query.'"RFCEMISOR" = \''.$Datos['Rfc'].'\', ';
            $query = $query.'"NOMBREEMISOR" = \''.$Datos['Nombre'].'\', ';
            $query = $query.'"REGIMENFISCAL" = \''.$Datos['RegimenFiscal'].'\' ';
            $query = $query.'WHERE "ID_COMPROBANTE" = '.'\''.$ID_COMPROBANTE.'\' ';

            // echo '**************** CFDICOMPROBANTE:Emisor *************************';
            // echo '\n';
            // echo $query;
            // echo '\n';
            $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
            pg_free_result($result);
        }
        
        foreach ($xml->xpath('//cfdi:Comprobante//cfdi:Receptor') as $Datos){ 
            $query = 'UPDATE "InfUsuario"."CFDICOMPROBANTE" SET ';
            $query = $query.'"RFCRECEPTOR" = \''.$Datos['Rfc'].'\', ';
            $query = $query.'"NOMBRERECEPTOR" = \''.$Datos['Nombre'].'\', ';
            $query = $query.'"USOCFDI" = \''.$Datos['UsoCFDI'].'\' ';
            $query = $query.'WHERE "ID_COMPROBANTE" = '.'\''.$ID_COMPROBANTE.'\' ';

            // echo '**************** CFDICOMPROBANTE:Receptor *************************';
            // echo '\n';
            // echo $query;
            // echo '\n';
            $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
            pg_free_result($result);
        }

        foreach ($xml->xpath('//cfdi:Comprobante//cfdi:CfdiRelacionados') as $Datos){ 
            $query = 'INSERT INTO "InfUsuario"."CFDICOMPROBANTERELACIONADOS"( ';
            $query = $query.'"TIPORELACION", ';
            $query = $query.'"ID_COMPROBANTE" ) ';
            $query = $query.'VALUES( ';

            $query = $query.'\''.$Datos['TipoRelacion'].'\', ';
            $query = $query.'\''.$ID_COMPROBANTE.'\' ';

            $query = $query.' ) ';

            // echo '**************** CFDICOMPROBANTERELACIONADOS *************************';
            // echo '\n';
            // echo $query;
            // echo '\n';
            $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
            pg_free_result($result);

            $query = 'SELECT "ID_RELACIONADOS" FROM "InfUsuario"."CFDICOMPROBANTERELACIONADOS" WHERE "ID_COMPROBANTE" = ';
            $query = $query.'\''.$ID_COMPROBANTE.'\' AND "TIPORELACION" = ';
            $query = $query.'\''.$Datos['TipoRelacion'].'\' ';

            $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
            while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
                foreach ($line as $col_value) {
                    $ID_RELACIONADOS = $col_value;
                }
            }

            pg_free_result($result);

            foreach ($xml->xpath('//cfdi:Comprobante//cfdi:CfdiRelacionados//cfdi:CfdiRelacionado') as $Datos){ 
                $query = 'UPDATE "InfUsuario"."CFDICOMPROBANTERELACIONADOS" SET ';
                $query = $query.'"UUID" = \''.$Datos['UUID'].'\' ';
                $query = $query.'WHERE "ID_RELACIONADOS" = '.'\''.$ID_RELACIONADOS.'\' ';

                // echo '**************** CFDICOMPROBANTERELACIONADOS:UUID *************************';
                // echo '\n';
                // echo $query;
                // echo '\n';
                $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
                pg_free_result($result);
            }
        }

        foreach ($xml->xpath('//cfdi:Comprobante//cfdi:Impuestos') as $Datos){ 
            $val1 = $Datos['TotalImpuestosRetenidos'] ?? '0';
            $val2 = $Datos['TotalImpuestosTrasladados'] ?? '0';

            $query = 'UPDATE "InfUsuario"."CFDICOMPROBANTE" SET ';
            $query = $query.'"TOTALIMPUESTOSRETENIDOS" = '.$val1.', ';
            $query = $query.'"TOTALIMPUESTOSTRASLADADOS" = '.$val2.' ';
            $query = $query.'WHERE "ID_COMPROBANTE" = '.'\''.$ID_COMPROBANTE.'\' ';

            // echo '**************** CFDICOMPROBANTE:TotalImpuestos *************************';
            // echo '\n';
            // echo $query;
            // echo '\n';
            $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
            pg_free_result($result);
        }

        foreach ($xml->xpath('//cfdi:Comprobante//cfdi:Impuestos//cfdi:Retenciones//cfdi:Retencion') as $Datos){
            if (false === isset($Datos['TipoFactor'])) {
                $query = 'INSERT INTO "InfUsuario"."CFDICOMPROBANTEIMPUESTOSRETENIDOS"( ';
                $query = $query.'"IMPUESTO", "IMPORTE", ';
                $query = $query.'"ID_COMPROBANTE" ) ';
                $query = $query.'VALUES( ';

                $query = $query.'\''.$Datos['Impuesto'].'\', ';
                $query = $query.'\''.$Datos['Importe'].'\', ';
                $query = $query.'\''.$ID_COMPROBANTE.'\' ';

                $query = $query.' ) ';

                // echo '**************** CFDICOMPROBANTEIMPUESTOSRETENIDOS *************************';
                // echo '\n';
                // echo $query;
                // echo '\n';
                $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
                pg_free_result($result);  
            }
        }
        
        foreach ($xml->xpath('//cfdi:Comprobante//cfdi:Impuestos//cfdi:Traslados//cfdi:Traslado') as $Datos){
            if (false === isset($Datos['Base'])) {
                $query = 'INSERT INTO "InfUsuario"."CFDICOMPROBANTEIMPUESTOSTRASLADOS"( ';
                $query = $query.'"IMPUESTO", "IMPORTE", "TIPOFACTOR", "TASAOCUOTA", ';
                $query = $query.'"ID_COMPROBANTE" ) ';
                $query = $query.'VALUES( ';

                $query = $query.'\''.$Datos['Impuesto'].'\', ';
                $query = $query.'\''.$Datos['Importe'].'\', ';
                $query = $query.'\''.$Datos['TipoFactor'].'\', ';
                $query = $query.'\''.$Datos['TasaOCuota'].'\', ';
                $query = $query.'\''.$ID_COMPROBANTE.'\' ';

                $query = $query.' ) ';

                // echo '**************** CFDICOMPROBANTEIMPUESTOSTRASLADOS *************************';
                // echo '\n';
                // echo $query;
                // echo '\n';
                $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
                pg_free_result($result);  
            }
        }

        $Num = 0;
        foreach ($xml->xpath('//p:Pago') as $Datos) {
            $Num = $Num + 1;
            $query = 'INSERT INTO "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOS"( ';
            $query = $query.'"FECHAPAGO", "FORMADEPAGOP", "MONEDAP", "MONTO", "NUMOPERACION", ';
            $query = $query.'"RFCEMISORCTABEN", "RFCEMISORCTAORD", "CTABENEFICIARIO", "CTAORDENANTE", "ID_COMPROBANTE", "NUM" ) ';
            $query = $query.'VALUES( ';

            $query = $query.'\''.$Datos['FechaPago'].'\', ';
            $query = $query.'\''.$Datos['FormaDePagoP'].'\', ';
            $query = $query.'\''.$Datos['MonedaP'].'\', ';
            $query = $query.'\''.$Datos['Monto'].'\', ';
            $query = $query.'\''.$Datos['NumOperacion'].'\', ';
            $query = $query.'\''.$Datos['RfcEmisorCtaBen'].'\', ';
            $query = $query.'\''.$Datos['RfcEmisorCtaOrd'].'\', ';
            $query = $query.'\''.$Datos['CtaBeneficiario'].'\', ';
            $query = $query.'\''.$Datos['CtaOrdenante'].'\', ';
            $query = $query.'\''.$ID_COMPROBANTE.'\', ';
            $query = $query.'\''.$Num.'\' ';

            $query = $query.' ) ';

            // echo '**************** CFDICOMPROBANTECOMPLEMENTOPAGOS *************************';
            // echo '\n';
            // echo $query;
            // echo '\n';
            $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
            pg_free_result($result);

        }

        $Num = 0;
        foreach ($xml->xpath('//p:Pago//p:DoctoRelacionado') as $Datos) {
            $Num = $Num + 1;

            $query = 'SELECT "ID_PAGO" FROM "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOS" WHERE "ID_COMPROBANTE" = ';
            $query = $query.'\''.$ID_COMPROBANTE.'\' AND "NUM" = ';
            $query = $query.'\''.$Num.'\' ';

            $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
            while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
                foreach ($line as $col_value) {
                    $ID_PAGO = $col_value;
                }
            }
            pg_free_result($result);

            $val1 = $Datos['ImpSaldoAnt'] ?? '0';
            $val2 = $Datos['ImpPagado'] ?? '0';
            $val3 = $Datos['ImpSaldoInsoluto'] ?? '0';

            $query = 'INSERT INTO "InfUsuario"."CFDICOMPROBANTECOMPLEMENTOPAGOSDOCS"( ';
            $query = $query.'"IDDOCUMENTO", "MONEDADR", "METODODEPAGODR", "TIPOCAMBIODR", "NUMPARCIALIDAD", "IMPSALDOANT", ';
            $query = $query.'"IMPPAGADO", "IMPSALDOINSOLUTO", "SERIE", "FOLIO", "ID_PAGO", "NUM" ) ';
            $query = $query.'VALUES( ';

            $query = $query.'\''.$Datos['IdDocumento'].'\', ';
            $query = $query.'\''.$Datos['MonedaDR'].'\', ';
            $query = $query.'\''.$Datos['MetodoDePagoDR'].'\', ';
            $query = $query.'\''.$Datos['TipoCambioDR'].'\', ';
            $query = $query.'\''.$Datos['NumParcialidad'].'\', ';
            $query = $query.'\''.$val1.'\', ';
            $query = $query.'\''.$val2.'\', ';
            $query = $query.'\''.$val3.'\', ';
            $query = $query.'\''.$Datos['Serie'].'\', ';
            $query = $query.'\''.$Datos['Folio'].'\', ';
            $query = $query.'\''.$ID_PAGO.'\', ';
            $query = $query.'\''.$Num.'\' ';

            $query = $query.' ) ';

            // echo '**************** CFDICOMPROBANTECOMPLEMENTOPAGOSDOCS *************************';
            // echo '\n';
            // echo $query;
            // echo '\n';
            $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
            pg_free_result($result);
        }

        foreach ($xml->xpath('//t:TimbreFiscalDigital') as $Datos) {
            $query = 'INSERT INTO "InfUsuario"."CFDICOMPROBANTECOMPLEMENTO"( ';
            $query = $query.'"VERSION", "UUID", "FECHATIMBRADO", "RFCPROVCERTIF", "NOCERTIFICADOSAT", ';
            $query = $query.'"SELLOSAT", "SELLOCFD", "ID_COMPROBANTE" ) ';
            $query = $query.'VALUES( ';

            $query = $query.'\''.$Datos['Version'].'\', ';
            $query = $query.'\''.$Datos['UUID'].'\', ';
            $query = $query.'\''.$Datos['FechaTimbrado'].'\', ';
            $query = $query.'\''.$Datos['RfcProvCertif'].'\', ';
            $query = $query.'\''.$Datos['NoCertificadoSAT'].'\', ';
            $query = $query.'\''.$Datos['SelloSAT'].'\', ';
            $query = $query.'\''.$Datos['SelloCFD'].'\', ';
            $query = $query.'\''.$ID_COMPROBANTE.'\' ';

            $query = $query.' ) ';

            // echo '**************** CFDICOMPROBANTECOMPLEMENTO *************************';
            // echo '\n';
            // echo $query;
            // echo '\n';
            $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
            pg_free_result($result);
        } 
    }

    $Num = 0;
    foreach ($xml->xpath('//cfdi:Comprobante//cfdi:Conceptos//cfdi:Concepto') as $Datos){
        $Num = $Num + 1;
        $val1 = $Datos['Descuento'] ?? '0';
        $importe = $Datos['Importe'] ?? '0';

        $query = 'INSERT INTO "InfUsuario"."CFDICONCEPTOS"( ';
        $query = $query.'"CLAVEPRODSERV", "CANTIDAD", "CLAVEUNIDAD", "UNIDAD", "DESCRIPCION", ';
        $query = $query.'"VALORUNITARIO", "IMPORTE", "NOIDENTIFICACION", "DESCUENTO", "ID_COMPROBANTE", "NUM" ) ';
        $query = $query.'VALUES( ';

        $query = $query.'\''.$Datos['ClaveProdServ'].'\', ';
        $query = $query.'\''.$Datos['Cantidad'].'\', ';
        $query = $query.'\''.$Datos['ClaveUnidad'].'\', ';
        $query = $query.'\''.$Datos['Unidad'].'\', ';
        $query = $query.'\''.$Datos['Descripcion'].'\', ';
        $query = $query.'\''.$Datos['ValorUnitario'].'\', ';
        $query = $query.'\''.$Datos['Importe'].'\', ';
        $query = $query.'\''.$Datos['NoIdentificacion'].'\', ';
        $query = $query.'\''.$val1.'\', ';
        $query = $query.'\''.$ID_COMPROBANTE.'\', ';
        $query = $query.'\''.$Num.'\' ';

        $query = $query.' ) ';

        // echo '**************** CFDICONCEPTOS *************************';
        // echo '\n';
        // echo $query;
        // echo '\n';
        $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
        pg_free_result($result);
    }

    $Num = 0;
    foreach ($xml->xpath('//cfdi:Comprobante//cfdi:Conceptos//cfdi:Concepto//cfdi:Impuestos//cfdi:Retenciones//cfdi:Retencion') as $Datos){ 
        if (true === isset($Datos['TipoFactor'])) {
            $Num = $Num + 1;
            $query = 'SELECT "ID_CONCEPTO" FROM "InfUsuario"."CFDICONCEPTOS" WHERE "ID_COMPROBANTE" = ';
            $query = $query.'\''.$ID_COMPROBANTE.'\' AND "NUM" = ';
            $query = $query.'\''.$Num.'\' ';

            $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
            while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
                foreach ($line as $col_value) {
                    $ID_CONCEPTO = $col_value;
                }
            }

            $query = 'INSERT INTO "InfUsuario"."CFDICONCEPTOSIMPUESTOSRETENCIONES"( ';
            $query = $query.'"BASE", "IMPUESTO", "TIPOFACTOR", "TASAOCUOTA", "IMPORTE", ';
            $query = $query.'"ID_CONCEPTO", "NUM" ) ';
            $query = $query.'VALUES( ';
    
            $query = $query.'\''.$Datos['Base'].'\', ';
            $query = $query.'\''.$Datos['Impuesto'].'\', ';
            $query = $query.'\''.$Datos['TipoFactor'].'\', ';
            $query = $query.'\''.$Datos['TasaOCuota'].'\', ';
            $query = $query.'\''.$Datos['Importe'].'\', ';
            $query = $query.'\''.$ID_CONCEPTO.'\', ';
            $query = $query.'\''.$Num.'\' ';
    
            $query = $query.' ) ';
    
            // echo '**************** CFDICONCEPTOSIMPUESTOSRETENCIONES *************************';
            // echo '\n';
            // echo $query;
            // echo '\n';
            $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
            pg_free_result($result);
        }
    }

    $Num = 0;
    foreach ($xml->xpath('//cfdi:Comprobante//cfdi:Conceptos//cfdi:Concepto//cfdi:Impuestos//cfdi:Traslados//cfdi:Traslado') as $Datos){ 
        if (true === isset($Datos['Base'])) {
            $Num = $Num + 1;
            $query = 'SELECT "ID_CONCEPTO" FROM "InfUsuario"."CFDICONCEPTOS" WHERE "ID_COMPROBANTE" = ';
            $query = $query.'\''.$ID_COMPROBANTE.'\' AND "NUM" = ';
            $query = $query.'\''.$Num.'\' ';

            // echo $query;
            $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
            while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
                foreach ($line as $col_value) {
                    $ID_CONCEPTO = $col_value;
                }
            }

            $query = 'INSERT INTO "InfUsuario"."CFDICONCEPTOSIMPUESTOSTRASLADOS"( ';
            $query = $query.'"BASE", "IMPUESTO", "TIPOFACTOR", "TASAOCUOTA", "IMPORTE", ';
            $query = $query.'"ID_CONCEPTO", "NUM" ) ';
            $query = $query.'VALUES( ';
    
            $query = $query.'\''.$Datos['Base'].'\', ';
            $query = $query.'\''.$Datos['Impuesto'].'\', ';
            $query = $query.'\''.$Datos['TipoFactor'].'\', ';
            $query = $query.'\''.$Datos['TasaOCuota'].'\', ';
            $query = $query.'\''.$Datos['Importe'].'\', ';
            $query = $query.'\''.$ID_CONCEPTO.'\', ';
            $query = $query.'\''.$Num.'\' ';
    
            $query = $query.' ) ';
    
            // echo '**************** CFDICONCEPTOSIMPUESTOSTRASLADOS *************************';
            // echo '\n';
            // echo $query;
            // echo '\n';
            $result = pg_query($query) or die('La consulta fallo: ' . pg_last_error());
            pg_free_result($result);
        }
    }

    pg_close($dbconn);
}

echo Car();

?>