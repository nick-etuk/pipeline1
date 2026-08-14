
import os
import pathlib
import json
from pipeline1.registry.add_project.detect_python import detect_python_project, extract_description_python
from pipeline1.registry.add_project.list_projects import list_projects
from pipeline1.registry.steps.scan_project_steps import project_sort_order
from pipeline1.registry.write_registry import write_registry
from pipeline1.lib.logging import log
from pipeline1.lib.context import get_context
from pipeline1.lib.variables_in_path_names import encode_variables_in_path


def add_project_registry_entry(new_project_entry: dict[str, str], interactive: bool = False) -> None:
    new_project_entry['sourceCodeRoot'] = encode_variables_in_path(new_project_entry['sourceCodeRoot'])
    new_project_entry['p1ProjectPath'] = encode_variables_in_path(new_project_entry['p1ProjectPath'])

    if interactive:
        log.info('Adding new P1 project:')
        for key, value in new_project_entry.items():
            log.info(f"  {key}: {value}")

        confirmation = input('Continue? [y/N]: ').strip().lower()
        # if confirmation not in ('y', 'yes'):
        if confirmation in ('n', 'no'):
            log.info('Project add cancelled by user.')
            return

    project_registry = list_projects()
    if any(x['projectId'] == new_project_entry['projectId'] for x in project_registry):
        log.debug(f"Project {new_project_entry['projectId']} already exists in the registry.")
        return

    project_registry.append(new_project_entry)
    project_registry = sorted(project_registry, key=lambda x: float(x['sortOrder']))
    write_registry(project_registry, 'project')
    log.info(f"Added project {new_project_entry['title']} to registry.")


def add_project(path_param: str) -> None:
    log.info('Adding new P1 project')
    detect_language = {
        'python': detect_python_project,
    }

    extract_description = {
        'python': extract_description_python,
    }

    languages = ['python']  # Extend to other languages in the future

    cwd = get_context('p1_invoke_dir') or os.getcwd()
    current_path = path_param if path_param else cwd
    proposed_p1_path = current_path
    proposed_parts = [part.lower() for part in pathlib.Path(proposed_p1_path).parts]
    if 'p1' not in proposed_parts:
        proposed_p1_path = os.path.join(proposed_p1_path, 'p1')

    project_json_path = pathlib.Path(proposed_p1_path) / 'project.json'
    if project_json_path.exists():
        log.debug(f"Found project.json at {project_json_path}, using it to prefill project details.")
        with open(project_json_path, 'r', encoding='utf-8') as file:
            content = file.read()
        try:
            project_config = json.loads(content)
            project_id = project_config.get('projectId', pathlib.Path(proposed_p1_path).name)
            new_project_entry = {
                'projectId': project_id,
                'title': project_config.get('title', 'New project'),
                'sortOrder': project_sort_order(project_id),
                'sourceCodeRoot': project_config.get('sourceCodeRoot', current_path),
                'p1ProjectPath': project_config.get('p1ProjectPath', proposed_p1_path),
            }
            add_project_registry_entry(new_project_entry, interactive=True)
            return
        except json.JSONDecodeError:
            log.warn(f"Warning: Could not parse JSON in {project_json_path}")

    prompts= {
        'projectId': {'prompt': 'Nickname', 'value': pathlib.Path(current_path).name},
        'title': {'prompt': 'Title', 'value': 'New project'},
        'sourceCodeRoot': {'prompt': 'Source code root', 'value': current_path},
    }

    for lang in languages:
        if detect_language[lang](current_path):
            log.info(f"Detected {lang} project at {current_path}")
            description = extract_description[lang](current_path)
            prompts['title']['value'] = description if description else prompts['title']['value']
            break

    # Prompt for project details. Skip prompts where the 'prompt' is 'none'. 
    # Use the default value if the user just presses enter.
    new_project_entry = {}
    for key, default_item in prompts.items():
        if default_item['prompt'] == 'none':
            new_project_entry[key] = default_item['value']
            continue
        input_value = input(f"{default_item['prompt']} [{default_item['value']}]: ")
        new_project_entry[key] = input_value.strip() if input_value.strip() else default_item['value']

    new_project_entry['p1ProjectPath'] = proposed_p1_path

    if not os.path.exists(new_project_entry['p1ProjectPath']):
        os.makedirs(new_project_entry['p1ProjectPath'], exist_ok=True)
        log.info(f"Created p1 directory at {new_project_entry['p1ProjectPath']}")

    # If project.json does not exist, write config to project.json in the p1 directory
    # This will save us having to ask for the same information again 
    # when we add the project to the registry in the future or on another machine.
    project_json_path = pathlib.Path(new_project_entry['p1ProjectPath']) / 'project.json'
    if not project_json_path.exists():
        with open(project_json_path, 'w', encoding='utf-8') as file:
            json.dump(new_project_entry, file, indent=4)
    
    new_project_entry['sortOrder'] = project_sort_order(new_project_entry['projectId'])

    add_project_registry_entry(new_project_entry, interactive=True)
