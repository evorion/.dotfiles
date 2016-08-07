#!/usr/bin/env bash
tmux display-message -p -F "#{pane_current_path}" -t 1 >> /tmp/last_cwd
