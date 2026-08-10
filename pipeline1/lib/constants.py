
FILE_HEADERS = {
    'project': ['projectId', 'title', 'sortOrder', 'sourceCodeRoot', 'p1ProjectPath'],
    'step': ['stepId', 'projectId', 'menu', 'title', 'sortOrder', 'baseFilename', 'path'],
}

LONG_RUNNING_STEP = 5 # Monitor the running time of steps that take longer than this number of seconds