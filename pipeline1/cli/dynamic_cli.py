import os
from pipeline1.lib.config import config
from pipeline1.lib.logging import log
from pipeline1.lib.config_dynamic import get_dynamic, set_dynamic


def get_dynamic_cli(args: list[str]) -> None:
    if len(args) < 1:
        # get all dynamic configurations
        dynamic_dir = os.path.join(config['working_dir'], 'dynamic_config')
        if not os.path.isdir(dynamic_dir):
            log.info("No dynamic configuration set.")
            return
        for group in os.listdir(dynamic_dir):
            group_dir = os.path.join(dynamic_dir, group)
            if not os.path.isdir(group_dir):
                continue
            for filename in os.listdir(group_dir):
                if filename.startswith('z') or not filename.endswith('.txt'):
                    continue
                key = filename[:-4]
                value = get_dynamic(key=key, group=group)
                if group == 'general':
                    log.info(f"{key} is {value}")
                else:
                    log.info(f"[{group}] {key} is {value}")
        return
    key = args[0]
    group = args[1] if len(args) > 1 else 'general'
    value = get_dynamic(key=key, group=group)
    if value is not None:
        if group == 'general':
            log.info(f"{key} is {value}")
        else:
            log.info(f"[{group}] {key} is {value}")
    else:
        log.info(f"{key} is not set")
    return

def set_dynamic_cli(args: list[str]) -> None:
    key = args[0]
    value = args[1]
    group = args[2] if len(args) > 2 else 'general'
    set_dynamic(key=key, value=value, group=group)
    if group == 'general':
        log.info(f"{key} set to {value}")
    else:
        log.info(f"[{group}] {key} set to {value}")
    