---
layout: post
title: Transmitir información usando el mando de un coche teledirigido
author: Electrónica y Ciencia
tags:
- estadística
- circuitos
- telemandos
thumbnail: http://2.bp.blogspot.com/_QF4k-mng6_A/TMbtzX86gpI/AAAAAAAAAZ4/sP0rkgS7ItI/s72-c/Imagen256.jpg
blogger_orig_url: https://electronicayciencia.blogspot.com/2010/10/transmitir-informacion-usando-el-mando.html
---



{% include image.html file="hist_BA.png" caption="" %}

Para abreviar no pondré los programas. Podéis encontrarlos si os interesa en el enlace que hay al final de la entrada, dentro del directorio transiciones. El algoritmo es muy sencillo y consiste en lo siguiente:

1. Fijar el estado A (ningún botón pulsado).
1. Esperar a que se desactive la señal en el receptor.
1. Enviar por puerto serie el nuevo estado.
1. Fijar el estado B (botón de tono grave).
1. Esperar a que en el receptor se refleje el cambio.
1. Enviar por puerto serie el nuevo estado.
1. ...
1. Repetir en el orden que habíamos dicho antes.

Si pusiéramos la oreja en la antena esto es lo que oiríamos:

{% include image.html file="transiciones.png" caption="" %}

Aquí vemos un sonograma de Baudline. El tiempo transcurre hacia abajo y las frecuencias aumentan hacia la derecha. Como es una onda cuadrada, las lineas verticales son los armónicos. En el estado A no hay ninguna señal. En el B las líneas están muy juntas porque se trata de los armónicos de una onda de 250Hz (250Hz, 500Hz, 750Hz, 1000Hz, 1250Hz, etc). En cambio la frecuencia moduladora para el estado C es de 1000Hz. Y los armónicos son múltiplos de 1000 (1000Hz, 2000Hz, 3000Hz, etc), por eso salen más separados.

Otra cosa interesante es que está más tiempo parado en el estado A que en los demás. Y que el estado C es el que menos dura. En efecto, el receptor se da cuenta muy rápidamente del tono de 1000Hz, para detectar el de 250Hz le cuesta un poco más. Pero una vez cesamos de enviar señal, la inercia que tiene es muy grande. Es normal, es un circuito pensado para un coche teledirigido, no para hacer de modem.

Luego en el [puerto serie]({{site.baseurl}}{% post_url 2010-03-22-conversor-usb-rs232 %}) tenemos un recolector de información que es el que lleva el registro del tiempo entre un estado y otro. Similar al que habíamos usado en nuestro [sensor LED]({{site.baseurl}}{% post_url 2010-09-08-sensor-optico-sencillo-con-amplio-rango %}). 

Los tiempos mínimos y máximos que se obtienen son (en milisegundos):

    AC:    8 - 17
    BC: 17.5 - 17.7

    AB: 64.4 - 65.6
    CB: 65.5 - 67.5

    CA: 146 - 149
    BA: 175 - 194

Pensad que estos tiempos son los tiempos durante los que tenemos que mantener un mismo estado para que el receptor se entere. Luego para nuestra codificación está claro que nos tenemos que centrar en B y C que son los dos estados más "rápidos", porque en cuanto queramos hacer algo con el estado A tendríamos que esperar hasta 200ms. La velocidad va a caer en picado. Y dentro del juego B y C lo que nos dice esto es que tenemos que darle a cada tono unos 70ms de margen (el máximo entre los dos).

Lo ideal sería quedarnos sólo con el C, pero como para transmitir algo tenemos que tener dos estados por fuerza hay que elegir B y C.

