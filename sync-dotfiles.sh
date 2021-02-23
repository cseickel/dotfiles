#!/bin/bash
# add this to crontab with something like:
# crontab -e
# * */1 * * * /home/arch/.dotfiles/sync-dotfiles.sh
cd /home/arch/.dotfiles
npm list --global --parseable --depth=0 | sed '1d' | awk '{gsub(/\/.*\//,"",$1); print}' > installed_npm_packages.txt
git add -A
git commit -m 'auto-commit'
git push
