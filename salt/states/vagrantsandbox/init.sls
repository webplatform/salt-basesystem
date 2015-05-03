/etc/salt/minion.d/docker.conf:
  file.managed:
    - source: salt://vagrantsandbox/files/salt/docker.conf

python-git:
  pkg.installed

/home/vagrant/README.md:
  file.managed:
    - contents: |
        Hi, this is your local Vagrant masterless salt workspace!

        ## If your base system uses Docker

        ```
        salt-call state.sls vagrantsandbox.docker
        docker pull ubuntu:trusty
        docker run -a ubuntu:trusty bash
        ```

        ... and you’re in Vagrant, that’s running a Docker container.

