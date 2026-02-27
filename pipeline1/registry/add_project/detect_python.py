def detect_python_project(path: str) -> bool:
    """Detect if the given path is a Python project by checking for common files."""
    import os

    python_indicators = ['setup.py', 'requirements.txt', 'Pipfile', 'pyproject.toml']

    for indicator in python_indicators:
        if os.path.isfile(os.path.join(path, indicator)):
            return True

    return False


def extract_description_python(path: str) -> str:
    """Extract project description from setup.py or pyproject.toml if available."""
    import os
    import re

    setup_path = os.path.join(path, 'setup.py')
    pyproject_path = os.path.join(path, 'pyproject.toml')

    description = ""

    if os.path.isfile(setup_path):
        with open(setup_path, 'r') as f:
            content = f.read()
            match = re.search(r'description\s*=\s*[\'"]([^\'"]+)[\'"]', content)
            if match:
                description = match.group(1)

    elif os.path.isfile(pyproject_path):
        with open(pyproject_path, 'r') as f:
            content = f.read()
            match = re.search(r'description\s*=\s*[\'"]([^\'"]+)[\'"]', content)
            if match:
                description = match.group(1)

    return description
