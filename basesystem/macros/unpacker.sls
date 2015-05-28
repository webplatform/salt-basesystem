{#
 # Download a file and extract it somewhere
 #
 # In pillar, you'd format like this:
 #
 # foobar:
 #   /opt/pypy:
 #     href: https://bitbucket.org/pypy/pypy/downloads/pypy-2.5.1-linux.tar.bz2
 #   /srv/webapps/publican/spec-data:
 #     href: https://renoirboulanger.com/spec-data.tar.bz2
 #     user: webapps
 #
 # ... and use in a state like this:
 #
 # {% from "basesystem/macros/unpacker.sls" import unpack_remote_loop %}
 # {% set foobar = salt['pillar.get']('foobar') %}
 # {{ unpack_remote_loop(foobar)}}
 #
 # ... or directly ...
 #
 # {{ unpack_remote('/opt/pypy', 'https://bitbucket.org/pypy/pypy/downloads/pypy-2.5.1-linux.tar.bz2') }}
 #}
{% macro unpack_remote(creates, href, args={}) %}

{% set user = args.get('user', None) %}

{% set fileName = href.split('/')|last() %}

{% set baseName = fileName.split('.')[0] %}

{% set extension = fileName.split('.')|last() %}

{% set downloadTo = creates.replace('/' ~ creates.split('/')|last(), '') %}
{% set expectedFilePath = downloadTo ~ '/' ~ fileName %}
{% set expectedExtractedDir = downloadTo ~ '/' ~ baseName %}

{% set supportedHandlers = {
     'zip': 'unzip'
    ,'bz2': 'bzip2'
    ,'gz':  'gzip'
  } %}

{% if extension == 'zip' %}
{% set extractCommand = 'unzip ' ~ expectedFilePath ~ ' -d ' ~ downloadTo %}
{% elif extension == 'bz2' %}
{% set extractCommand = 'mkdir -p "' ~ creates ~ '" && tar xfj ' ~ expectedFilePath ~ ' --strip-components=1 -C "' ~ creates ~ '"' %}
{% elif extension == 'gz' %}
{% set extractCommand = 'mkdir -p "' ~ creates ~ '" && tar xfz ' ~ expectedFilePath ~ ' --strip-components=1 -C "' ~ creates ~ '"' %}
{% endif %}

Unpack {{ creates }}:
  file.directory:
    - name: {{ downloadTo }}
{% if user %}
    - user: {{ user }}
{% endif %}
  pkg.installed:
    - name: {{ supportedHandlers[extension] }}
  cmd.run:
    - name: |
        if [[ -f "/var/cache/unpack/{{ fileName }}" ]] ; then
          cp "/var/cache/unpack/{{ fileName }}" "{{ expectedFilePath }}"
          {{ extractCommand }}
          rm "/var/cache/unpack/{{ fileName }}"
        else
          echo {{ href }} | xargs wget -qO- -O {{ expectedFilePath }}; {{ extractCommand }}
        fi
    - creates: {{ creates }}
    - cwd: {{ downloadTo }}
{% if user %}
    - user: {{ user }}
{% endif %}

Archive {{ fileName }}:
  file.directory:
    - name: /var/cache/unpack
  cmd.run:
    - name: |
        mv {{ expectedFilePath }} /var/cache/unpack/{{ fileName }}
        chown root:root /var/cache/unpack/{{ fileName }}
    - onlyif: test -f {{ expectedFilePath }} && test ! -f /var/cache/unpack/{{ fileName }}
    - creates: /var/cache/unpack/{{ fileName }}

{% endmacro %}

{% macro unpack_remote_loop(list) %}
{% if list|count >= 1 %}
{% for creates,args in list.items() %}
{{ unpack_remote(creates, args.href, args) }}
{% endfor %}
{% endif %}
{% endmacro %}
