import sys
from typing import Any

from icecream import ic
from pipeline1.lib.config import config
from pipeline1.lib.constants import Colours, Level, Mode, success_symbol, failure_symbol, success_messages, failure_messages

indentation = config['indentation']

class Logger:
    '''
    Buffered mode saves log messages and prints them at the end of the step.
    This makes it possible to indicate success or failure of the step
    by adding an icon to the first message.
    
    Direct mode prints log messages immediately.
    '''
    def __init__(self, indent: int = 0):
        self.log_fence = int(config['log_fence'])
        self.indent = indent
        self.mode = Mode.DIRECT
        self.buffer: list[dict[str, Any]] = []

    def set_indent(self, indent: int):
        self.indent = indent

    def show(self, msg: dict[str, Any]):
        if msg['level'].value < self.log_fence:
            return
        
        if msg['level'] == Level.DEBUG:
            if config['debug']:
                print(f"{indentation * (msg['indent'])}{Colours.GREY}{msg['message']}{Colours.ENDC}")
            return
        
        for text in success_messages:
            if text in msg['message'].lower():
                return # Do not print success messages. Success symbol is enough to convey meaning.

        if msg['level'] in [Level.HEADER, Level.BOLD]:
            print(f"{indentation * (msg['indent'])}{Colours.BOLD}{msg['message']}{Colours.ENDC}")
            return
        
        if msg['level'] == Level.INFO:
            print(f"{indentation * (msg['indent'])}{Colours.OKGREEN}{msg['message']}{Colours.ENDC}")
            return

        if msg['level'] == Level.ERROR:
            print(f"{indentation * (msg['indent'])}{Colours.FAIL}{msg['message']}{Colours.ENDC}")
            return

        # print(f"indent level: {msg['indent']}")          
        print(f"{indentation * (msg['indent'])}{msg['message']}")

    def begin(self, message: str):
        self.mode = Mode.BUFFERED
        self.buffer.append({'level': Level.INFO, 'message': message, 'indent': self.indent})

    def end(self, message: str):
        msg = {'level': Level.HEADER, 'message': message, 'indent': self.indent}
        self.mode = Mode.DIRECT
        for text in success_messages:
            if text in msg['message'].lower() and len(self.buffer) > 0:
                self.buffer[0]['message'] += f" {success_symbol}"
                break
        for text in failure_messages:
            if text in msg['message'].lower() and len(self.buffer) > 0:
                self.buffer[0]['message'] += f" {failure_symbol}"
                break
        
        for saved_msg in self.buffer:
            self.show(saved_msg)
        self.buffer = []
        self.show(msg)

    def info(self, message: str):
        if not message:
            return
        indent_level = self.indent + 1 if self.mode == Mode.BUFFERED else self.indent
        msg = {'level': Level.INFO, 'message': message, 'indent': indent_level}
        if self.mode == Mode.BUFFERED:
            self.buffer.append(msg)
        else:
            self.show(msg)

    def bold(self, message: str):
        if not message:
            return
        indent_level = self.indent + 1 if self.mode == Mode.BUFFERED else self.indent
        msg = {'level': Level.BOLD, 'message': message, 'indent': indent_level}
        if self.mode == Mode.BUFFERED:
            self.buffer.append(msg)
        else:
            self.show(msg)

    def warn(self, message: str):
        if not message:
            return
        indent_level = self.indent + 1 if self.mode == Mode.BUFFERED else self.indent
        msg = {'level': Level.WARNING, 'message': message, 'indent': indent_level}
        if self.mode == Mode.BUFFERED:
            self.buffer.append(msg)
        else:
            self.show(msg)

    def warning(self, message: str):
        self.warn(message)

    def error(self, message: str):
        if not message:
            sys.exit(1)

        indent_level = self.indent + 1 if self.mode == Mode.BUFFERED else self.indent
        msg = {'level': Level.ERROR, 'message': message, 'indent': indent_level}
        if self.mode == Mode.BUFFERED:
            self.end(message)
        else:
            self.show(msg)
        sys.exit(1)

    def debug(self, message: str):
        if not message:
            return
        
        indent_level = self.indent + 1 if self.mode == Mode.BUFFERED else self.indent
        msg = {'level': Level.DEBUG, 'message': message, 'indent': indent_level}
        if self.mode == Mode.BUFFERED:
            self.buffer.append(msg)
        else:
            self.show(msg)

log = Logger()