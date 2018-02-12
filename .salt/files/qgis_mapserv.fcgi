#!/bin/sh
{%- set cfg = salt['mc_project.get_configuration'](cfg) %}
{%- set data = cfg.data %}
set -e
export QGIS_LOG_FILE={{data.www_dir}}
export QGIS_AUTH_DB_DIR_PATH={{data.www_dir}}
export DISPLAY=:99
exec "{{data.www_dir}}/cgi-bin/qgis_mapserv.fcgi.wrapped" "${@}"
