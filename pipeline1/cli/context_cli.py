import os
from pipeline1.lib.config import config
from pipeline1.lib.logging import log
from pipeline1.lib.context import get_context, set_context


def get_context_cli(args: list[str]) -> None:
    '''
    Adds support for fetching all context values.
    Arranges arguments from command line and then calls get_context.
    '''
    if len(args) < 1:
        # get all dynamic configurations
        context_dir = os.path.join(config['working_dir'], 'context')
        if not os.path.isdir(context_dir):
            log.info("No dynamic configuration set.")
            return
        for scope in os.listdir(context_dir):
            scope_dir = os.path.join(context_dir, scope)
            if not os.path.isdir(scope_dir):
                continue
            for filename in os.listdir(scope_dir):
                if filename.startswith('z') or not filename.endswith('.txt'):
                    continue
                key = filename[:-4]
                value = get_context(key, scope)
                if scope == 'global':
                    log.info(f"{key} is {value}")
                else:
                    log.info(f"[{scope}] {key} is {value}")
        return
    key = args[0]
    scope = args[1] if len(args) > 1 else 'global'
    value = get_context(key, scope)
    if value is not None:
        if scope == 'global':
            log.info(f"{key} is {value}")
        else:
            log.info(f"[{scope}] {key} is {value}")
    else:
        log.info(f"{key} is not set")
    return

def set_context_cli(args: list[str]) -> None:
    # Arranges arguments from command line and then calls get_context.
    key = args[0]
    value = args[1]
    scope = args[2] if len(args) > 2 else 'global'
    set_context(key, value, scope)
    if scope == 'global':
        log.info(f"{key} set to {value}")
    else:
        log.info(f"[{scope}] {key} set to {value}")
    