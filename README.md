[![Docker Pulls](https://img.shields.io/docker/pulls/flywheel/mriqc.svg)](https://hub.docker.com/r/flywheel/mriqc/)
[![Docker Stars](https://img.shields.io/docker/stars/flywheel/mriqc.svg)](https://hub.docker.com/r/flywheel/mriqc/)
# flywheel/mriqc
Image quality metrics for quality assessment of MRI

Build context for a [Flywheel Gear](https://github.com/flywheel-io/gears/tree/master/spec) which runs the `mriqc` tool (v0.9.4).
For more information see [MRIQC's documentation](http://mriqc.readthedocs.io/en/0.9.4/)

* This Flywheel MRIQC gear allows either a Structural (T1w or T2w) or Functional MRI image as input
* You can change ```build.sh``` to edit the repository name for the image (default=`flywheel/mriqc`).
* The resulting image is ~5GB

### Build the Image
To build the image:
```
git clone https://github.com/flywheel-apps/mriqc
cd mriqc && docker build -t flywheel/mriqc .
```

### Example Local Usage
To run the `mriqc` command in this image on your local instance, do the following:
```
docker run --rm -ti \
  -v </path/to/input/data>:/flywheel/v0/input/nifti \
  -v </path/for/output/data>:/flywheel/v0/output \
  flywheel/mriqc
```
Usage notes:
  * You are mounting the directory (using the ```-v``` flag) which contains the input data in the container at ```/flywheel/v0/input/nifti``` and mounting the directory where you want your output data within the container at ```/flywheel/v0/output```.
  * The "input" directory (mounted within the container at ```/flywheel/v0/input/nifti```) should contain only the file you wish to perform the quality metrics on.
  * No input arguments are required for the container to be executed
  * If a Structural (T1w or T2w) MRI image is given as input, the filename needs to be in BIDS format OR a config file indicating the input image is "Structural" must be generated and placed in the appropriate location (```/flywheel/v0/config.json```)


<br>

 _Gear Author: Jennifer Reiter <<jenniferreiter@invenshure.com>>. Flywheel 2017._
