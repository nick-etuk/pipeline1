## Checks

Each step has an expression called a "check". This is used to work out if the step has been done or not.
The checks look like this:

{
  "dependencies": [],
  "checks": {
    "macos": ["command -v keybase | grep -q keybase"],
    "ubuntu": ["true"]
  }
}

The checks can be OS specific - macos, ubuntu, win. Unix means either ubuntu or macos.