En realidad no siempre tardan lo mismo. Va a haber un valor mínimo del tiempo de detección, por debajo del cual no se detecta nada. Pero habrá veces que tarde más o tarde menos dependiendo por ejemplo de la calidad de la recepción. Hay una distribución estadística, que se llama [de Weibull](http://es.wikipedia.org/wiki/Distribuci%C3%B3n_de_Weibull) que más o menos modela este comportamiento. No vamos a hacer el test porque creo que ya queda fuera del ámbito del artículo. Para las tres transiciones podemos dibujar tres histogramas que nos darán una idea de cual es el margen que tenemos que dejar si queremos que el receptor no se confunda. Esto es importante, porque la tasa de error va en funciona de este tiempo. Si dejamos un tiempo demasiado corto podremos transmitir más rápido pero a costa de tener más errores, habrá símbolos que se reciban bien (1 o 0) y otras veces se recibirán mal (un 0 por un 1 o al revés).

{% include image.html file="hist_BA.png" caption="" %}

En la imagen superior vemos que la transición hacia A (apagado) desde cualquiera de los estados activos (lo que tarda el receptor en enterarse de que hemos soltado el botón) ronda los 182ms. Puede ocurrir que se detecta antes, por diversas causas, pero es raro que se detecte antes de 178ms. Y hay un tiempo mínimo donde la probabilidad de que se detecte es cero. Por ejemplo en t=0 no vamos a detectar nada, porque es evidente que el integrado necesita un tiempo para procesar la señal y conmutar.

{% include image.html file="hist_AC.png" caption="" %}

La transición hacia C es mucho más rápida, de hecho en la imagen superior se notan los pasos discretos de tiempo. Lo mismo que la anterior, lo normal es que se detecte en 15ms. Puede darse en menos tiempo pero también puede tardar más.

{% include image.html file="hist_AB.png" caption="" %}

Esta es la transición hacia B. El factor limitante de la velocidad. Al igual que las otras tiene un tiempo característico, que es de unos 64.6ms. Pero si ajustamos ahí nuestro retardo puede pasar que no se detecte algunas veces, porque como ya vemos en la distribución, hay muchas medidas que han ocurrido en tiempos superiores. Cuando diseñamos un sistema de transmisión tenemos que alcanzar un compromiso entre velocidad y tasa se fallo. En este caso con tomar 66ms parece que cubriríamos todo el margen. Pero eso no nos asegura una tasa de error cero. Porque siempre habrá ruido e interferencias.

Resumiendo, con 70ms de duración de cada simbolo tenemos una velocidad máxima de 14 baudios. Como decíamos al principio es poca cosa pero para según qué proyectos puede ser muy útil.

## Enviar la información

Ya tenemos todo listo. Vamos a usar el método de No Retorno a Cero, con una velocidad de 14 baudios. Si transmitimos paquetes de 8 bits, y teniendo en cuenta los tiempos de parada (de 200ms) es algo más de 1 byte por segundo. Basta programar un poco para tener dos PICs, uno actuando sobre el transmisor con un texto preprogramado y otro con el receptor.

{% include image.html file="Imagen005.jpg" caption="" %}

He usado un pequeño truco para sincronizar las dos partes. Porque al haber tanta inercia es fácil que el receptor se pierda. Consiste en que al inicio siempre transmito un 0. Como es el que más tarda, el retardo también sirve para el 1. Si no lo hiciera, el receptor perdería el hilo en los signos que empezaran por 1. Ese truco se llama **Look At Me** y se usa en casi todos los dispositivos remotos. Tened en cuenta que aunque yo conmute siempre a un tiempo fijo en el transmisor, al receptor le llega la señal cada vez con un retardo distinto. Por eso tengo que ver qué estado hay al final de los 70ms. Si lo viera a la mitad unas veces se recibiría bien (para los 1, que tardan menos por ser el tono más agudo) y otras mal.

Este es el programa transmisor:

```cpp
void one (void) {
 output_high(PIN_LED);
 input(PIN_TXGrave);
 output_low(PIN_TXAgudo);
 delay_ms(symbol_time);
}

void zero (void) {
 input(PIN_TXAgudo);
 output_low(PIN_TXGrave);
 delay_ms(symbol_time);
}

void off (void) {
 input(PIN_LED);
 input(PIN_TXAgudo);
 input(PIN_TXGrave);
} 

/* Transmitiremos primero el bít más significativo  */
/* Se podría hacer al revés también, va al gusto.   */
/* Antes de empezar la transmision mandamos un bit  */
/* de start.                                        */
void transmit_byte (char value) {
 #bit msb = value.7
 char i;

 // Bit de start a modo de LAM (Look At Me)
 // Uso el cero porque tarda más en recibirse que el uno
 // entonces el retardo es válido para los dos.
 zero();

 // Transmisión del bit
 for (i=0; i <= 7; i++) {
  if (msb) {
   one(); 
  }
  else {
   zero();
  }
  value <<= 1;
 }
 off();
}

void main()
{
 unsigned char i;
 unsigned char test_seq[] = {
                             0b00000000, // 0x00
                             0b00010001, // 0x11
                             0b01010101, // 0x55
                             0b10101010, // 0xAA
                             0b11110000, // 0xF0
                             0b00001111, // 0x0F
                             0b11111111, // 0xFF -> FIN
                               };

 setup_adc(ADC_OFF);
 setup_timer_0(RTCC_INTERNAL|RTCC_DIV_1);
 setup_oscillator(OSC_4MHZ);
 port_a_pullups(FALSE);

 off();

 i = 0;
 for(;;) {
  char value;
//  value = read_eeprom (i);
  value = test_seq[i];
  if (value == 0xFF) {
   i = 0;
   delay_ms(repetition_time);
  }
  else {
   output_high(PIN_LED);
   transmit_byte(value);
   output_low(PIN_LED);
   delay_ms(off_time);
   i++;
  }
 }

}
```

El algoritmo es muy simple. Descomponer el símbolo en sus bits y transmitirlos en el orden que queramos (ya sea primero el más significativo o el menos). También me gustaría que os fijarais en los códigos de prueba que se transmiten.

A la hora de recibir es cuando nos servimos del truco que os había dicho antes. Recibimos el primer bit y sabemos que va a ser un cero. Así que una vez lo recibamos vamos muestreando los estados a intervalos regulares. Cuando juntamos 8 bits transmitimos el byte correspondiente por el puerto serie hasta el PC.

```cpp
void main()
{
 setup_adc(ADC_OFF);
 setup_timer_0(RTCC_INTERNAL|RTCC_DIV_1);
 setup_oscillator(OSC_4MHZ);
 port_a_pullups(FALSE);

 
 for (;;) {
  char value;
  char num;

  // Esperamos el estado A (a que todo se apague)
  while(input(PIN_RXAgudo) || input(PIN_RXGrave));
  printf("A");
  // Esperamos un B que significa el comienzo
  while(!input(PIN_RXGrave));
  printf("C ");

  // Esperamos un pequeño lapso porque la transición 
  // A-B tiene un error de más-menos unos pocos ms.
  delay_ms(5);

  // Y muestreamos cada symbol_time ms
  // Terminamos si se apagan los dos (se vuelve a A)
  // o si se llega a los 8 bits
  value = 0;
  for (num=0; num<=7; num++) {
   #bit lsb = value.0
   short grave, agudo;

   delay_ms(symbol_time);

   grave = input(PIN_RXGrave);
   agudo = input(PIN_RXAgudo);

   if (grave) {
    // Es un 0, rotamos y añadimos el valor
    value <<= 1;
    lsb = 0;
    printf("0");  

   }
   else if (agudo) {
    // Es un 1, rotamos y añadimos el valor
    value <<= 1;
    lsb = 1;
    printf("1");

   }
   else {
    // No hay más datos
    printf("A");
    break;

   }
  }

  output_high(PIN_LED);
  printf(" %X\r\n", value);
  delay_ms(100);
  output_low(PIN_LED);

 }

}
```

Lo mismo que antes, cuando ponemos la oreja en la antena vemos algo como esto. La captura es de una prueba anterior, en la que habíamos usado un retardo de 68ms y la señal de *Look At Me* era un 1 seguido de un 0. Así es como se vería la transmisión de 3 bytes: 0x0F, 0x55 y 0x55:

{% include image.html file="0F5555.png" caption="" %}

 Después de hacer todas las pruebas tenemos un sistema de transmisión inalámbrico, lento, muy lento pero muy fácil de hacer. Y hasta aquí podemos llegar con estos circuitos tal como vienen de fábrica sin modificaciones importantes.

{% include image.html file="rx_debug.png" caption="" %}

## Evolución del sistema

¿Qué modificaciones podríamos hacer en el sistema para convertirlo en algo más útil? Pues algunas, por ejemplo: 

- Más velocidad. Con el RX-3 que viene de fábrica es imposible. Así que tal vez podríamos capturar la señal cuando sale del demodulador (ver [este esquema]({{site.baseurl}}{% post_url 2010-09-15-receptor-coche-rc-de-dos-canales %})) y procesarla para detectar nosotros el tono.
- También podemos obviar la parte del oscilador en el transmisor (ver [esquema del transmisor]({{site.baseurl}}{% post_url 2010-05-04-mando-de-un-coche-teledirigido %})) y utilizar otro sistema para modular la portadora. Así podríamos usar frecuencias más altas que sean más rápidas de detectar.
- Más potencia. Incorporando un transistor para amplificar la potencia al final y una buena antena tendríamos un poco más de alcance.

En definitiva, aprovechar los osciladores de RF y currarnos el resto, que cada uno juzgue si le parece práctico o no. Encontraréis los archivos usados en las pruebas [aqui](https://sites.google.com/site/electronicayciencia/datos_RC.rar). Están los logs de las transiciones, los programas y los hex de los PICs.
