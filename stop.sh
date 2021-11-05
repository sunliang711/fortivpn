#!/bin/bash

sessionName=fortiClient

tmux kill-session -t ${sessionName}
pkill openfortivpn
