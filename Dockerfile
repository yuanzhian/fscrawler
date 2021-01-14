FROM toto1310/fscrawler:2.7-SNAPSHOT-es7-nolang

VOLUME /root/.fscrawler

VOLUME /tmp/es:ro

COPY ${PWD}/config /root/.fscrawler

COPY ${PWD}/data /tmp/es:ro

CMD ["fscrawler", "--trace", "--config_dir", "/root/.fscrawler", "code_search"]

 
