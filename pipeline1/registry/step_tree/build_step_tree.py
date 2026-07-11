
from typing import Any

from pipeline1.registry.step_tree.step_node import StepNode


def build_step_tree(step_registry: list[dict[str, Any]]) -> 'StepNode':
    '''
    Build a tree structure of steps based on their child steps.
    '''

    root_node = StepNode(step_id='root')
    step_nodes: dict[str, StepNode] = {}

    for step in step_registry:
        step_id = step['stepId']
        step_node = StepNode(step_id=step_id)


