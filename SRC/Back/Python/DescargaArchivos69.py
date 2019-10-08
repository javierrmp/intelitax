#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
import requests
import io
from time import localtime, strftime
from clint.textui import progress
from chardet import detect

def url_response(url):
    path, url, pathnvo = url
    print(path)
    if os.path.exists(pathnvo):
        os.remove(pathnvo)
    r = requests.get(url, stream = True)
    with open(path, 'wb') as f:
        total_length = int(r.headers.get('content-length'))
        for ch in progress.bar(r.iter_content(chunk_size = 1024), expected_size=(total_length/1024) + 1):
            if ch:
                f.write(ch)

    from_codec = get_encoding_type(path)
    print("**** CONVIRTIENDO ARCHIVO ***", pathnvo)

    with io.open(path, 'r', encoding=from_codec) as f, io.open(pathnvo, 'w', encoding='utf-8') as e:
        text = f.read() 
        e.write(text)
        os.remove(path) 

def get_encoding_type(file):
    with open(file, 'rb') as f:
        rawdata = f.read()
    
    return detect(rawdata)['encoding']

def main(argv):
    urls = [
        ("Cancelados_tmp.csv", "http://omawww.sat.gob.mx/cifras_sat/Documents/Cancelados.csv", "Cancelados.csv"),
        ("Condonadosart74CFF_tmp.csv", "http://omawww.sat.gob.mx/cifras_sat/Documents/Condonadosart74CFF.csv", "Condonadosart74CFF.csv"),
        ("Condonadosart146BCFF_tmp.csv", "http://omawww.sat.gob.mx/cifras_sat/Documents/Condonadosart146BCFF.csv", "Condonadosart146BCFF.csv"),
        ("Condonadosart21CFF_tmp.csv", "http://omawww.sat.gob.mx/cifras_sat/Documents/Condonadosart21CFF.csv", "Condonadosart21CFF.csv"),
        ("CondonadosporDecreto_tmp.csv", "http://omawww.sat.gob.mx/cifras_sat/Documents/CondonadosporDecreto.csv", "CondonadosporDecreto.csv"),
        ("Retornoinversiones_tmp.csv", "http://omawww.sat.gob.mx/cifras_sat/Documents/Retornoinversiones.csv", "Retornoinversiones.csv"),
        ("Exigibles_tmp.csv", "http://omawww.sat.gob.mx/cifras_sat/Documents/Exigibles.csv", "Exigibles.csv"),
        ("Firmes_tmp.csv", "http://omawww.sat.gob.mx/cifras_sat/Documents/Firmes.csv", "Firmes.csv"),
        ("No%20localizados_tmp.csv", "http://omawww.sat.gob.mx/cifras_sat/Documents/No%20localizados.csv", "No%20localizados.csv"),
        ("Sentencias_tmp.csv", "http://omawww.sat.gob.mx/cifras_sat/Documents/Sentencias.csv", "Sentencias.csv"),
        ("Listado_Completo_69-B_temp.csv", "http://omawww.sat.gob.mx/cifras_sat/Documents/Listado_Completo_69-B.csv", "Listado_Completo_69-B.csv")
        ]

    print("**** DESCARGANDO ARCHIVOS ***")
    print(strftime("%a, %d %b %Y %H:%M:%S", localtime()))
    
    for x in urls:
        url_response (x)
    
    print(strftime("%a, %d %b %Y %H:%M:%S", localtime()))
    

if __name__ == "__main__":
  main(sys.argv[1:])
