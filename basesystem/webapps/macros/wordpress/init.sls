{#
 # ref:
 #   - https://gist.github.com/renoirb/1b42edac44c723185c9d
 #   - http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#jinja-macros
 #   - http://www.pluginmirror.com/plugins
 #}
{% macro wordpress_plugin(name, versionIdentifier, handler, wpDocroot, gitRepo=None) -%}

Install WordPress {{ name }} plugin using {{ handler }}:
{%- if handler == 'zip' %}
  pkg.installed:
    - name: unzip
  cmd.run:
    - name: echo https://downloads.wordpress.org/plugin/{{ name ~ '.' ~ versionIdentifier }}.zip | xargs wget -qO- -O  {{ wpDocroot }}/wp-content/plugins/{{ name }}.zip; unzip {{ wpDocroot }}/wp-content/plugins/{{ name }}.zip -d {{ wpDocroot }}/wp-content/plugins
    - unless: test -d {{ wpDocroot }}/wp-content/plugins/{{ name }}
    - creates: {{ wpDocroot }}/wp-content/plugins/{{ name ~ '.' ~ versionIdentifier }}.zip
{% endif -%}

{%- if handler == 'git' %}
  pkg.installed:
    - name: git
  git.latest:
    - name: {{ gitRepo|default('https://github.com/wp-plugins/' ~ name) }}
    - rev: {{ versionIdentifier }}
    - target: {{ wpDocroot }}/wp-content/plugins/{{ name }}
    - unless: test -d {{ wpDocroot }}/wp-content/plugins/{{ name }}/.git
    - submodules: True
{% endif -%}

{#%- if handler == 'subversion' %}
# NEEDS TESTING!!

  pkg.installed:
    - name: subversion
  svn.latest:
    - name: http://plugins.svn.wordpress.org/{{ name }}/tags/{{ versionIdentifier }}
    - target: {{ wpDocroot }}/wp-content/plugins/{{ name }}

{% endif -%#}

{%- endmacro %}

{% macro wordpress_cronjob(name, wpDocroot, user='root') %}
cd {{ wpDocroot }}; php -q wp-cron.php:
  cron.present:
    - user: {{ user }}
    - minute: 0
    - identifier: CRON-WordPress-{{ name }}
{% endmacro %}
