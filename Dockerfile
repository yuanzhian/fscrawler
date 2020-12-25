FROM ubuntu:16.04

#不写会中文乱码
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y openjdk-8-jdk
RUN apt-get update && apt-get install -y unzip wget

WORKDIR /runtime

ENV FS_BRANCH=2.6-SNAPSHOT
ENV FS_ZIP_FILE=fscrawler-2.6-20180922.161450-7.zip
RUN wget https://oss.sonatype.org/content/repositories/snapshots/fr/pilato/elasticsearch/crawler/fscrawler/2.6-SNAPSHOT/$FS_ZIP_FILE
RUN unzip $FS_ZIP_FILE

WORKDIR /runtime/fscrawler-$FS_BRANCH

ENV FSCRAWLER_VERSION=2.6-SNAPSHOT

RUN mkdir -p /usr/share/fscrawler/config

WORKDIR /usr/share/fscrawler
ENV PATH /usr/share/fscrawler/bin:$PATH

# ensure fscrawler user exists
RUN addgroup --system fscrawler && adduser --system --ingroup fscrawler fscrawler

# grab su-exec (alpine) or gosu (ubuntu) for easy step-down from root
# and bash for "bin/fscrawler" among others
RUN apt-get update && apt-get install -y gosu bash openssl

RUN cp -rf /runtime/fscrawler-$FS_BRANCH/* ./

RUN rm -rf /runtime

VOLUME /usr/share/fscrawler/data
RUN mkdir /usr/share/fscrawler/config-mount \
  && touch /usr/share/fscrawler/config-mount/empty

COPY entry.sh /

COPY code_search /config-mount/code_search/
COPY _settings.json /config/_default/6/

RUN chmod +x /entry.sh

ENTRYPOINT ["/entry.sh"]

CMD ["fscrawler", "--trace", "--config_dir", "/usr/share/fscrawler/config", "code_search"]

