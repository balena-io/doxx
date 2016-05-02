Doxx — static docs generator
======================

> **Work in Progress!** This is currently a WIP project. Originally created as part of the Resin.io documentation repository, the code is currently being extracted and generalized. After it's done the original repository will start using this project as dependency, and this project will be considered production-ready.

Doxx is an opinionated but flexible static generator for technical documentation.

Doxx was created at Resin.io to address some unique features we needed from our docs:
* author docs in Markdown,
* use Handlebars templates inside of the docs files, with support for partials (DRY FTW),
* generate "dynamic" pages by expanding the skeleton page over a combination of parameters, and be able to override parts of such pages for specific params combinations,
* use powerful templating language (Swig in our case) for pages layouts,
* generate static docs, but also be able to reuse the same layouts for a couple of dynamic routes (like server-rendered search results),
* easily define navigation tree using the simple plain-text format,
* easily render breadcrumbs that reflect the page position in the navigation tree.


License
-------

The project is licensed under the Apache 2.0 license.
