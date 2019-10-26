FROM perl:latest

COPY back/bin/entrypoint.sh /docker_bin/

RUN true \
	&& cpanm Starman \
	&& chmod a+x /docker_bin/* \
	&& true

ENTRYPOINT ["/docker_bin/entrypoint.sh"]
