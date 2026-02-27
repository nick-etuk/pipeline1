#!/usr/bin/env bash

list_steps() { 
    update_step_registry
    cat "$WORKING_DIR/step_registry.csv"    
}
