Setup Node.js dependencies:
  pkgrepo.managed:
    - humanname: nodesource
    - name: deb https://deb.nodesource.com/node_4.x {{ salt['grains.get']('oscodename') }} main
    - file: /etc/apt/sources.list.d/nodesource.list
    - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
  pkg.installed:
    - pkgs:
      - rlwrap
      - nodejs: "4.3.1-1nodesource1~trusty1"
  cmd.wait:
    - names:
      - "npm install npm -g"
      - "npm install -g bower grunt-cli"
    - unless: test -f /usr/local/lib/node_modules/grunt-cli/bin/grunt
