---
layout: post
title:  "Try One Post"
date:   2020-02-01 10:10:10 +0100
tags: catI catII catIII
description: Here is the description
---

This name ends in .md, not .markdown.

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
- page.slug: {{page.slug}}
- page.assets: {{page.assets}}

![My helpful screenshot]({{site.baseurl}}/assets/{{page.slug}}/img/a-cat.png)


{% include image.html max-width="200px" file="a-cat.png" caption="This is the Jekyll logo." %}
{% include image.html  file="a-cat.png" caption="This is the Jekyll logo." %}


## Equations

Inline $$mean = \frac{\displaystyle\sum_{i=1}^{n} x_{i}}{n}$$ equation.

Alone

$$
k_{n+1} = n^2 + k_n^2 - k_{n-1}
$$


equation.

fdfdfs

