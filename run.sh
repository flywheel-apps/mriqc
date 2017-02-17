#! /bin/bash
# This script is meant to evoke the algorithm without requiring any input arguments
#

# Define directory names and containers
FLYWHEEL_BASE=/flywheel/v0
INPUT_DIR=$FLYWHEEL_BASE/input
ROOTOUT_DIR=$FLYWHEEL_BASE/output
OUTPUT_DIR=$ROOTOUT_DIR/out
WORKING_DIR=$ROOTOUT_DIR/work
CONFIG_FILE=$FLYWHEEL_BASE/config.json
MANIFEST_FILE=$FLYWHEEL_BASE/manifest.json
LOG_FILE=/flywheel/v0/output/mriqc.log

(
  CONTAINER='[flywheel/mriqc]'
  # Check if the input directory is not empty
  if [[ "$(ls -A $INPUT_DIR)" ]] ; then
      echo "$CONTAINER  Starting..."
  else
      echo "Input directory is empty: $INPUT_DIR"
      exit 1
  fi

  # If config file exists, get the intent of file (Structural or Functional)
  if [[ -e $CONFIG_FILE ]] ; then
      intent=`cat $CONFIG_FILE | jq -r '.config.intent'`
      echo "Config file is present: File intent is $intent"
  # Otherwise, get the default intent of file from the manifest
  else
      intent=`cat $MANIFEST_FILE | jq -r '.config.intent.default'`
      echo "No config file found: default intent ($intent) is assumed"
  fi

  # Find input file in input directory with the extension .nii, .nii.gz
  input_file=`find $INPUT_DIR -iname '*.nii' -o -iname '*.nii.gz'`
  bni=`basename "$input_file"`
  filename="${bni%%.*}"
  inextension="${bni#*.}"

  # If input file found
  if [[ ! -e $input_file ]]; then
      echo "No Nifti files (.nii or .nii.gz) were found within input directory $INPUT_DIR"
      exit 1
  fi

  ## TODO: CHECK IF ALREADY BIDS COMPLIANT
  #bids_re="sub-[0-9a-fA-F]+_[T1w | T2w]"
  #if [[ $filename =~ $re ]]; then echo "BIDS!"; fi

  ## Create a BIDS format directory to be ingested by MRIQC
  # Define participant label, to be used in naming scheme as well as being passed to algorithm as a command line argument
  # Pull out all letters and numbers from input filename to be used as participant label
  PARTICIPANT_LABEL="${filename//[!0-9a-zA-Z]}"
  # Define top level dir
  BIDS_DIR=$WORKING_DIR/sub-$PARTICIPANT_LABEL
  # Define the sub directory (Functional: func) (Structural: anat)
  # Define file description for BIDS format (Functional: task-<task_label>_bold) or (Structural: T1w, T2w)
  # Define the output report filename
  if [[ $intent -eq 'Functional' ]]; then
      subdirname=func
      filedesc=_task-_bold
      outfilename=sub-$PARTICIPANT_LABEL'_bold.html'
  else
      subdirname=anat
      filedesc=_T1w # TODO -- are we assuming this is T1w?
      outfilename=sub-$PARTICIPANT_LABEL'_T1w.html'
  fi
  # Define subdir and bids_file
  BIDS_SUBDIR=$BIDS_DIR/$subdirname
  bids_file=sub-$PARTICIPANT_LABEL$filedesc
  mkdir -p $BIDS_SUBDIR
  # Change filename to be in BIDS format
  cp $input_file $BIDS_SUBDIR/$bids_file.$inextension

  # Call MRIQC software
  source /etc/fsl/fsl.sh
  source /etc/afni/afni.sh
  mriqc $BIDS_DIR $OUTPUT_DIR participant -w $WORKING_DIR --participant_label $PARTICIPANT_LABEL

  # Cleanup outputs
  # Move html report to the output directory and rename to match the original input filename
  cp $OUTPUT_DIR/reports/$outfilename $ROOTOUT_DIR/$filename'_mriqc.qa.html'
  # Remove the working directory
  rm -r $WORKING_DIR
  rm -r $OUTPUT_DIR

  # Get a list of the files in the output directory
  outputs=`find $ROOTOUT_DIR -type f -name "*"`
  # If outputs exist, then go on...
  if [[ -z $outputs ]]
      then
          echo "No results found in output directory... Exiting"
          exit 1
      else
          chmod -R 777 $ROOTOUT_DIR
          echo -e "Wrote: `ls $ROOTOUT_DIR`"
  fi

  exit 0
) 2>&1 | tee $LOG_FILE
