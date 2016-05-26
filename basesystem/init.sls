webapps:
  user.present:
    - fullname: Web Application runner user
    - shell: /bin/bash
    - home: /srv/webapps
    - createhome: True
    - system: True
    - uid: 990
    - groups:
      - www-data
  group.present:
    - gid: 990
    - system: True
    - members:
      - webapps

/srv/webapps:
  file.directory:
    - user: webapps
    - group: webapps

/srv/webapps/.ssh:
  file.directory:
    - createdirs: True
    - user: webapps
    - group: webapps
    - mode: 0700

/etc/profile.d/lazy_aliases.sh:
  file.managed:
    - source: salt://basesystem/files/lazy_aliases.sh
    - mode: 755
    - group: users

Ensure common package dependencies:
  pkg.installed:
    - pkgs:
      - software-properties-common

Global projects supported dependencies and locales:
  pkg.installed:
    - name: locales
  cmd.run:
    - names:
      - locale-gen en_US.utf8
      - dpkg-reconfigure locales

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

/etc/apt/apt.conf.d/20auto-upgrades:
  file.managed:
    - contents: |
        APT::Periodic::Update-Package-Lists "1";
        APT::Periodic::Unattended-Upgrade "1";

# ref: http://hardenubuntu.com/server-setup/disable-irqbalance
/etc/default/irqbalance:
  file.managed:
    - source: salt://basesystem/files/irqbalance

Timekeeping packages and APT over TLS:
  pkg.installed:
    - pkgs:
      - ntp
      - ntpdate
      - apt-transport-https
  file.managed:
    - name: /etc/default/ntpdate
    - contents: |
        # Managed by Salt
        NTPDATE_USE_NTP_CONF=yes
        NTPSERVERS="us.pool.ntp.org"
        NTPOPTIONS="-g"

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
