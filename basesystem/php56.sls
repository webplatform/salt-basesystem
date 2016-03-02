Setup PHP 5.6 dependencies:
  pkgrepo.managed:
    - humanname: ondrejphp5
    - dist: {{ salt['grains.get']('oscodename') }}
    - keyid: E5267A6C
    - keyserver: keyserver.ubuntu.com
    # See https://launchpad.net/~ondrej/+archive/ubuntu/php5-5.6
    - name: deb http://ppa.launchpad.net/ondrej/php5-5.6/ubuntu {{ salt['grains.get']('oscodename') }} main
    # See https://launchpad.net/~ondrej/+archive/ubuntu/php5
    #- name: deb http://ppa.launchpad.net/ondrej/php5/ubuntu {{ salt['grains.get']('oscodename') }} main
    - file: /etc/apt/sources.list.d/ondrej-php5-5_6-trusty.list
  pkg.installed:
    - pkgs:
      - php5
      - php5-xcache
      - php5-mysqlnd
      - php5-cli

## START COPY-PASTA https://github.com/saltstack-formulas/php-formula/blob/master/php/composer.sls
install-composer:
  pkg.installed:
    - name: curl
  cmd.run:
    - names:
      - "curl -sS https://getcomposer.org/installer -o /root/composer-installer"
      - "php /root/composer-installer --filename=composer --install-dir=/usr/bin"
    - unless: test -f /usr/bin/composer

#update-composer:
#  cmd.run:
#    - name: "/usr/bin/composer selfupdate
#    - unless: |
#        test $(grep --text COMPOSER_DEV_WARNING_TIME /usr/bin/composer | egrep '^\s*define' | sed -e 's,[^[:digit:]],,g') \> $(php -r 'echo time();')
#    - require:
#      - cmd: install-composer

## END COPY-PASTA
