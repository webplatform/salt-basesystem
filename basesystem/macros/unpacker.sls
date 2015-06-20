{#
 # Packer macros
 #
 # Pack and Unpack compressed archives
 #
 # This set of macro allows to download from a remote server
 # into a folder and makes sure the file structure remains.
 #}



{#
 # Download and unpack an archive to a directory
 #
 # Refer to the [README.md](https://github.com/webplatform/salt-basesystem)
 #}
{% macro unpack_remote(href, dest, args={}) %}

{% set user = args.get('user', None) %}

{% set fileName = href.split('/')|last() %}
{% set baseName = fileName.split('.')[0] %}
{% set extension = fileName.split('.')|last() %}

{% set downloadTo = dest.replace('/' ~ dest.split('/')|last(), '') %}
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
{% set extractCommand = 'mkdir -p "' ~ dest ~ '" && tar xfj ' ~ expectedFilePath ~ ' --strip-components=1 -C "' ~ dest ~ '"' %}
{% elif extension == 'gz' %}
{% set extractCommand = 'mkdir -p "' ~ dest ~ '" && tar xfz ' ~ expectedFilePath ~ ' --strip-components=1 -C "' ~ dest ~ '"' %}
{% endif %}

Packager unpack {{ dest }}:
  file.directory:
    - name: {{ downloadTo }}
{% if user %}
    - user: {{ user }}
{% endif %}
  pkg.installed:
    - name: {{ supportedHandlers[extension] }}
  cmd.run:
    - stateful: True
    - name: |
        if [[ -f "/var/cache/unpack/{{ fileName }}" ]] ; then
          cp "/var/cache/unpack/{{ fileName }}" "{{ expectedFilePath }}"
          {{ extractCommand }}
        else
          echo {{ href }} | xargs wget -qO- -O {{ expectedFilePath }}; {{ extractCommand }}
        fi
    - creates: {{ dest }}
    - cwd: {{ downloadTo }}
    - unless: test -d {{ dest }}
{% if user %}
    - user: {{ user }}
{% endif %}

Packager cache to /var/cache/unpack/{{ fileName }}:
  file.directory:
    - name: /var/cache/unpack
  cmd.run:
    - name: |
        if [[ ! -f "/var/cache/unpack/{{ fileName }}" ]] ; then
          mv {{ expectedFilePath }} /var/cache/unpack/{{ fileName }}
          chown root:root /var/cache/unpack/{{ fileName }}
        fi
        if [[ -f "{{ expectedFilePath }}" ]] ; then
          rm {{ expectedFilePath }}
        fi
    - creates: /var/cache/unpack/{{ fileName }}
{% endmacro %}



{% macro unpack_remote_loop(list) %}
{% if list|count >= 1 %}
{% for dest,args in list.items() %}
{{ unpack_remote(args.href, dest, args) }}
{% endfor %}
{% endif %}
{% endmacro %}
