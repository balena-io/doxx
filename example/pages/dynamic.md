---
dynamic_page:
  axes: [ $os, $language ]
  url: $os/$language/$baseUrl
  partials_search: [ $os+$language, $os, $language, _default ]
  switch_text: Getting Started with $os and $language
---

# Dynamic page about {{ $os_details.name }} & {{ $language_details.name }}

Hey, this is the page about **{{ $os_details.name }}** and **{{ $language_details.name }}**.

## Smart import

{{ import "imported" }}
