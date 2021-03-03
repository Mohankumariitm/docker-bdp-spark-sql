FROM ubuntu:latest
LABEL maintainer="mohankumarelec@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN echo "tzdata tzdata/Areas select Asia" >> preseed.txt && echo "tzdata tzdata/Zones/Asia select Kolkata" >> preseed.txt && debconf-set-selections preseed.txt
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk python2 python2-dev build-essential software-properties-common curl git man unzip nano wget && \
    rm -rf /var/lib/apt/lists/* 

RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    curl https://bootstrap.pypa.io/2.7/get-pip.py --output get-pip.py && \
    python2 get-pip.py && \
    python2 -m pip install pytest && \
    ln -s /usr/bin/python2 /usr/bin/python

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV MAJOR_HADOOP_VERSION=2.7
ENV SPARK_VERSION=v2.3.0
ENV MAVEN_OPTS="-Xmx2g -XX:ReservedCodeCacheSize=512m"

RUN git clone  --depth 1 --branch ${SPARK_VERSION} https://github.com/apache/spark.git
RUN mkdir -p /root/bdp/tools && cd /root/bdp/tools && git clone  --depth 1 --branch ${SPARK_VERSION} https://github.com/apache/spark.git
RUN cd /root/bdp/tools/spark && \
    ./build/mvn -Pyarn -Pmesos -Phive -Phive-thriftserver -Phadoop-${MAJOR_HADOOP_VERSION} -Dhadoop.version=${MAJOR_HADOOP_VERSION}.0 -DskipTests clean package && \
    cd /root/bdp/tools/spark/python && \
    python2 setup.py install

EXPOSE 8080
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]










