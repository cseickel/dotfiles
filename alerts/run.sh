#!/bin/bash
set -e
cd ~/.local/alerts
. ./env
python3 ./alert-monitor.py
