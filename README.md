Doxx — static docs generator
======================

> Originally created as part of the Resin.io documentation repository, the code is now extracted and generalized.

Doxx is an opinionated yet flexible static generator for technical documentation.

Doxx was created at Resin.io to address the requirements (some of them unique) we have for our docs:
* author docs in Markdown,
* use Handlebars templates inside of the docs files, with support for partials (DRY FTW). It also has a [rich collection of helpers](https://github.com/assemble/handlebars-helpers) preloaded,
* generate "dynamic" pages by expanding the skeleton page over a combination of parameters, and be able to override parts of such pages for specific params combinations,
* use powerful templating language (Swig in our case) for pages layouts,
* generate static docs, but also be able to reuse the same layouts for a couple of dynamic routes (like server-rendered search results),
* easily define navigation tree using the simple plain-text format,
* easily render breadcrumbs that reflect the page position in the navigation tree.


License
-------

The project is licensed under the Apache 2.0 license.
