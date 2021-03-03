FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
RUN echo "tzdata tzdata/Areas select Asia" >> preseed.txt && echo "tzdata tzdata/Zones/Asia select Kolkata" >> preseed.txt && debconf-set-selections preseed.txt
RUN apt-get update
RUN apt-get -d install -y openjdk-8-jdk python2 python2-dev build-essential software-properties-common byobu curl git htop man unzip nano wget
RUN apt-get install -y python2 python2-dev byobu curl git htop man unzip nano wget
COPY code-server-install.sh /
RUN chmod +x /code-server-install.sh && ./code-server-install.sh
RUN curl https://bootstrap.pypa.io/get-pip.py --output get-pip.py
RUN python2 get-pip.py
RUN python2 -m pip install pytest
RUN apt-get install -y openjdk-8-jdk
RUN echo "tzdata tzdata/Areas select Asia" >> preseed.txt && echo "tzdata tzdata/Zones/Asia select Kolkata" >> preseed.txt && debconf-set-selections preseed.txt
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV GIT_SSL_NO_VERIFY=1
ENV MAJOR_HADOOP_VERSION=2.7
ENV SPARK_VERSION=v2.3.0
ENV MAVEN_OPTS="-Xmx2g -XX:ReservedCodeCacheSize=512m"
RUN git clone  --depth 1 --branch ${SPARK_VERSION} https://github.com/apache/spark.git
RUN mkdir -p /root/bdp/tools && cd /root/bdp/tools && git clone  --depth 1 --branch ${SPARK_VERSION} https://github.com/apache/spark.git
RUN cd /root/bdp/tools/spark && ./build/mvn -Pyarn -Pmesos -Phive -Phive-thriftserver -Phadoop-${MAJOR_HADOOP_VERSION} -Dhadoop.version=${MAJOR_HADOOP_VERSION}.0 -DskipTests clean package
EXPOSE 8080
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]











