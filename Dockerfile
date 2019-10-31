FROM ubuntu
LABEL maintainer="Julian Nonino <noninojulian@gmail.com>"

# Install required tools, tar, curl, net-tools and Java JRE
RUN apt-get update -y && \
    apt-get install -y tar curl net-tools iproute2 netcat nbtscan openjdk-8-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Zookeeper
ENV ZOOKEEPER_VERSION 3.5.6
RUN curl -O http://apache.mirror.anlx.net/zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz && \
    tar -xvf apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz && \
    rm -rf apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz && \
    mv apache-zookeeper-$ZOOKEEPER_VERSION-bin zookeeper && \
    mv zookeeper /opt
ENV ZOOKEEPER_HOME /opt/zookeeper
ENV PATH $ZOOKEEPER_HOME/bin:$ZOOKEEPER_HOME/lib:$PATH
WORKDIR /opt/zookeeper

RUN cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg && \
    echo "standaloneEnabled=false" >> /opt/zookeeper/conf/zoo.cfg && \
    echo "reconfigEnabled=true" >> /opt/zookeeper/conf/zoo.cfg && \
    echo "skipACL=yes" >> /opt/zookeeper/conf/zoo.cfg && \
    echo "dynamicConfigFile=/opt/zookeeper/conf/zoo.cfg.dynamic" >> /opt/zookeeper/conf/zoo.cfg

# Expose:
#   - Client Port (2181)
#   - Follower Port (2888)
#   - Election Port (3888)
EXPOSE 2181 2888 3888

COPY start.sh /usr/local/bin
ENTRYPOINT [ "/usr/local/bin/start.sh" ]