# flywheel/mriqc

# External Dependencies for MRIQC
#  FSL
#  N4ITK bias correcton released with ANTs
#  AFNI

# start with ubuntu // Or do we use our freesurfer docker container?
FROM poldracklab/mriqc:0.9.0-0

# Make directory for flywheel spec (v0)
ENV FLYWHEEL /flywheel/v0
RUN mkdir -p ${FLYWHEEL}
COPY run.sh ${FLYWHEEL}/run
COPY manifest.json ${FLYWHEEL}/manifest.json

# Install wget
RUN apt-get update && apt-get -y install wget
# Install jq to parse the JSON config file
RUN wget -N -qO- -O /usr/bin/jq http://stedolan.github.io/jq/download/linux64/jq
RUN chmod +x /usr/bin/jq

# Set the entrypoint
ENTRYPOINT ["/flywheel/v0/run"]
