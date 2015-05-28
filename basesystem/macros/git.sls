{#
 #
 # In pillar, you'd format like this:
 #
 # foo:
 #   /var/www/html:
 #     origin: https://github.com/webplatform/salt-basesystem.git
 #     user: vagrant
 #     auth_key: /home/vagrant/.ssh/id_rsa
 #   /srv/webapps/publican:
 #     origin: https://github.com/webplatform/publican.git
 #     branch: task-based-docker
 #     before:
 #       - /srv/webapps/publican/spec-data
 #     remotes:
 #       upstream: https://github.com/webspecs/publican.git
 #
 # ... and use in a state like this:
 #
 # {% from "basesystem/macros/git.sls" import git_clone_loop %}
 # {% set foo = salt['pillar.get']('foo') %}
 # {{ git_clone_loop(foo) }}
 #}
{% macro git_clone(creates, origin, args={}) %}

{% set user = args.get('user', None) %}
{% set auth_key = args.get('auth_key', None) %}

{% set branchName = args.get('branch', 'master') %}
{% set remotes = args.get('remotes') %}

{% set before_unpack_remote = args.get('before', []) %}

Clone {{ creates }}:
  file.directory:
    - name: {{ creates }}
{% if user %}
    - user: {{ user }}
{% endif %}
{% if before_unpack_remote|count() >= 1 %}
    - watch_in:
{% for archive_dest in before_unpack_remote %}
      - file: Unpack {{ archive_dest }}
{% endfor %}
{% endif %}
  git.latest:
    - name: {{ origin }}
    - rev: {{ branchName }}
    - target: {{ creates }}
    - unless: test -d {{ creates }}/.git
{% if user %}
    - user: {{ user }}
{% endif %}
{% if auth_key %}
    - identity: {{ auth_key }}
{% endif %}
{% for remote_name,remote in remotes.items() %}
{% if remote_name != 'origin' %}
  cmd.run:
    - name: git remote add {{ remote_name }} {{ remote }}
    - unless: grep -q -e 'remote "{{ remote_name }}' .git/config
    - cwd: {{ creates }}
{% if user %}
    - user: {{ user }}
{% endif %}
{% endif %}
{% endfor %}
{% endmacro %}



{% macro git_clone_loop(list) %}
{% if list|count >= 1 %}
{% for dir,obj in list.items() %}
{{ git_clone(dir, obj.origin, obj) }}
{% endfor %}
{% endif %}
{% endmacro %}
