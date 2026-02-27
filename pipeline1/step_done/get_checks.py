from typing import Any
from pipeline1.lib.config import config
# from icecream import ic

def get_checks(step: dict[str, Any]) -> list[str]:
    if 'checks' not in step:
        return []
    
    checks: list[str] = []

    if config['my_os'] in step['checks']:
        checks += step['checks'][config['my_os']]
    
    if config['my_os'] != 'win' and 'unix' in step['checks']:
        checks += step['checks']['unix']

    return checks
