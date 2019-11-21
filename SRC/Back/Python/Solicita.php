<?php

function Sol() {
    $argumentos = getopt("c:k:r:i:f:t:a:u:", array(
        "certificado:",
        "llave:",
        "rfc:",
        "fechainicial",
        "fechafin",
        "tipo",
        "autoriza",
        "funcion",
        ));

    if (
        !isset($argumentos["c"]) || isset($argumentos["certificado"])
        ||
        !isset($argumentos["k"]) || isset($argumentos["llave"])
        ||
        !isset($argumentos["r"]) || isset($argumentos["rfc"])
        ||
        !isset($argumentos["i"]) || isset($argumentos["fechainicial"])
        ||
        !isset($argumentos["f"]) || isset($argumentos["fechafin"])
        ||
        !isset($argumentos["t"]) || isset($argumentos["tipo"])
        ||
        !isset($argumentos["a"]) || isset($argumentos["autoriza"])
        ||
        !isset($argumentos["u"]) || isset($argumentos["funcion"])
    )   {
        exit("Modo de uso:
            -c --certificado    Certificado
            -k --llave          Llave
            -r --rfc            RFC
            -i --fechainicial   Fecha Inicial
            -f --fechafin       Fecha Final
            -t --tipo           Tipo Solicitud
            -a --autoriza       Token Autorizacion
            -u --funcion        emisor o receptor
            ");
        }

    $certificado = isset($argumentos["c"]) ? $argumentos["c"] : $argumentos["certificado"];
    $llave = isset($argumentos["k"]) ? $argumentos["k"] : $argumentos["llave"];
    $nurfc = isset($argumentos["r"]) ? $argumentos["r"] : $argumentos["rfc"];
    $finicial = isset($argumentos["i"]) ? $argumentos["i"] : $argumentos["fechainicial"];
    $ffinal = isset($argumentos["f"]) ? $argumentos["f"] : $argumentos["fechafin"];
    $tipo = isset($argumentos["t"]) ? $argumentos["t"] : $argumentos["tipo"];
    $idautoriza = isset($argumentos["a"]) ? $argumentos["a"] : $argumentos["autoriza"];
    $funcion = isset($argumentos["u"]) ? $argumentos["u"] : $argumentos["funcion"];

    include_once('include/LoginXmlRequest.php');
    include_once('include/RequestXmlRequest.php');
    include_once('include/VerifyXmlRequest.php');
    include_once('include/Utils.php');

    $loginSAT = new LoginXmlRequest();
    $solicita = new RequestXmlRequest();
    $verifica = new VerifyXmlRequest();
    $util = new Utils();

    $cert = file_get_contents($certificado);
    $key = file_get_contents($llave);
    $rfc = $nurfc;
    $fechaInicial = $finicial;
    $fechaFinal = $ffinal;
    $TipoSolicitud = $tipo;
    $token = $idautoriza;

    // $fh = fopen("Datos2.xml", 'w') or die("Se produjo un error al crear el archivo");
    // fwrite($fh, $funcion) or die("No se pudo escribir en el archivo");
    // fclose($fh);
    
    $ResponseRequest = $solicita->soapRequest($cert, $key, $token, $rfc, $fechaInicial, $fechaFinal, $TipoSolicitud, $funcion);
    $idSolicitud = $ResponseRequest->idSolicitud;
    return $idSolicitud;

    }

    echo Sol();

?>