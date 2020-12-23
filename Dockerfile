FROM ubuntu:16.04

#不写会中文乱码
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y openjdk-8-jdk
RUN apt-get update && apt-get install -y unzip wget

WORKDIR /runtime

ENV FS_BRANCH=fscrawler-2.6
ENV FS_UPSTREAM=dadoonet

#----------------------------
RUN wget https://github.com/$FS_UPSTREAM/fscrawler/archive/$FS_BRANCH.zip
RUN unzip $FS_BRANCH.zip

WORKDIR /runtime/fscrawler-$FS_BRANCH

ENV FSCRAWLER_VERSION=2.6

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

ENTRYPOINT ["/entry.sh"]
CMD ["fscrawler", "--trace", "--rest", "--config_dir", "/usr/share/fscrawler/config", "myjob"]
