FROM rocker/hadleyverse
MAINTAINER Marc A. Suchard <msuchard@ucla.edu>

RUN apt-get update && apt-get install -y python-dev

## Install Rserve
RUN install2.r \
	Rserve \
	RSclient \
	openssl \
	httr \
	xml2 \
&& rm -rf /tmp/download_packages/ /tmp/*.rds

## Install OHDSI R packages
RUN installGithub.r \
	OHDSI/SqlRender \
	OHDSI/DatabaseConnector \
	OHDSI/Achilles \
	OHDSI/Cyclops \
	OHDSI/OhdsiRTools \
	OHDSI/FeatureExtraction \
	OHDSI/PatientLevelPrediction \
	OHDSI/CohortMethod \
	OHDSI/PublicOracle \
	hadley/xml2 \
	cloudyr/aws.s3 \
	OHDSI/OhdsiSharing \
	OHDSI/StudyProtocols/KeppraAngioedema \
&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds


COPY Rserv.conf /etc/Rserv.conf
COPY startRserve.R /usr/local/bin/startRserve.R

EXPOSE 8787
EXPOSE 6311

RUN apt-get update && apt-get install -y supervisor

RUN echo "" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "[supervisord]" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "[program:Rserve]" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "command=/usr/local/bin/startRserve.R" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "[program:RStudio]" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "command=/init" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "stdout_logfile=/var/log/supervisor/%(program_name)s.log" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "stderr_logfile=/var/log/supervisor/%(program_name)s.log" >> /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
