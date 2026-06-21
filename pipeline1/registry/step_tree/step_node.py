class StepNode:
    def __init__(self, step_id, children=None, parent=None):
        # I don't think we need parents.
        self.step_id = step_id
        self.children = children if children is not None else []
        self.parent = parent

    def add_child_step(self, step_id):
        child_node = StepNode(step_id, parent=self)
        self.children.append(child_node)
        return child_node

    def add_child_node(self, child_node):
        child_node.parent = self
        self.children.append(child_node)

    def remove_child_node(self, child_node):
        if child_node in self.children:
            self.children.remove(child_node)
            child_node.parent = None

    def get_parent(self):
        return self.parent

    def get_children(self):
        return self.children

    def __repr__(self):
        return f"StepNode({self.step_id})"
    
    def is_root(self):
        return self.parent is None