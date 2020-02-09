#!/bin/zsh
# File              : prompt_eucalyptus_setup
# Author            : Hiroki Konishi <relastle@gmail.com>
# Date              : 11.06.2019
# Last Modified Date: 11.06.2019
# Last Modified By  : Hiroki Konishi <relastle@gmail.com>
# prompt_eucalyptus_setup
# Copyright (c) 2019 Hiroki Konishi <relastle@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

POWERLINE_SEPARATOR=''
NERD_FONT_GIT=' '
NERD_FONT_HOME=''
NERD_FONT_DOCKER=''

TEXT_COLOR_WHITE="white"
TEXT_COLOR_BLACK="black"

BRANCH_COLOR_MASTER="yello"
BRANCH_COLOR_NON_MASTER="white"

POWERLINE_SUCCESS_COLOR="2" # normal green
POWERLINE_FAILURE_COLOR="9" # bright red

status_color=${POWERLINE_SUCCESS_COLOR}
last_exit_code=''

POWERLINE_B_COLOR_SAFE='12'
POWERLINE_B_COLOR_DANGER='9'

POWERLINE_A_COLOR="6" # normal cyan
POWERLINE_B_COLOR='12' # bright blue
POWERLINE_C_COLOR="4" # normal blue


vi_status='INSERT'
VI_INSERT_COLOR='yello'
VI_NORMAL_COLOR='cyan'
vi_status_color="${VI_INSERT_COLOR}"

chpwd_flag=false

# set STATUS_COLOR: cyan for "insert", green for "normal" mode.
prompt_eucalyptus_vim_mode() {
	vi_status="${${KEYMAP/vicmd/NORMAL}/(main|viins)/INSERT}"
	vi_status_color="${${KEYMAP/vicmd/${VI_NORMAL_COLOR}}/(main|viins)/${VI_INSERT_COLOR}}"
    zle reset-prompt
}

# Set branch color dependent on branch name.
# if `master`, then color will be yellow
prompt_eucalyptus_branch_color() {
    current_branch=$(git branch 2>/dev/null | grep \* | cut -d ' ' -f2)
    if [[ ${current_branch} = 'master' ]] ; then
        fmt_branch="%F{${BRANCH_COLOR_MASTER}}%b%f%u%c%f"
    else
        fmt_branch="%F{${BRANCH_COLOR_NON_MASTER}}%b%f%u%c%f"
    fi
    zstyle ':vcs_info:*' formats "${fmt_branch}"
}

prompt_eucalyptus_precmd () {
    # change color for status color according to previous cmd exit status
    local LAST_EXIT_CODE=$?
    if [[ $LAST_EXIT_CODE -ne 0 ]]; then
        # last_exit_code=${LAST_EXIT_CODE}
        last_exit_code=''
        status_color=${POWERLINE_FAILURE_COLOR}
    else;
        last_exit_code=''
        status_color=${POWERLINE_SUCCESS_COLOR}
    fi

    # echo "chpwd_flag = ${chpwd_flag} @ precmd"
    if [[ $chpwd_flag != true ]] then
        prompt_eucalyptus_branch_color
        vcs_info #&& echo "get VCS_INFO precmd"
    fi
    chpwd_flag=false
}

prompt_eucalyptus_preexec () {
    chpwd_flag=false
}

prompt_eucalyptus_chpwd () {
    prompt_eucalyptus_branch_color
    vcs_info #&& echo "get VCS_INFO chpwd"
    chpwd_flag=true
}

prompt_eucalyptus_render() {

    if [ -z "$DOCKER_CONTAINER" ]
    then
        POWERLINE_LEFT_A=""
    else
        POWERLINE_LEFT_A="%K{${POWERLINE_A_COLOR}}%F{${TEXT_COLOR_BLACK}} "$NERD_FONT_DOCKER" "$DOCKER_CONTAINER" %k%f%K{${POWERLINE_B_COLOR}}%F{${POWERLINE_A_COLOR}}"$POWERLINE_SEPARATOR
    fi

    if [[ $(hostname) != ${EUCALYPTUS_WHITE_HOST_NAME} ]] then
        display_host_name=" $(hostname):"
    else
        display_host_name=""
    fi

    if [[ ${EUCALYPTUS_HOST_NAME_DANGER} != "" && $(hostname) =~ "${EUCALYPTUS_HOST_NAME_DANGER}" ]] then
        POWERLINE_B_COLOR=${POWERLINE_B_COLOR_DANGER}
    else
        POWERLINE_B_COLOR=${POWERLINE_B_COLOR_SAFE}
    fi

    # for current directory name (and host name if sshed)
    POWERLINE_LEFT_B="%K{${POWERLINE_B_COLOR}}%F{${TEXT_COLOR_BLACK}} "$NERD_FONT_HOME""${display_host_name}" %c %k%f%K{${POWERLINE_C_COLOR}}%F{${POWERLINE_B_COLOR}}"$POWERLINE_SEPARATOR

    # for git branch and status
    POWERLINE_LEFT_C="%k%f%K{${POWERLINE_C_COLOR}}%F{${TEXT_COLOR_WHITE}} $NERD_FONT_GIT "'${vcs_info_msg_0_}'" %k%f%K{"'${status_color}'"%}%F{${POWERLINE_C_COLOR}}"$POWERLINE_SEPARATOR

    POWERLINE_LEFT_D="%F{${TEXT_COLOR_BLACK}}"'${last_exit_code}'"%k%f%{${reset_color}%}%F{"'${status_color}'"}""${POWERLINE_SEPARATOR}%{${reset_color}%}"

    RPROMPT="%F{"'${vi_status_color}'"}[--"'${vi_status}'"--] %F{green}%~%f"
    PROMPT="${POWERLINE_LEFT_TMP}${POWERLINE_LEFT_A}${POWERLINE_LEFT_B}${POWERLINE_LEFT_C}${POWERLINE_LEFT_D} %f%k"
}

prompt_eucalyptus_setup() {
    export KEYTIMEOUT=20

    fmt_staged="%F{red} %f"
    fmt_unstaged="%F{yellow} %f"
    fmt_branch="%F{${TEXT_COLOR_WHITE}}%b%f%u%c%f"
    fmt_action="%F{red}[%a]%f"

	add-zsh-hook precmd prompt_eucalyptus_precmd
	add-zsh-hook preexec prompt_eucalyptus_preexec
	add-zsh-hook chpwd prompt_eucalyptus_chpwd

	zle -N zle-line-init prompt_eucalyptus_vim_mode
	zle -N zle-keymap-select prompt_eucalyptus_vim_mode

    autoload -Uz vcs_info
    zstyle ":vcs_info:*" enable git
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:git:*' stagedstr "${fmt_staged}"
    zstyle ':vcs_info:git:*' unstagedstr "${fmt_unstaged}"
    zstyle ':vcs_info:*' formats "${fmt_branch}"
    zstyle ':vcs_info:*' actionformats "${fmt_branch}${fmt_action}"

    prompt_eucalyptus_render
}

prompt_eucalyptus_setup
