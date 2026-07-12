#!/usr/bin/env bash

clone_templates() {
    switch_to "$REPO_DIR"
    git clone https://github.com/nick-etuk/pipeline1-template-web.git
    # set_context status templates_cloned 'done'
    switch_back

}
