/etc/salt/minion.d/docker.conf:
  file.managed:
    - source: salt://vagrantsandbox/files/salt/docker.conf

python-git:
  pkg.installed

vagrant:
  user.present:
    - createhome: False
    - groups:
      - www-data
  group.present:
    - addusers:
      - webapps
      - vagrant

/srv/appshomedir/workspace:
  file.symlink:
    - target: /vagrant
    - makedirs: True

