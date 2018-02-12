{% set cfg = opts.ms_project %}
{% import "makina-states/_macros/h.jinja" as h with context %}
{% set cops = salt['mc_locations.settings']().cops %}
include:
  - makina-states.controllers.corpusops
{% macro configure() %}
    - contents: |
         ---
         val: bar
{% endmacro %}
{{ h.install_via_cops('services_misc_xvfb', configure=configure) }}
