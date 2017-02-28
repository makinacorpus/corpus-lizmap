{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
{# export macro to callees #}
{% set ugs = salt['mc_usergroup.settings']() %}
{% set locs = salt['mc_locations.settings']() %}
{% set cfg = opts['ms_project'] %}
{{cfg.name}}-restricted-perms:
  file.managed:
    - name: {{cfg.project_dir}}/global-reset-perms.sh
    - mode: 750
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - contents: |
            #!/usr/bin/env bash
            if [ -e "{{cfg.pillar_root}}" ];then
            "{{locs.resetperms}}" -q "${@}" \
              --dmode '0770' --fmode '0770' \
              --user root --group "{{ugs.group}}" \
              --users root \
              --groups "{{ugs.group}}" \
              --paths "{{cfg.pillar_root}}";
            fi
            if [ -e "{{cfg.project_root}}" ];then
              "{{locs.resetperms}}" "${@}" \
              --dmode '0770' --fmode '0770'  \
              --paths "{{cfg.project_root}}" \
              --paths "{{cfg.data_root}}" \
              --users www-data \
              --users {% if not cfg.no_user%}{{cfg.user}}{% else -%}root{% endif %} \
              --groups {{cfg.group}} \
              --user {% if not cfg.no_user%}{{cfg.user}}{% else -%}root{% endif %} \
              --group {{cfg.group}};
              "{{locs.resetperms}}" "${@}" \
              --no-recursive -o\
              --dmode '0555' --fmode '0644'  \
              --paths "{{cfg.project_root}}" \
              --paths "{{cfg.project_dir}}" \
              --paths "{{cfg.project_dir}}"/.. \
              --paths "{{cfg.project_dir}}"/../.. \
              --users www-data ;
            # set inner upload dir permissions to the relevant user
            # any one which has level to global root is a global rw user
            # any one bellow just have RW on its subfolder, but just enter directory rigth
            # on the ftp root
            {% set ftp_directories = salt['mc_utils.odict'](instance=False)((
              (data.ftp_root, {'no_recursive': False,
                          'user': cfg.user, 'group': cfg.group, 'mode': '0771',
                          'users': [cfg.user, 'www-data'], 'groups': [cfg.group, 'www-data']}),
              (data.rftp_root, {'no_recursive': True,
                           'user': cfg.user, 'group': cfg.group, 'mode': '0771',
                           'users': [cfg.user, 'www-data'], 'groups': [cfg.group, 'www-data']}))) %}
            setfacl  -b -R "{{data.ftp_root}}"
            {% for userdef in cfg.data.users%}{% for usr, udata in userdef.items() %}
              {%    set uhome = udata.get('home', data.ftp_root) %}
              {%    set ftp_directory = ftp_directories.setdefault(
                       uhome, {'user': usr, 'group': usr, 'mode': '0771',
                               'users': [ cfg.user, 'www-data'], 'groups': [cfg.group, 'www-data']}) %}
              {% if not usr in ftp_directory.users%}{% do ftp_directory.users.append(usr) %}{%endif%}
            {% endfor%}{% endfor %}
            {% for ftp_directory, d in ftp_directories.items() %}
            {{locs.resetperms}} -q {% if d.get('no_recursive', False) %}--no-recursive{%endif%}\
              -u {{d.user}} -g {{d.group}} --dmode "{{d.mode}}" --fmode "{{d.mode}}"\
              {% for usr in d.users%}--users {{usr}}:rwx {%endfor%}\
              {% for grp in d.groups%}--groups {{grp}}:rwx {%endfor%}\
              --paths "{{ftp_directory}}"
            {% endfor %}
            fi
  cmd.run:
    - name: {{cfg.project_dir}}/global-reset-perms.sh
    - cwd: {{cfg.project_root}}
    - user: root
    - watch:
      - file: {{cfg.name}}-restricted-perms

{{cfg.name}}-fixperms:
  file.managed:
    - name: /etc/cron.d/{{cfg.name.replace('.', '_')}}-fixperms
    - user: root
    - mode: 744
    - contents: |
                {{cfg.data.cron_periodicity}} root {{cfg.project_dir}}/global-reset-perms.sh

