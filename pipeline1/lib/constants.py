from enum import Enum

FILE_HEADERS = {
    'project': ['projectId', 'title', 'sortOrder', 'sourceCodeRoot', 'p1ProjectPath'],
    'step': ['stepId', 'projectId', 'menu', 'title', 'sortOrder', 'baseFilename', 'path'],
}

LONG_RUNNING_STEP = 5 # Monitor the running time of steps that take longer than this number of seconds


class Level(Enum):
    DEBUG = 0
    INFO = 1
    WARNING = 2
    ERROR = 3
    HEADER = 4
    BOLD = 5

class Mode(Enum):
    DIRECT = 0
    BUFFERED = 1

class Colours:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    GREY = '\033[90m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    ENDC = '\033[0m'


# success_symbol = '✔'
# failure_symbol = '✘'
success_symbol = '\u2714'
failure_symbol = '\u2718'

success_messages = ['step completed', 'already done']
failure_messages = ['step failed', 'not attempted']
