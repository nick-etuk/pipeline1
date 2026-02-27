import subprocess
from typing import Any
from pipeline1.lib.logging import log


def remove_container(container_name: str) -> None:
    commandline = ['docker', 'container', 'rm', '-f', container_name]
    process = subprocess.run(commandline, capture_output=True, text=True)
    if process.returncode == 0:
        log.info(f"Old docker container '{container_name}' removed successfully.")
    else:
        log.warn(f"Failed to remove old docker container '{container_name}': {process.stderr.strip()}")

def remove_docker_containers(step: dict[str, Any]) -> None:
    commandline = ['docker', 'container', 'ls', '--format', '{{.Names}}']

    if not ('checks' in step and 'dockerContainers' in step['checks']):
        return
    
    containers_to_remove = step['checks']['dockerContainers']
    # Convert container names to lowercase
    containers_to_remove = [str(item).lower() for item in containers_to_remove]
    
    running_containers = []
    process = subprocess.run(commandline, capture_output=True, text=True)
    if process.returncode != 0:
        log.warn("Failed to list Docker containers. Is Docker running?")
        return
    
    running_containers = process.stdout.strip().lower().split('\n')
    for expected in containers_to_remove:
        for actual in running_containers:
            if expected in actual:
                remove_container(actual)
            