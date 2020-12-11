---
layout: post
title:  "Try One Post"
date:   2020-12-01
tags: catI catII catIII
description: Here is the description
assets: /prueba-blog/assets/2020/12/try-one-post
---

This name ends in .md, not .markdown.

This is a static asset for you: [file2]({{assets}}/file1.txt).

A squared video (4:3):

{% include youtube.html src="https://www.youtube.com/embed/BZwuTo7zKM8" %}

A wide video (16:9):

{% include youtube.html src="https://www.youtube.com/embed/jYFefppqEtE" %}

{% include image.html max-width="200px" file="a-cat.png" caption='This is the  
Jekyll logo. [file1](/file1.txt)' %}

This is a phrase cutted by two spaces  
and a line break.


- bullet item 1 in two parts. This is the first part.

  And this is the second part.

- bullet item 2



This is a phrase cutted by one space 
and a line break.

Code:

```xml
<salutation>
   <hello lang="spanish">
   hola
   </hello>
<salutation>
```

## Images

This is another subsection.

Some images:


Var.page: {{ page.path }}


- Custom var: {{page.assetfolder}}
- Site.baseurl: {{site.baseurl}}
- Testing: {{site.testing}}
- page.slug: {{page.slug}}
- page.assets: {{page.assets}}



{% include image.html max-width="200px" file="a-cat.png" caption="This is the Jekyll logo." %}
{% include image.html file="a-cat.png" caption="This is the
**Jekyll** logo." %}


## Equations

Inline $$mean = \frac{\displaystyle\sum_{i=1}^{n} x_{i}}{n}$$ equation.

Alone

$$
k_{n+1} = n^2 + k_n^2 - k_{n-1}
$$


equation.

fdfdfs



Y ahora, para cualquier otro valor que no esté en la tabla, tan sólo debemos interpolar entre los dos valores más cercanos. La ec
uación de una interpolación lineal es así:

$$
y=y_{0}+\underbrace{\frac {y_{1}-y_{0}} {x_{1}-x_{0}}}_A\ (x-x_{0})
$$



Esta ecuación debemos optimizarla para su uso en un microcontrolador sin FPU. Nos interesa ganar velocidad en el bucle principal porque, si el bucle tarda varios milisegundos, no podríamos oír dos tics más próximos entre sí que ese tiempo.

La división, por ejemplo, está formada por valores fijos, constantes. La precalculamos y la llamaremos <b>A</b>.

\\[\begin{split}<br />y &amp;=A (x-x_{0})+ y_{0}\\\\<br />&amp;= Ax\ \underbrace{-Ax_{0} + y_{0}}_{-B}<br />\end{split}\\]



La suma $-Ax_{0} + y_{0}$ es también constante, no depende de x, la llamaremos <b>B</b>. Realmente,  como en este caso es siempre negativa, la llamaremos $-B$ y nos ahorramos poner el signo menos todo el rato. Reescribimos la ecuación anterior de esta otra forma:

\\[y = Ax - B\\]




