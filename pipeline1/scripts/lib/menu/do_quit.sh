#!/usr/bin/env bash

do_quit() {
    printf "To show this menu again, enter the command \'p1\'\n"
    echo 'The script p1.py is located at:'
    startup_script=$(find "$P1_ROOT_UNIX" -name "p1.py" -type f -not -path ".venv_p1/*")
    dirname "$startup_script"
}
