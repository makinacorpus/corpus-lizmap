{% set cfg = opts.ms_project %}
{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set apacheSettings = salt['mc_apache.settings']() %}
{% set sdata = salt['mc_utils.json_dump'](cfg) %}
{% set php = salt['mc_php.settings']() %}
include:
  - makina-states.services.gis.qgis

prepreq-{{cfg.name}}:
  pkg.{{salt['mc_pkgs.settings']()['installmode']}}:
    - watch:
      - pkg: prereq-qgis
    - pkgs:
      {# install the lib in dep this save us from naming diff
         packages between debian flavors #}
      - libspatialite-dev
      - libsqlite3-mod-blobtoxy
      - libsqlite3-mod-impexp
      - postgresql-client
      - redis-server
      - php{{php.php_ver}}-sqlite3

{{cfg.name}}-lizmapwebclient:
  mc_git.latest:
    - name: {{cfg.data.git}}
    - target: {{cfg.project_root}}/webapp
    - rev: {{data.rev}}
    - user: {{cfg.user}}
    - watch:
      - pkg: prepreq-{{cfg.name}}

www-dir-{{cfg.name}}:
  file.symlink:
    - name: {{cfg.data_root}}/www
    - target: {{cfg.project_root}}/webapp/lizmap/www
    - watch:
      - mc_git: {{cfg.name}}-lizmapwebclient

var-dirs-{{cfg.name}}:
  file.directory:
    - names:
      - {{cfg.data.var}}
      - {{cfg.data.cgi_dir}}
      - {{cfg.data.template_dir}}
    - makedirs: true
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - watch:
      - file: www-dir-{{cfg.name}}

{{cfg.name}}-lizmapwebclient-docroot-fcgi:
  file.copy:
    - source: /usr/lib/cgi-bin/qgis_mapserv.fcgi
    - name: {{cfg.data.cgi_dir}}/qgis_mapserv.fcgi.wrapped
    - force: true
    - makedirs: true
    - watch:
      - file: var-dirs-{{cfg.name}}

{% for file in ['admin.sld', 'wms_metadata.xml', 'qgis_mapserv.fcgi']  %}
{{cfg.name}}-lizmapwebclient-docroot-fcgi-{{file}}:
  file.managed:
    - source: salt://makina-projects/{{cfg.name}}/files/{{file}}
    - name: {{cfg.data.cgi_dir}}/{{file}}
    - template: jinja
    - defaults:
        cfg: {{cfg.name}}
    - watch:
      - file: {{cfg.name}}-lizmapwebclient-docroot-fcgi
{% endfor %}

{{cfg.name}}-block-l:
  file.accumulated:
    - require_in:
      - file: {{cfg.name}}-block-do
    - filename: /etc/hosts
    - text: |-
            {% if data.pgsql_ip %}
            {{data.pgsql_ip}} {{data.pgsql_name}}
            {% endif %}

{{cfg.name}}-block-do:
  file.blockreplace:
    - name: /etc/hosts
    - marker_start: "#-- start {{cfg.name}} pgsql"
    - marker_end: "#-- end {{cfg.name}} pgsql"
    - content: ''
    - append_if_not_found: True
    - backup: '.bak'
    - show_changes: True
