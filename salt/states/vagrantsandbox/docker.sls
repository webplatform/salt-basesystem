# ref: https://github.com/saltstack-formulas/docker-formula
{%- set kernelrelease = salt['grains.get']('kernelrelease') %}

include:
  - docker

Docker linux-kernel deps:
  pkg.installed:
    - pkgs:
      - linux-image-extra-{{ kernelrelease }}
      - aufs-tools
  cmd.run:
    - name: modprobe aufs
    - unless: modinfo aufs > /dev/null 2>&1
