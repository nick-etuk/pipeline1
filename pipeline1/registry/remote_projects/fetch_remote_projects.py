import json
import os
from pipeline1.registry.remote_projects.configure_builtin_remotes import configure_builtin_remotes
from pipeline1.lib.config import config
from pipeline1.lib.logging import log
from pipeline1.registry.add_project.add_project import add_project_registry_entry
from pipeline1.registry.steps.scan_project_steps import project_sort_order
from pipeline1.run_step.invoke_commands import invoke_commands
from pipeline1.registry.add_project.list_projects import list_projects


def fetch_remote_projects(force: bool = False) -> None:
    """
    Read configs for all remotes, and add to registry if not already there. 
    This allows users to add their own remotes by adding config files to the remotes dir.
    """

    configure_builtin_remotes()
    remotes_dir = config['remotes_dir']
    project_registry = list_projects()

    for config_file in os.listdir(remotes_dir):
        if not config_file.endswith('.json'):
            continue

        config_path = os.path.join(remotes_dir, config_file)
        with open(config_path, 'r', encoding='utf-8') as file:
            project_config = file.read()
        try:
            project = json.loads(project_config)
        except json.JSONDecodeError:
            log.warn(f"Remote project config {config_file} contains invalid JSON. Skipping.")
            continue

        git_url = project['repo']
        project_basename = git_url.rsplit('/', maxsplit=-1)[-1].replace('.git', '')
        project_id = project.get("projectId", project_basename)
        if not project_id:
            log.warn(f"Remote project config {config_file} is missing 'projectId'. Skipping.")
            continue
        project_dir = os.path.join(remotes_dir, project_basename)

        registry_entry = {
            'projectId': project_id,
            'title': project.get('title', project_id),
            'sourceCodeRoot': project.get('sourceCodeRoot', project.get('sourceCodePath', '')),
            'p1ProjectPath': project_dir,
            'sortOrder': project_sort_order(project_id),
        }
        
        if any(x['projectId'] == project_id for x in project_registry):
            continue

        add_project_registry_entry(registry_entry)

        if os.path.exists(project_dir) and not force:
            log.info(f"Project {git_url} already exists at {project_dir}. Skipping download.")
            continue

        log.info(f"Cloning remote project from {git_url}...")
        
        parent_dir = os.path.dirname(project_dir)
        if not os.path.exists(parent_dir):
            os.makedirs(parent_dir, exist_ok=True)

        log.debug(f"git_url: {git_url} project_basename: {project_basename}")
        command = f"git clone {git_url} {project_dir}"
        invoke_commands([command])
        if not os.path.exists(project_dir):
            log.warn(f"Failed to clone {git_url}.")
            continue

        log.info(f"Remote project {git_url} cloned to {project_dir}.")

        # make all script files executable
        for root, _, files in os.walk(project_dir):
            for file in files:
                if file.endswith(('.sh', '.py')):
                    file_path = os.path.join(root, file)
                    os.chmod(file_path, 0o755)



