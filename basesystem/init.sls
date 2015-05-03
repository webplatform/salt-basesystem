# ref: https://github.com/saltstack-formulas/docker-formula
{%- set kernelrelease = salt['grains.get']('kernelrelease') %}

Commonly used utilities:
  pkg.installed:
    - pkgs:
      - screen
      - htop
      - monkeytail
      - vim
      - vim-common

# ref: http://hardenubuntu.com/initial-setup/system-updates
unattended-upgrades:
  debconf.set:
    - data:
        'unattended-upgrades/enable_auto_updates':
          type: boolean
          value: "true"

  cmd.wait:
    - name: "dpkg-reconfigure unattended-upgrades"
    - watch:
      - debconf: unattended-upgrades
    - env:
        DEBIAN_FRONTEND: noninteractive
        DEBCONF_NONINTERACTIVE_SEEN: "true"

# ref: http://hardenubuntu.com/server-setup/disable-irqbalance
/etc/default/irqbalance:
  file.managed:
    - source: salt://basesystem/files/irqbalance

# apport: ref: http://hardenubuntu.com/disable-services/disable-apport
Remove non-needed packages:
  pkg.purged:
    - pkgs:
      - landscape-common
      - landscape-client
      - whoopsie
      - apport
      - at
      - avahi-daemon
      - avahi-utils

Docker linux-kernel deps:
  pkg.installed:
    - pkgs:
      - linux-image-extra-{{ kernelrelease }}
      - aufs-tools
  cmd.run:
    - name: modprobe aufs
    - unless: modinfo aufs > /dev/null 2>&1

