from typing import Any
from time import sleep
from pipeline1.lib.logging import log
from pipeline1.step_done.check_step_done import check_step_done


def wait_for_parallel(step: dict[str, Any], args: list[str]) -> bool:
    log.info(f"Waiting for {step['step_id']}")

    max_wait_time = 600  # seconds. Todo: read from config
    poll_interval = 5    # seconds
    waited_time = 0

    while waited_time < max_wait_time:
        step_done = check_step_done(step, args, calling_function='wait_for_parallel')

        if step_done:
            log.info(f"{step['step_id']} completed in new tab.")
            return True
        
        sleep(poll_interval)
        waited_time += poll_interval
        print('.', end='', flush=True)

    log.warn(f"Timed-out waiting for {step['step_id']}")
    return False
