---
dynamic:
  variables: [ $os, $language ]
  ref: $os/$language/$original_ref
  $switch_text: Getting Started with $os and $language
---

# Dynamic page about {{ $os.name }} & {{ $language.name }}

Hey, this is the page about **{{ $os.name }}** and **{{ $language.name }}**.

## Smart import

{{ import "imported" }}
