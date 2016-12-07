---
dynamic:
  variables: [ $os, $language ]
  ref: $os/$language/$original_ref
  $switch_text: Getting Started with $os and $language
example_version: "1.0.0"
---

# Dynamic page about {{ $os.name }} & {{ $language.name }}

Hey, this is the page about **{{ $os.name }}** and **{{ $language.name }}**.

## Smart import

{{ import "imported" }}

## Helpers Example

{{#eq $os.id "osx"}}
  **This page _is about_ OSX**.
  This paragraph is rendered using the Handlebars helper.
{{else}}
  **This page _is NOT about_ OSX**.
  This paragraph is rendered using the Handlebars helper.
{{/eq}}

{{#semverGte example_version "0.9.0"}}

> This blockquote should only be visible if `example_version` (which is equal to `{{ example_version }}`) is not less than **0.9.0**.

{{/semverGte}}


{{#semverLte example_version "0.9.0"}}

> This blockquote should only be visible if `example_version` (which is equal to `{{ example_version }}`) is not greater than **0.9.0**.

{{/semverLte}}
