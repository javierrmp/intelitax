<?php

function Des() {
    $argumentos = getopt("c:k:r:a:v:", array(
        "certificado:",
        "llave:",
        "rfc:",
        "autoriza",
        "verifica",
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
        !isset($argumentos["v"]) || isset($argumentos["verifica"])
    )   {
        exit("Modo de uso:
            -c --certificado   certificado
            -k --llave         Llave
            -r --rfc           RFC
            -a --autoriza      Token Autorizacion
            -v --verifica      Verificacion
            ");
        }

    $certificado = isset($argumentos["c"]) ? $argumentos["c"] : $argumentos["certificado"];
    $llave = isset($argumentos["k"]) ? $argumentos["k"] : $argumentos["llave"];
    $nurfc = isset($argumentos["r"]) ? $argumentos["r"] : $argumentos["rfc"];
    $idautoriza = isset($argumentos["a"]) ? $argumentos["a"] : $argumentos["autoriza"];
    $idPaqueteSol = isset($argumentos["v"]) ? $argumentos["v"] : $argumentos["verifica"];

    include_once('include/LoginXmlRequest.php');
    include_once('include/RequestXmlRequest.php');
    include_once('include/VerifyXmlRequest.php');
    include_once('include/DownloadXmlRequest.php');
    include_once('include/Utils.php');

    $loginSAT = new LoginXmlRequest();
    $solicita = new RequestXmlRequest();
    $verifica = new VerifyXmlRequest();
    $descarga = new DownloadXmlRequest();
    $util = new Utils();

    $cert = file_get_contents($certificado);
    $key = file_get_contents($llave);
    $rfc = $nurfc;
    $token = $idautoriza;
    $idPaquete = $idPaqueteSol;

    $ResponseDownload = $descarga->soapRequest($cert, $key, $token, $rfc, $idPaquete);
    $util->saveBase64File($ResponseDownload->Paquete, $idPaquete.".zip");
    $respuesta = "DESCARGA CON EXITO";
    return $respuesta;
    }

    echo Des();

?>