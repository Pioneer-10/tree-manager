FROM perl:latest

WORKDIR /app

COPY back/bin/entrypoint.sh /docker_bin/

RUN true \
	&& cpanm Starman \
	&& cpanm DBI \
	&& cpanm DBD::SQLite \
	&& cpanm Routes::Tiny \
	&& cpanm Template::Toolkit \
	&& chmod a+x /docker_bin/* \
	&& true

COPY back/bin/init_db.pl /docker_bin/

RUN perl /docker_bin/init_db.pl

ENTRYPOINT ["/docker_bin/entrypoint.sh"]
