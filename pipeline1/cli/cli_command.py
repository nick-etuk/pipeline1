from pipeline1.registry.remote_projects.fetch_remote_projects import fetch_remote_projects
from pipeline1.cli.context_cli import get_context_cli, set_context_cli
from pipeline1.cli.set_default_step import set_default_step
from pipeline1.registry.get_registries import get_registries
from pipeline1.registry.steps.scan_all_steps import scan_all_steps
from pipeline1.run_step.run_step import run_step
from pipeline1.registry.add_project.add_project import add_project
from pipeline1.cli.list_steps import list_steps
from pipeline1.lib.logging import log
from pipeline1.cli.permissive_match import permissive_match

# from icecream import ic

def cli_command(args: list[str]):
    command = args[0].lower()
    command_args = args[1:]

    if command == 'scan':
        fetch_remote_projects()
        scan_all_steps()
        return
    
    if command == "list":
        list_steps()
        return 
    
    if command == 'install':
        add_project(command_args[0] if command_args else '')
        scan_all_steps()
        return
    
    if command == 'get':
        get_context_cli(command_args)
        return
    
    if command == 'set':
        set_context_cli(command_args)
        return
        
    project_registry, step_registry = get_registries()
    step_ids = [step['stepId'] for step in step_registry]
    matching_step_id = permissive_match(command, step_ids)

    if matching_step_id:
        for step in step_registry:
            if step['stepId'] == matching_step_id:
                set_default_step(project_registry=project_registry, step_registry_entry=step)
                run_step(step_registry_entry=step, step_args=command_args, overrides=[], new_tab_active=False)
                return
    log.info(f"{command} is not a recognized command or step_id. Use 'list' to see available steps.")
    