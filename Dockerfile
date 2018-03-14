FROM alpine:3.7

RUN apk update
RUN apk add --no-cache -t .build-deps wget ca-certificates gnupg openssl openjdk8-jre curl dcron bash su-exec
RUN rm -rf /var/cache/apk/*


##################
## Install gosu ##
##################
RUN curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.10/gosu-arm64"
RUN chmod +x /usr/local/bin/gosu

###########################
## Install elasticsearch ##
###########################

ENV ES_VERSION 6.2.1

RUN wget -qO /tmp/es.tgz https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.2.1.tar.gz && \
  cd /usr/share && \
  tar xf /tmp/es.tgz && \
  rm /tmp/es.tgz

ENV ES_HOME /usr/share/elasticsearch-$ES_VERSION
ENV ES_TMPDIR /usr/share/elasticsearch/tmp
RUN adduser -D -h $ES_HOME elasticsearch
RUN chown -R elasticsearch: $ES_HOME
RUN mkdir /conf && touch /conf/.CREATED && chown -R elasticsearch: /conf
RUN mkdir /test-0 && mkdir /test-1
#### Install essential elasticsearch plugins ####
RUN $ES_HOME/bin/elasticsearch-plugin install repository-s3

########################
## Install log Rotate ##
########################
RUN echo '*/5 * * * * /usr/sbin/logrotate /etc/logrotate.conf' | crontab -

#######################
## Configure startup ##
#######################

ADD start /start
ADD gstop /gstop

WORKDIR $ES_HOME

EXPOSE 9200 9300

CMD ["/start"]
