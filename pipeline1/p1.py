import sys
from pipeline1.lib.show_config import show_config
from pipeline1.registry.get_registries import get_registries
from pipeline1.menu.menu_main import show_menu_main
from pipeline1.cli.cli_command import cli_command
from pipeline1.registry.steps.detect_step_changes import detect_step_changes
from pipeline1.run_step.run_step import run_step_by_id

def main():
    detect_step_changes()

    # new_tab_file = get_new_tab_file()
    # if not new_tab_file:
    commands = sys.argv[1:]
    if commands and any(c.strip() != '' for c in commands):
        cli_command(args=commands)
        sys.exit(0)

    project_registry, step_registry = get_registries()         

    show_config()

    run_step_by_id('setup_terminal', [], step_registry)

    show_menu_main(project_registry=project_registry, step_registry=step_registry)


if __name__ == "__main__":
    main()