FROM docker.elastic.co/logstash/logstash:6.6.1
ADD /logstash-config /usr/share/logstash/config-rabbitmq
