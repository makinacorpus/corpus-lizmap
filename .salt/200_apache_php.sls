{% set cfg = opts.ms_project %}
{% if cfg.data.has_app %}
{% import "makina-states/services/http/apache/init.sls" as apache with context %}
{% import "makina-states/services/php/init.sls" as php with context %}
include:
  - makina-states.services.php.phpfpm_with_apache
{{apache.virtualhost(cfg.data.domain, cfg.data.www_dir, **cfg.data.apache_vhost)}}
{{php.fpm_pool(cfg.data.domain, cfg.data.www_dir, **cfg.data.fpmpool)}}
{% else %}
no-op: {mc_proxy.hook: []}
{% endif %}
