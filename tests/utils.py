import json
from flywheel.rest import ApiException
import datetime


def get_test_inputs_outputs_T1w(fw):
    """Returns a inputs, config, destination and outpus files for a T1w example

    Args:
        fw (flywheel.Client): A flywheel client
    """
    acquisition = fw.lookup('circleci/circle-tests/sub-51187/ses-/T1w')
    inputs = {'nifti': acquisition.get_file('sub-51187_T1w.nii.gz')}
    outputs = ['sub-51187_T1w_mriqc.qa.html']
    return inputs, {}, acquisition, outputs


def add_gear(fw, docker_tag, manifest_path=None):
    """Add gear to Flywheel

    Args:
        fw (flywheel.Client): A flywheel client
        docker_tag (str): Docker image tag on dockerhub
        manifest_path (Path like): Path to manifest

    Returns:
        (flywheel.GearDoc): The newly created gear object
    """
    # Generate GearDoc json
    with open(manifest_path, 'r') as fid:
        manifest = json.load(fid)
    manifest['custom']['flywheel'] = {'suite': 'ci-test'}
    manifest['label'] = f'{manifest["name"]}-{docker_tag}'.replace('/', '-').replace(':', '-')
    manifest['name'] = f'{manifest["name"]}-{docker_tag}'.replace('/', '-').replace(':', '-')
    gear_doc = {
        'category': manifest.get('custom').get('gear-builder').get('category'),
        'gear': manifest,
        'exchange': {'rootfs-url': f'docker://docker.io/{docker_tag}'},
    }
    # Add gear to the flywheel instance
    gear_id = fw.add_gear(manifest['name'], gear_doc)
    return fw.get_gear(gear_id)


def get_jobs_states(fw, job_ids):
    """Return list of job states

    Args:
        fw (flywheel.Client): A flywheel client
        job_ids (list): List of job IDs

    Returns:
        (list): A list of state of jobs
    """
    return [fw.get_job(j).state for j in job_ids]


def is_all_jobs_done(fw, job_ids):
    """Return true if all jobs are finished (i.e. complete, failed or canceled), False otherwise

    Args:
        fw (flywheel.Client): A flywheel client
        job_ids (list): List of job IDs

    Returns:
        (bool): True if all jobs are finished (i.e. complete, failed or canceled), False otherwise
    """
    states = get_jobs_states(fw, job_ids)
    return all([s in ['complete', 'failed', 'cancelled'] for s in states])


def cleanup(fw, job_ids):
    """Cleanup acquisition files or delete analysis container

    Cleanup all traces left by jobs

    Args:
        fw (flywheel.Client): A flywheel client
        job_ids (list): List of job IDs
    """
    for jid in job_ids:
        job = fw.get_job(jid)
        if job.state == 'complete':
            dst_id, dst_type = job['destination']['id'], job['destination']['type']
            if dst_type == 'acquisition':  # remove files
                dst = fw.get(job['destination']['id'])
                for fname in job['saved_files']:
                    dst.delete_file(fname)
        # remove analysis container
        try:
            parent_id = fw.get_analysis(job.destination.id).parent.id
            fw.delete_container_analysis(parent_id, job.destination.id)
        except ApiException:
            pass
