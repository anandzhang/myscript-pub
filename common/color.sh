#!/bin/bash
# 输出带颜色的提示信息
# 自带高亮 \e[1m
RED='\e[1;31m'
GREEN='\e[1;32m'
BROWN='\e[1;33m'
BLUE='\e[1;34m'
PURPLE='\e[1;35m'
CYAN='\e[1;36m'
NONE='\e[0m'

in_red() { echo -e "${RED}$*${NONE}"; }
in_green() { echo -e "${GREEN}$*${NONE}"; }
in_brown() { echo -e "${BROWN}$*${NONE}"; }
in_blue() { echo -e "${BLUE}$*${NONE}"; }
in_purple() { echo -e "${PURPLE}$*${NONE}"; }
in_cyan() { echo -e "${CYAN}$*${NONE}"; }
