from pipeline1.cli.dynamic_cli import get_dynamic_cli, set_dynamic_cli
from pipeline1.cli.set_default_step import set_default_step
from pipeline1.registry.get_registries import get_registries
from pipeline1.run_step.run_step import run_step
from pipeline1.registry.update_registries import update_registries
from pipeline1.registry.add_project.add_project import add_project
from pipeline1.cli.list_steps import list_steps
from pipeline1.lib.logging import log

# from icecream import ic

def cli_command(args: list[str]):
    command = args[0].lower()
    command_args = args[1:]

    if command == 'scan':
        project_registry, _ = get_registries()
        update_registries(project_registry)
        return
    
    if command == "list":
        list_steps()
        return 
    
    if command == 'install':
        add_project(command_args)
        return
    
    if command == 'get':
        get_dynamic_cli(command_args)
        return
    
    if command == 'set':
        set_dynamic_cli(command_args)
        return
        
    project_registry, step_registry = get_registries()
    for step in step_registry:
        if step['step_id'] == command:
            set_default_step(project_registry=project_registry, step_registry_entry=step)
            run_step(step_registry_entry=step, step_args=command_args, overrides=[], new_tab_active=False)
            return
    log.info(f"{command} is not a recognized command or step_id. Use 'list' to see available steps.")
    