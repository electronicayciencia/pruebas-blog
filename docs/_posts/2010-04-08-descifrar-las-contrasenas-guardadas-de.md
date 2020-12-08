---
layout: post
title: Descifrar las contraseñas guardadas de Opera
author: Electrónica y Ciencia
tags:
- programacion
- PC
thumbnail: http://4.bp.blogspot.com/_QF4k-mng6_A/S72vMwQxa1I/AAAAAAAAADI/X5RQfJ2b3mw/s72-c/buscar_wand.png
blogger_orig_url: https://electronicayciencia.blogspot.com/2010/04/descifrar-las-contrasenas-guardadas-de.html
---

Así como en Firefox tenemos la opción de mostrar una contraseña guardada, en Opera no existe esa posibilidad. En alguna ocasión puede ser útil extraer la lista de las contraseñas guardadas. Como Opera no es *open source* no conocemos el algoritmo de cifrado, lo único que está claro es que, de alguna manera, si el navegador tiene acceso a esa información es que el cifrado debe ser reversible.

Gracias a SNA de [Reverse Engineering Team](http://www.reteam.org/blog/archives/00000012.htm), tenemos una herramienta capaz de descifrar las claves. El código fuente original lo podeis encontrar [aqui](http://www.reteam.org/blog/archives/unwand.cpp). Compila sin problemas en Windows según el autor; pero no en Linux, donde se necesitan unos ligeros retoques. A continuación explico los cambios:

La ruta de las cabeceras en Linux es un poco distinta:<br />#include "md5.h"#include "des.h"<br />por<br />

    #include <string.h> 

    #include <openssl/md5.h> 

    #include <openssl/des.h>

Y además, por la razón que pongo abajo:<br />std::wcout << (wchar_t *)cryptoData << std::endl;<br />por <br />// Quick and dirty workaround to convert UTF chars.int i=0;while(cryptoData[i]) {    printf("%c", cryptoData[i]);    i += 2;}std::wcout << std::endl;<br />Los carácteres se almacenan en formato *widechar*, lo que en términos prácticos y **para caracteres estándar** significa que para poner *Hola* se almacena *H\0o\0l\0a\0* (intercalando un carácter nulo tras cada letra). Que dará problemas o no dependiendo de la configuración del terminal. Puede ocurrir que salgan bien, o que sólo salgan interrogaciones o que sólo aparezca la primera letra de cada palabra, incluso podrían salir caracteres chinos. Así que para evitar estos efectos eliminamos los caracteres nulos intercalados. Es una manera simple de hacer la conversión, y que sólo funciona para caracteres ASCII. En caso de caracteres no estándar lo anterior **no es cierto**.

Para compilarlo utilizamos el siguiente comando:

    c++ unwand.cpp -lcrypto -o unwand

<br />Necesitaremos instalar la librería OpenSSL (libssl) si no la tenemos ya instalada y sus correspondientes cabeceras (libssl-dev). Lo ejecutamos y el programa explora el archivo Wand volcando todos los bloques de información que pueda descifrar. La salida, semejante a esta, puede ser difícil de leer pero al menos tenemos lo que buscábamos.

    > unwand wand.pruebas.dat

    Personal profile                <- Cabecera del fichero

    Ecom_SchemaVersion              <- Tipo de base de datos

    http://www.ejemplo.com/login    <- Pagina

    http://www.ejemplo.com          <- Dominio completo

    user                            <- Campo formulario

    Pepito                          <- Valor del campo

    password                        <- Campo formulario

    f4k3p4$s                        <- Valor del campo

    ...

Para encontrar el archivo *wand.dat* podemos escribir en la barra de direcciones *about:config* y acto seguido buscar *wand*:

{% include image.html file="buscar_wand.png" caption="" %}

Ni que decir tiene que este programita sólo será útil si no hemos establecido una contraseña maestra. Lo he probado con las versiones 9 y 10 para Linux y para Windows, con el resto debería funcionar también. A menos que cambien el algoritmo en el futuro. Encontraréis el archivo adaptado para Linux, junto con un fichero *wand.dat* para pruebas y el ejecutable ya compilado [en este enlace](http://sites.google.com/site/electronicayciencia/unwand.zip).
