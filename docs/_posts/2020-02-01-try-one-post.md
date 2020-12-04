---
layout: post
title:  "Try One Post"
date:   2020-02-01 10:10:10 +0100
tags: catI catII catIII
assets: {{post.baseurl}}
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

## Subsection

This is another subsection.

Some images:


Var.page: {{ page.path }}


- Custom var: {{page.assetfolder}}
- Site.baseurl: {{site.baseurl}}
- page.slug: {{page.slug}}
- page.assets: {{page.assets}}

![My helpful screenshot]({{site.baseurl}}/assets/{{page.slug}}/img/a-cat.png)


