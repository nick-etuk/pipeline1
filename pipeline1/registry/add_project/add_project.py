
import os
import pathlib
from pipeline1.registry.add_project.detect_python import detect_python_project, extract_description_python
from pipeline1.registry.get_registries import get_registries
from pipeline1.registry.write_registry import write_registry
from pipeline1.registry.update_step_registry import update_step_registry
from pipeline1.lib.logging import log

def add_project(args: list[str]) -> None:

    detect_language = {
        'python': detect_python_project,
    }

    extract_description = {
        'python': extract_description_python,
    }

    languages = ['python']  # Extendable for other languages in the future


    current_path = os.getcwd()
    # current_path = str(pathlib.Path().resolve())

    default= {
        'project_id': {'label': 'Id', 'value': pathlib.Path(current_path).name},
        'title': {'label': 'Description', 'value': 'New project'},
        'sourceCodePath': {'label': 'Source code path', 'value': current_path},
        'wsProjectPath': {'label': 'none', 'value': current_path},
    }

    for lang in languages:
        if detect_language[lang](current_path):
            log.info(f"Detected {lang} project at {current_path}")
            description = extract_description[lang](current_path)
            default['title']['value'] = description if description else default['title']['value']
            break

    new_project_entry = {}
    for key, default_item in default.items():
        if default_item['label'] == 'none':
            new_project_entry[key] = default_item['value']
            continue
        input_value = input(f"{default_item['label']} [{default_item['value']}]: ")
        new_project_entry[key] = input_value.strip() if input_value.strip() else default_item['value']


    project_registry, _ = get_registries()
    project_id = new_project_entry['project_id']

    if any(proj['project_id'] == project_id for proj in project_registry):
        log.info(f"Project {project_id} already exists in the registry.")
        return

    project_registry.append(new_project_entry)
    write_registry(project_registry, 'project')
    log.info(f"Added project {new_project_entry['title']} to registry.")

    update_step_registry(project_registry)
    return

