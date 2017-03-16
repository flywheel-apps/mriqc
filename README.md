[![Docker Pulls](https://img.shields.io/docker/pulls/flywheel/mriqc.svg)](https://hub.docker.com/r/flywheel/mriqc/)
[![Docker Stars](https://img.shields.io/docker/stars/flywheel/mriqc.svg)](https://hub.docker.com/r/flywheel/mriqc/)
# flywheel/mriqc
Image quality metrics for quality assessment of MRI

Build context for a [Flywheel Gear](https://github.com/flywheel-io/gears/tree/master/spec) which runs the `mriqc` tool (v0.9.0-0).
For more information see [MRIQC's documentation](http://mriqc.readthedocs.io/en/0.9.0-0/)

* Currently, this Flywheel MRIQC gear only allows Functional MRI images as input
* You can change ```build.sh``` to edit the repository name for the image (default=`flywheel/mriqc`).
* The resulting image is ~5GB

### Build the Image
To build the image:
```
git clone https://github.com/flywheel-apps/mriqc
./build.sh
```

### Example Local Usage
To run the `mriqc` command in this image on your local instance, do the following:
```
docker run --rm -ti \
  -v </path/to/input/data>:/flywheel/v0/input/ \
  -v </path/for/output/data>:/flywheel/v0/output \
  flywheel/mriqc
```
Usage notes:
  * You are mounting the directory (using the ```-v``` flag) which contains the input data in the container at ```/flywheel/v0/input/``` and mounting the directory where you want your output data within the container at ```/flywheel/v0/output```.
  * The "input" directory (mounted within the container at ```/flywheel/v0/input/```) should contain only the file you wish to 'deface'.
  * Only the first file found in the input directory will be run through the algorithm.
  * No input arguments are required for the container to be executed
