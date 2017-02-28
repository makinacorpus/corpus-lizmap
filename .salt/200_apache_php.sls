{%- set cfg = opts.ms_project %}
{%- set phps = salt['mc_php.settings']() %}
{% import "makina-states/services/http/apache/init.sls" as apache with context %}
{% import "makina-states/services/php/init.sls" as php with context %}
include:
  - makina-states.services.php.phpfpm_with_apache
{{apache.virtualhost(cfg.data.domain, cfg.data.www_dir, **cfg.data.apache_vhost)}}
{{php.fpm_pool(cfg.data.domain, cfg.data.www_dir, **cfg.data.fpmpool)}}

{{cfg.name}}-extra-php:
  pkg.latest:
    - pkgs: [php{{phps['php_ver']}}-xml]
    - watch:
      - mc_proxy: makina-apache-php-post-inst
    - watch_in:
      - mc_proxy: makina-apache-php-pre-conf
