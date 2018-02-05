FROM ubuntu:xenial
LABEL maintainer="Julian Nonino <noninojulian@outlook.com>"

# Install required tools, tar, curl, net-tools and Java JRE
RUN apt-get update -y && \
    apt-get install -y tar curl net-tools iproute netcat nbtscan openjdk-8-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Zookeeper
ENV ZOOKEEPER_VERSION 3.5.3-beta
RUN curl -O http://www-us.apache.org/dist/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz && \
    tar -xvf zookeeper-$ZOOKEEPER_VERSION.tar.gz && \
    rm -rf zookeeper-$ZOOKEEPER_VERSION.tar.gz && \
    mv zookeeper-$ZOOKEEPER_VERSION zookeeper && \
    mv zookeeper /opt
ENV ZOOKEEPER_HOME /opt/zookeeper
ENV PATH $ZOOKEEPER_HOME/bin:$ZOOKEEPER_HOME/lib:$PATH
WORKDIR /opt/zookeeper

RUN cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg && \
    echo "standaloneEnabled=false" >> /opt/zookeeper/conf/zoo.cfg && \
    echo "dynamicConfigFile=/opt/zookeeper/conf/zoo.cfg.dynamic" >> /opt/zookeeper/conf/zoo.cfg

#  conf_dir: /etc/zookeeper/conf
#  data_dir: /var/lib/zookeeper
#  log_dir: /var/log/zookeeper
#  path: /opt/zookeeper
#  dynamic_conf_file: /etc/zookeeper/conf/zoo.cfg.dynamic


# Expose:
#   - Client Port (2181)
#   - Follower Port (2888)
#   - Election Port (3888)
EXPOSE 2181 2888 3888

COPY start.sh /usr/local/bin
CMD ["/usr/local/bin/start.sh"]
