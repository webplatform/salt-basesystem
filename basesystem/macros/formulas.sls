{%- from "basesystem/macros/git.sls" import git_clone_loop -%}

{#
 # formulas_repos should look like this in Python
 #
 # OrderedDict([('formulas', OrderedDict([('/srv/formulas/basesystem',
 #   OrderedDict([
 #     ('branch', 'master'),
 #     ('origin', 'https://github.com/renoirb/salt-basesystem.git'),
 #     ('remotes', OrderedDict([
 #       ('upstream', 'git@github.com:webplatform/salt-basesystem.git')
 #     ]))
 #   ])
 # )]))])
 #}
{% macro formulas_clone(formulas_repos=[], roots_location_parent='/etc/salt/minion.d') %}

{{ git_clone_loop(formulas_repos) }}

{{ roots_location_parent }}/roots.conf:
  file.blockreplace:
    - marker_start: "    # START Managed formula repositories -DO-NOT-EDIT-"
    - marker_end: "    # END Managed formula repositories --"
    - contents: |
        ##
        ## Managed by Salt stack, do NOT EDIT manually!
        ##
        ## BEWARE! file_roots MUST be last, as any formulas will be appended below.
        ##
        file_roots:
          base:
            - /srv/salt
    - append_if_not_found: True
    - show_changes: True

{% for creates,args in formulas_repos.items() %}
{% set slug = creates.split("/")|last() %}
Add {{ creates }} into {{ roots_location_parent }}/roots.conf:
  file.accumulated:
    - filename: {{ roots_location_parent }}/roots.conf
    - name: "Creates accumulator {{ creates }}"
    - text: "    - {{ creates }}"
    - require_in:
      - file: {{ roots_location_parent }}/roots.conf
{% endfor %}

{% endmacro %}
