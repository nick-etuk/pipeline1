import json
import os
from pipeline1.registry.remote_projects.remote_projects import REMOTE_PROJECTS
from pipeline1.lib.config import config
from pipeline1.lib.logging import log

def configure_builtin_remotes() -> None:
    for project in REMOTE_PROJECTS:
        config_file = os.path.join(config['remotes_dir'], f"{project['projectId']}.json")
        if not os.path.isfile(config_file):
            log.info(f"Creating config file for remote project {project['title']}")
            json_content = json.dumps(project, indent=4)
            with open(config_file, 'w', encoding='utf-8') as f:
                f.write(json_content)
        