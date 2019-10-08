<?php

function Auth() {
    $argumentos = getopt("c:k:", array(
        "certificado:",
        "llave:",
        ));

    if (
        !isset($argumentos["c"]) || isset($argumentos["certificado"])
        ||
        !isset($argumentos["k"]) || isset($argumentos["llave"])
    )   {
        exit("Modo de uso:
            -c --certificado   certificado
            -k --llave         Llave
            ");
        }

    $certificado = isset($argumentos["c"]) ? $argumentos["c"] : $argumentos["certificado"];
    $llave = isset($argumentos["k"]) ? $argumentos["k"] : $argumentos["llave"];

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

    $ResponseAuth = $loginSAT->soapRequest($cert,$key);
    $token = $ResponseAuth->token;
    return $token;

    }

    echo Auth();

?>