{% set cfg = opts.ms_project %}
{% if cfg.data.has_db %}
{% import "makina-states/services/db/postgresql/init.sls" as pgsql with context %}
{% set db = cfg.data.db %}
include:
  - makina-states.services.gis.postgis
{{ pgsql.postgresql_db(db.name, template="postgis") }}
{{ pgsql.postgresql_user(db.user,
                          password=db.password,
                          db=db.name,) }}
{% else %}
no-op: {mc_proxy.hook: []}
{% endif %}
