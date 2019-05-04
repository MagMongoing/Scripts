minion_install:
  cmd.run:
    - name: curl -L https://bootstrap.saltstack.com -o install_salt.sh &&  sh install_salt.sh -P
    - unless: rpm -qa|grep salt-minion
minion_conf:
  file.managed:
    - name: /etc/salt/minion
    - source: salt://minions/files/minion
    - template: jinja
    - defaults:
      minion_id: {{grains['nodename']}}
#    - require:
#      - cmd: minion_install
salt_service:
  service.running:
    - name: salt-minion
    - enable: True
    - require:
      - file: minion_conf
  cmd.run:
    - name: systemctl restart salt-minion
