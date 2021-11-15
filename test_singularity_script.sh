#!/bin/sh
new_fw_dir=`python -c "import singularity; singularity.check_for_singularity()"`
if [[ "$new_fw_dir" == "None" ]]; then
  FLYWHEEL_BASE=/flywheel/v0
  echo "Running on docker with directory: $FLYWHEEL_BASE"
else
  FLYWHEEL_BASE=$new_fw_dir
  echo "Running on singularity with new temp directory: $FLYWHEEL_BASE"
fi
