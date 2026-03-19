from pipeline1.lib.logging import log
from pipeline1.registry.get_registries import get_registries


def list_steps() -> None:
    project_registry, step_registry = get_registries()

    log.info("built_in:")
    built_in_steps = [step for step in step_registry if step['projectId'] == 'core']
    built_in_steps = sorted(built_in_steps, key=lambda x: x['stepId'])
    for step in built_in_steps:
        log.info(f"\t {step['stepId']}")
    for project in project_registry:
        log.info(f"{project['title']}")
        project_steps = [step for step in step_registry if step['projectId'] == project['projectId']]
        project_steps = sorted(project_steps, key=lambda x: x['stepId'])
        for step in project_steps:
            log.info(f"\t {step['stepId']}")
 