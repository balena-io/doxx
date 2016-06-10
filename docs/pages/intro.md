---
title: Introduction
---
# Doxx

> Doxx is a static technical docs generator with dynamic twist.
> Doxx was originally created as part of [resin.io](https://resin.io) docs repository, but eventually transformed into a stand-alone project.

## What does it do? How can it be useful to us?

Doxx is an opinionated project with minimal configuration that was created to aid creation and management of big technical documentation sites.
It has several important features, some of them unique:

* docs are **authored** in `Markdown`,
* `Handlebars` **template** language can be used inside of the docs files, with support for partials (keep things DRY). It also has a [rich collection of helpers](https://github.com/assemble/handlebars-helpers) preloaded,
* **"dynamic" documents** can be created by expanding the skeleton page over a combination of parameters (variables),
* **"smart partials"** can be used inside of dynamic pages: the Doxx engine will pick the best partial based on the variables combination,
* a powerful templating language (`Swig`) can be used for **pages layouts**,
* the same layouts can be used if you need **dynamic routes** (Doxx has a simple express helper that will configure things for you). This can be used, for example, to have server-rendered search results page, or 404 page,
* Doxx can generate `Lunr.js` **search index** for you, and has utilities for searching it server-side,
* **navigation** tree can be defined using the simple plain-text format, and rendered with proper current page highlighting,
* **breadcrumbs** are pre-generated that reflect the page position in the navigation tree.

## What do you mean _opinionated_?

Doxx is built with specific technologies (like `Markdown`, `Handlebars`, and `Swig`) and currently doesn't allow replacing them with your favorite alternatives. If you only need some of the Doxx's features you can use specific [plugins and utilities](/api/components) in your own project.

## Is it a program or a library?

Both. You can run it from the [command-line](/cli) to get your `.md` files and redner them to `.html`. You can do the same from [Node.js program](/api/build). And then Doxx has some helpers that you can use in your [server-side](/api/server) (JS) code.

## Where do I start?

Go to [Basics](/basics) section to get started.
