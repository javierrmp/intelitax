<?php

function Ver() {
    $argumentos = getopt("c:k:r:a:s:", array(
        "certificado:",
        "llave:",
        "rfc:",
        "autoriza",
        "solicita",
        ));

    if (
        !isset($argumentos["c"]) || isset($argumentos["certificado"])
        ||
        !isset($argumentos["k"]) || isset($argumentos["llave"])
        ||
        !isset($argumentos["r"]) || isset($argumentos["rfc"])
        ||
        !isset($argumentos["a"]) || isset($argumentos["autoriza"])
        ||
        !isset($argumentos["s"]) || isset($argumentos["solicita"])
    )   {
        exit("Modo de uso:
            -c --certificado   certificado
            -k --llave         Llave
            -r --rfc           RFC
            -a --autoriza      Token Autorizacion
            -s --solicita      Solicitud
            ");
        }

    $certificado = isset($argumentos["c"]) ? $argumentos["c"] : $argumentos["certificado"];
    $llave = isset($argumentos["k"]) ? $argumentos["k"] : $argumentos["llave"];
    $nurfc = isset($argumentos["r"]) ? $argumentos["r"] : $argumentos["rfc"];
    $idautoriza = isset($argumentos["a"]) ? $argumentos["a"] : $argumentos["autoriza"];
    $idsolicita = isset($argumentos["s"]) ? $argumentos["s"] : $argumentos["solicita"];

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
    $token = $idautoriza;
    $idSolicitud = $idsolicita;

    $ResponseVerify = $verifica->soapRequest($cert, $key, $token, $rfc, $idSolicitud);
    $idPaquete = $ResponseVerify->idPaquete;
    return $idPaquete;
    }

    echo Ver();

?>