from pipeline1.lib.config import config
from pipeline1.lib.logging import log


def correct_os(step: dict) -> bool:
    if 'os' not in step:
        return True 
    
    if step['os'] == config['my_os']:
        return True
    
    if step['os'] == 'unix' and config['my_os'] == 'win':
        log.end(f"Step {step['stepId']} not for {config['my_os']}")
        return False
    
    return True