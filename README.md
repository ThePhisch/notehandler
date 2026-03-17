# Anton Notehandler

**Idea**: have a remote notes repository managed using git. Local changes are
recognised and pushed. Regular pulling from remote keeps the local repo up to
date.

## Design Statement and Requirements

- notehandler manages a notes repository consisting of plain-text, UTF-8
  markdown files with globally unique filenames. The files may be structured
  in a folder hierarchy.
- notehandler must run on both MacOS and Linux, using native handlers as far as
  possible.
- notehandler must be configurable in the following parameters:
    - git remote location and authentication
    - pull intervals
    - push intervals/rules regarding bunching of local changes
    - note folder location
- notehandler must be available as a background service that runs at startup

## Implementation details
- linux
    - systemd for running as a service in the background
- macos
    - launchd
- file watcher: entr
- scaffolding for entr: coreutils, sh
- script run by entr on noticing a write/add/delete: git and coreutils, sh
