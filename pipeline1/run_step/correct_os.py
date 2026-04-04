from pipeline1.lib.config import config
from pipeline1.lib.logging import log


def correct_os(step: dict) -> bool:
    if 'os' not in step:
        return True 
    
    os_array = step['os']
    if isinstance(os_array, str):
        os_array = [step['os']]

    os_array = [os_name.strip().lower() for os_name in os_array]
    
    if config['my_os'] in os_array:
        return True
    
    if 'unix' in os_array and config['my_os'] == 'win':
        log.end(f"Step {step['stepId']} not for {config['my_os']}")
        return False
    
    if 'win' in os_array and config['my_os'] != 'win':
        log.end(f"Step {step['stepId']} not for {config['my_os']}")
        return False
    
    return True