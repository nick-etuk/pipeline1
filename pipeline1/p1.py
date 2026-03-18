import sys

from pipeline1.lib.show_config import show_config
from pipeline1.registry.get_registries import get_registries
from pipeline1.menu.menu_main import show_menu_main
from pipeline1.cli.cli_command import cli_command
from pipeline1.lib.get_new_tab_file import get_new_tab_file
from pipeline1.run_step.run_step import run_step_by_id

# from pipeline1.lib.logging import log

# from icecream import ic
    
def main():
    new_tab_file = get_new_tab_file()
    if not new_tab_file:
        commands = sys.argv[1:]
        if commands and any(c.strip() != '' for c in commands):
            cli_command(args=commands)
            sys.exit(0)


    project_registry, step_registry = get_registries()         

    # This will never be needed. New tab procesing now done in terminal_login.sh
    # if new_tab_file:
    #     log.debug(f"Python processing new tab file: {new_tab_file}")
    #     with open(new_tab_file) as f:
    #         content = f.readlines()
    #     os.remove(new_tab_file)
        
    #     for line in content:
    #         line = line.strip()
    #         log.debug(f"line:>{line}<")
    #         parts = line.split('~')
    #         step_id = parts[0]
    #         args = parts[1:]
    #         # ic(args)

    #         for step in step_registry:
    #             if step['step_id'] == step_id:
    #                 run_step(step_registry_entry=step, step_args=args, overrides=[], new_tab_active=True)
    #                 break
    #     # return
    #     sys.exit(0)
    
    show_config()

    run_step_by_id('setup_terminal', [], step_registry)

    show_menu_main(project_registry=project_registry, step_registry=step_registry)
    sys.exit(0)


if __name__ == "__main__":
    main()