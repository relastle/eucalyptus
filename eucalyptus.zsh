#!/bin/zsh
# File              : mytheme.zsh
# Author            : Hiroki Konishi <relastle@gmail.com>
# Date              : 24.04.2019
# Last Modified Date: 24.04.2019
# Last Modified By  : Hiroki Konishi <relastle@gmail.com>

autoload -Uz vcs_info
setopt prompt_subst

if [[ $TERM = *256color* || $TERM = *rxvt* ]]; then
    __PROMPT_SKWP_COLORS=(
    "%F{81}"  # turquoise
    "%F{166}" # orange
    "%F{135}" # purple
    "%F{161}" # hotpink
    "%F{118}" # limegreen
    )
else
    __PROMPT_SKWP_COLORS=(
    "%F{cyan}"
    "%F{yellow}"
    "%F{magenta}"
    "%F{red}"
    "%F{green}"
    )
fi

POWERLINE_SEPARATOR=''
# POWERLINE_R_SEPARATOR=$'\uE0B2'
NERD_FONT_GIT=''
NERD_FONT_HOME=''
NERD_FONT_DOCKER=''
# NERD_FONT_VIM=$'\uE7C5'
# NERD_FONT_TERMINAL=$'\uf120'
# NERD_FONT_ARROW=$'\ue285'
#

# TEXT_COLOR_WHITE="255"
# TEXT_COLOR_BLACK="16"
# POWERLINE_A_COLOR="19"
# POWERLINE_B_COLOR="36"
# POWERLINE_C_COLOR="31"

TEXT_COLOR_WHITE="white"
TEXT_COLOR_BLACK="black"

POWERLINE_A_COLOR="cyan"
POWERLINE_B_COLOR="green"
POWERLINE_C_COLOR="blue"


local fmt_staged="%F{red} ●%f"
local fmt_unstaged="%F{yellow} ●%f"
local fmt_branch="%F{${TEXT_COLOR_WHITE}}%b%f%u%c%f"
local fmt_action="%F{red}[%a]%f"

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "${fmt_staged}"
zstyle ':vcs_info:git:*' unstagedstr "${fmt_unstaged}"
zstyle ':vcs_info:*' formats "${fmt_branch}"
zstyle ':vcs_info:*' actionformats "${fmt_branch}${fmt_action}"
if [ -z "$DOCKER_CONTAINER" ]
then
    POWERLINE_LEFT_A=""
else
    POWERLINE_LEFT_A="%K{${POWERLINE_A_COLOR}}%F{${TEXT_COLOR_BLACK}} "$NERD_FONT_DOCKER" "$DOCKER_CONTAINER" %k%f%K{${POWERLINE_B_COLOR}}%F{${POWERLINE_A_COLOR}}"$POWERLINE_SEPARATOR
fi

POWERLINE_LEFT_B="%K{${POWERLINE_B_COLOR}}%F{${TEXT_COLOR_BLACK}} "$NERD_FONT_HOME" %c %k%f%K{${POWERLINE_C_COLOR}}%F{${POWERLINE_B_COLOR}}"$POWERLINE_SEPARATOR
POWERLINE_LEFT_C="%k%f%K{${POWERLINE_C_COLOR}}%F{${TEXT_COLOR_WHITE}} "$NERD_FONT_GIT' ${vcs_info_msg_0_}'" %k%f%{${reset_color}%}%F{${POWERLINE_C_COLOR}}"$POWERLINE_SEPARATOR"%{${reset_color}%}"

precmd () { vcs_info }

RPROMPT="%{${fg[green]}%}[%~]%{${reset_color}%}"
PROMPT=${POWERLINE_LEFT_A}${POWERLINE_LEFT_B}${POWERLINE_LEFT_C}" "

