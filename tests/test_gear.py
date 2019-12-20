import os
import time
import pytest
from pathlib import Path
from .utils import add_gear, cleanup, get_test_inputs_outputs_T1w, get_jobs_states, is_all_jobs_done
import flywheel

MANIFEST_PATH = Path(__file__).parents[1] / 'manifest.json'


def test_gear_run_with_t1w():

    fw = flywheel.Client(os.environ.get('FW_KEY'))
    gear = add_gear(fw, os.environ.get('DOCKERHUB_TAG'), MANIFEST_PATH)
    input, config, destination, files = get_test_inputs_outputs_T1w(fw)

    # Submit job and wait for completion or failure
    job_id = gear.run(config=config, inputs=input, destination=destination, tags=['test'])
    print(f'Time since jobs submission:\n')
    t0 = time.time()
    while not is_all_jobs_done(fw, [job_id]):
        print(f'\t{time.time()-t0:0.0f}s\n')
        time.sleep(10)

    # check job is completed
    assert all([s == 'complete' for s in get_jobs_states(fw, [job_id])])
    # check output files
    out_files = [f.name for f in fw.get(destination.id).files]
    for f in files:
        assert f in out_files

    # cleanup
    fw.delete_gear(gear.id)
    cleanup(fw, [job_id])


