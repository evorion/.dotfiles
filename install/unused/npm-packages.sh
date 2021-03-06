#!/usr/bin/env bash
set -e

read -p "Install tldr-pages? "                   -n 1 -r install_tldr
echo
read -p "Install jscs? "                         -n 1 -r   param_jscs
echo
read -p "Install jshint? "                       -n 1 -r   param_jshint
echo
read -p "Install fixmyjs? "                      -n 1 -r   param_fixmyjs
echo
read -p "Install Typescript? "                   -n 1 -r   param_typescript
echo
read -p "Install clausreinke/typescript-tools? " -n 1 -r   param_ts_tools
echo
read -p "Install vvakame/typescript-formatter? " -n 1 -r   param_ts_formatter
echo
echo "..."

case $install_tldr in
  y) npm install -g tldr
esac

case $param_jscs in
    y|Y )
        npm install -g jscs;;
esac

case $param_jshint in
    y|Y )
        npm install -g jshint;;
esac

case $param_fixmyjs in
    y)
        npm install -g fixmyjs;;
esac

case $param_typescript in
    y|Y )
        npm install -g typescript;;
esac

case $param_ts_tools in
    y|Y )
        npm install -g clausreinke/typescript-tools;;
esac

case $param_ts_formatter in
    y|Y )
        npm install -g typescript-formatter;;
esac
