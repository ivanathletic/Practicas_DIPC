#!/bin/bash

#pasamos el certificado SSL del servidor al cliente
scp server@192.168.34.150:/etc/pki/tls/certs/logstash-forwarder.crt /tmp

mkdir -p /etc/pki/tls/certs
cp /tmp/logstash-forwarder.crt /etc/pki/tls/certs/


#instalamos filebeat
echo "deb https://packages.elastic.co/beats/apt stable main" | sudo tee -a /etc/apt/sources.list.d/beats.list
apt-get update
apt-get install filebeat


#editamos el fichero de configuracion de filebeat
sed -i 's/\- \/var\/log\/\*.log/\- \/var\/log\/auth.log\n        \- \/var\/log\/.syslog/' /etc/filebeat/filebeat.yml

sed -i 's/#document\_type\: log/ document\_type\: syslog/' /etc/filebeat/filebeat.yml

sed -i '/elasticsearch:/,/\"\]/d' /etc/filebeat/filebeat.yml

#descomentamos la seccion de logstash añadiendo la parte de tls
sed -i '/s\#logstash/ logstash:\n    hosts: ["192.168.34.150:5044"]\n    bulk_max_size: 1024\n    tls:\n     certificate_authorities: ["\/etc\/pki\/tls\/certs\/logstash-forwarder.crt"]/'  /etc/filebeat/filebeat.yml

#reiniciamos filebeat
systemctl restart filebeat
systemctl enable filebeat