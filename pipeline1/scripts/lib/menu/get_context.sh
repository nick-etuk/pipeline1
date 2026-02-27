#!/usr/bin/env bash

get_context() {
    DEFAULT_STEP_ID=$(get_config 'default_step_id')
    DEFAULT_STEP_PATH=$(get_config 'default_step_path')
}