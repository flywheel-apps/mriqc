#flywheel/mriqc

# Get the MRIQC algorithm from DockerHub
FROM poldracklab/mriqc:0.16.1
MAINTAINER Flywheel <support@flywheel.io>

# Install jq to parse the JSON config file
RUN apt-get update && apt-get -y install jq zip
# RUN apt-get install -y python3

# Install patched version of xvfbwrapper
RUN pip install -q https://github.com/ehlertjd/xvfbwrapper/releases/download/0.2.9.post1/xvfbwrapper-0.2.9.post1-py2.py3-none-any.whl
RUN pip install beautifulsoup4==4.8.2

# Make directory for flywheel spec (v0)
ENV FLYWHEEL /flywheel/v0
RUN mkdir -p ${FLYWHEEL}
COPY run ${FLYWHEEL}/run
COPY singularity.py ${FLYWHEEL}/singularity.py
COPY manifest.json ${FLYWHEEL}/manifest.json
COPY remove_rate_widget.py ${FLYWHEEL}/remove_rate_widget.py
# ENV preservation for Flywheel Engine
RUN env -u HOSTNAME -u PWD | \
  awk -F = '{ print "export " $1 "=\"" $2 "\"" }' > ${FLYWHEEL}/docker-env.sh

RUN echo "export XVFB_WRAPPER_SOFT_FILE_LOCK=1" >> ${FLYWHEEL}/docker-env.sh

# Set the entrypoint
ENTRYPOINT ["/flywheel/v0/run"]
