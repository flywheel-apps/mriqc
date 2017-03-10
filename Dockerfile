# flywheel/mriqc

# Get the MRIQC algorithm from DockerHub
FROM poldracklab/mriqc:0.9.0-0
MAINTAINER Jennifer Reiter <jenniferreiter@invenshure.com>

# Install wget
RUN apt-get update && apt-get -y install wget

# Install jq to parse the JSON config file
RUN wget -N -qO- -O /usr/bin/jq http://stedolan.github.io/jq/download/linux64/jq
RUN chmod +x /usr/bin/jq

# Make directory for flywheel spec (v0)
ENV FLYWHEEL /flywheel/v0
RUN mkdir -p ${FLYWHEEL}
COPY run ${FLYWHEEL}/run
COPY manifest.json ${FLYWHEEL}/manifest.json

# ENV preservation for Flywheel Engine
RUN env -u HOSTNAME -u PWD > ${FLYWHEEL}/docker-env.sh

# Set the entrypoint
ENTRYPOINT ["/flywheel/v0/run"]
