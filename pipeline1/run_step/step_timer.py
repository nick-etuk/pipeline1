import os
from datetime import datetime

from pipeline1.lib.config import config
from pipeline1.lib.constants import LONG_RUNNING_STEP
from pipeline1.lib.context import set_context

def start_timer(step_key: str) -> datetime:
    set_context('current_step', step_key)
    timings_directory = os.path.join(config['working_dir'], 'monitor', 'step_timings')
    if not os.path.exists(timings_directory):
        os.makedirs(timings_directory, exist_ok=True)
        
    timings_file = os.path.join(timings_directory, f"{step_key}.csv")
    max_duration_file = os.path.join(timings_directory, f"{step_key}_max_duration.txt")

    start_time = datetime.now()
    if not os.path.exists(timings_file):
        with open(timings_file, 'w') as f:
            f.write("step_key,event,value\n")
            f.write(f"{step_key},start,{start_time}\n")
    else:
        with open(timings_file, 'a') as f:
            f.write(f"{step_key},start,{start_time}\n")

    return start_time


def stop_timer(step_key: str, start_time: datetime):
    end_time = datetime.now()
    # set_context('current_step', '')

    duration = (end_time - start_time).total_seconds()
    if duration < LONG_RUNNING_STEP:
        return

    timings_directory = os.path.join(config['working_dir'], 'monitor', 'step_timings')
    timings_file = os.path.join(timings_directory, f"{step_key}.csv")

    with open(timings_file, 'a') as f:
        f.write(f"{step_key},stop,{end_time}\n")
        f.write(f"{step_key},duration,{duration}\n")

    max_duration_file = os.path.join(timings_directory, f"{step_key}_max_duration.txt")
    if not os.path.exists(max_duration_file):
        with open(max_duration_file, 'w') as f:
            f.write(f"{duration}\n")
        return
    
    max_duration_str = ''
    with open(max_duration_file, 'r') as f:
        max_duration_str = f.read().strip()

    # If the file is empty or contains invalid data, return.
    if not max_duration_str or not max_duration_str.replace('.', '', 1).isdigit():
        return
    
    max_duration = float(max_duration_str)

    if duration > max_duration:
        with open(max_duration_file, 'w') as f:
            f.write(f"{duration}\n")