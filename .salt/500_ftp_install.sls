{% set cfg = opts.ms_project %}
{% if cfg.data.has_app %}
include:
  - makina-states.services.ftp.pureftpd
{% set apacheSettings = salt['mc_apache.settings']() %}

{{cfg.name}}-bindmounted-ftp:
  file.directory:
    - names:
      - {{cfg.project_root}}/webapp/lizmap/ftp
      - {{cfg.data.ftp_root}}
    - user: {{apacheSettings.httpd_user}}
    - group: {{apacheSettings.httpd_user}}
    - mode:  775
    - makedirs: true

  mount.mounted:
    - name: {{cfg.project_root}}/webapp/lizmap/ftp
    - device: {{cfg.data.ftp_root}}
    - fstype: none
    - opts: bind,exec,rw
    - watch:
      - file: {{cfg.name}}-bindmounted-ftp

{# create each user, his home and base layout #}
{% for userdef in cfg.data.users %}
{% for user, data in userdef.items() %}
{{cfg.name}}-ftp-user-{{user}}:
  group.present:
    - name: {{user}}
    - watch:
      - mount: {{cfg.name}}-bindmounted-ftp
  user.present:
    - shell: /bin/ftponly
    - name: {{user}}
    - password: {{salt['mc_utils.unix_crypt'](data.password)}}
    - group: {{user}}
    - fullname: {{user}} user
    - home: {{cfg.data.ftp_root}}
    - remove_groups: False
    - gid_from_name: True
    - watch:
      - group: {{cfg.name}}-ftp-user-{{user}}

{{cfg.name}}-{{salt['mc_apache.settings']().httpd_user}}-in-ftpgroup-{{user}}:
  user.present:
    - name: {{apacheSettings.httpd_user}}
    - remove_groups: False
    - groups:
      - {{user}}
    - watch:
      - user: {{cfg.name}}-ftp-user-{{user}}
{% endfor %}
{% endfor %}
{% else %}
no-op: {mc_proxy.hook: []}
{% endif %}
