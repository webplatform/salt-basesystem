/etc/salt/minion.d/docker.conf:
  file.managed:
    - source: salt://vagrantsandbox/files/salt/docker.conf

python-git:
  pkg.installed

