Doxx — static docs generator
======================

> Originally created as part of the balena.io documentation repository, the code is now extracted and generalized.

Doxx is an opinionated yet flexible static generator for technical documentation.

Doxx was created at balena.io to address the requirements (some of them unique) we have for our docs:
* author docs in Markdown,
* use Handlebars templates inside of the docs files, with support for partials (DRY FTW). It also has a [rich collection of helpers](https://github.com/assemble/handlebars-helpers) preloaded,
* generate "dynamic" pages by expanding the skeleton page over a combination of parameters, and be able to override parts of such pages for specific params combinations,
* use powerful templating language (Swig in our case) for pages layouts,
* generate static docs, but also be able to reuse the same layouts for a couple of dynamic routes (like server-rendered search results),
* easily define navigation tree using the simple plain-text format,
* easily render breadcrumbs that reflect the page position in the navigation tree.

## Writing and editing documentation

All documentation is written in [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet). To create a new page of documentation, add it to `pages/` and add a link to `config/navigation.txt`.

To create reusable content which appears on multiple pages, create a file in the `shared/` folder and import it using `{{> file.md }}`

### Dynamic pages

Doxx allows the creation of dynamic documentation pages. These are pages which are generated based on options selected by the user. For example, you may wish to change the content of a 'Getting started' page for different language and OS combinations. Each dynamic page has one or more dropdowns at the top of the page which enumerate the various options.

A dynamic page looks very much like a normal page but with a special header and a larger-than-average amount of shared content.

Here is an example header for a dynamic page with two variables:

```
---
dynamic:
  variables: [ $os, $language ]
  ref: $os/$language/$original_ref
  $switch_text: View documentation for $os and $language
---
```

`variables` is self-explanatory: a list of the variables that the user can change. `ref` is the path of the page, as used in `config/navigation.txt`. `switch_text` is what appears at the top of the page with the dropdowns. Variables should be set up in `/config/dictionaries/` so that each variable has an `id` and a `name`.

There are two main ways the variables can affect the contents of the page: smart import and conditional statements.

Smart import lets you write shared content snippets which are chosen based on the value of the variables selected by the user. Choose a name for the snippet and create a folder in `shared/` with that name.

To include a smart import, add `{{ import "<name of snippet>"}}` to the Markdown.

This will look in the shared folder with the name of the snippet and import files with the following precedence:

1) **Exact matches**: Doxx will first look for a file of the form `variable1+variable2.md`. For example, in a page where the user can choose an OS and a language, if the user has chosen `osx` and `javascript` then Doxx will import the file `osx+javascript.md`. The order is important here: it is the order defined in the variables list in the header of the dynamic page.

2) **Matches for a single variable**: if there is no file with that name, Doxx will then look for a file of the form `variable1.md` and then `variable2.md`. For the example above, if a file called `osx.md` exists then Doxx will import that, and if not then it will look for and import a file called `javascript.md`. Again the order of precedence is determined by the order the variables are defined in the header.

3) **Default**: if no exact or partial match is found, Doxx imports `_default.md`.

#### Navigation

The left-hand side navigation menu is set up in `config/navigation.txt`, which defines a tree of pages.

Each node can be:

- Plain text, `Some text`, which acts as a link to its first child
- A plain link: `[/some/link]`, which gets its title from the linked page
- A link with custom title, `Some text[/some/link]`
- A dynamic page with a title that does not change, `Default title[/some/$dictionary/link]
- A dynamic page with a dynamic title, `Default title ~ Title with {{ interpolation }}[/some/$dictionary/link]''

License
-------

The project is licensed under the Apache 2.0 license.
