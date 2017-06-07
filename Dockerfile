#flywheel/mriqc

# Get the MRIQC algorithm from DockerHub
FROM poldracklab/mriqc:0.9.4
MAINTAINER Flywheel <support@flywheel.io>

# Install jq to parse the JSON config file
RUN apt-get update && apt-get -y install jq

# Make directory for flywheel spec (v0)
ENV FLYWHEEL /flywheel/v0
RUN mkdir -p ${FLYWHEEL}
COPY run ${FLYWHEEL}/run
COPY manifest.json ${FLYWHEEL}/manifest.json

# ENV preservation for Flywheel Engine
RUN env -u HOSTNAME -u PWD | \
  awk -F = '{ print "export " $1 "=\"" $2 "\"" }' > ${FLYWHEEL}/docker-env.sh

# Set the entrypoint
ENTRYPOINT ["/flywheel/v0/run"]
