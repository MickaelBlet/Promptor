#
# Promptor
#
# Licensed under the MIT License <http://opensource.org/licenses/MIT>.
# Copyright (c) 2022 BLET Mickaël.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

PROMPT_SCRIPT_LIB=$("cd" -P -- "$("dirname" -- "$0")" && printf '%s\n' "$(pwd -P)/$("basename" -- "$0")")

# ------------------------------------------------------------------------------
# ALIAS

alias prompt_font_enable='sed -i "s/\(PROMPT_OPTION_POWERLINE\)=.*/\1=true/" "$PROMPT_SCRIPT_LIB" && source "$PROMPT_SCRIPT_LIB"'
alias prompt_font_disable='sed -i "s/\(PROMPT_OPTION_POWERLINE\)=.*/\1=false/" "$PROMPT_SCRIPT_LIB" && source "$PROMPT_SCRIPT_LIB"'
alias prompt_git_enable='sed -i "s/\(PROMPT_OPTION_GIT\)=.*/\1=true/" "$PROMPT_SCRIPT_LIB" && source "$PROMPT_SCRIPT_LIB"'
alias prompt_git_disable='sed -i "s/\(PROMPT_OPTION_GIT\)=.*/\1=false/" "$PROMPT_SCRIPT_LIB" && source "$PROMPT_SCRIPT_LIB"'

# ------------------------------------------------------------------------------
# OPTIONS

PROMPT_OPTION_POWERLINE=true
PROMPT_OPTION_GIT=true

# ------------------------------------------------------------------------------
# HOOK

# pre exec command event
function preexec() {
    # refresh title bar with current command
    printf "\033]0;%s\007" "$1"
}

# pre command event
function precmd() {
    local characterBranch=" "
    local characterLock=" X "
    local characterRightFillArrow=""
    local characterRightArrow=" | "
    local characterLeftFillArrow=""
    local characterLeftArrow=" | "

    # font character
    if ${PROMPT_OPTION_POWERLINE}; then
        characterBranch=$' \ue0a0 ' &> /dev/null
        characterLock=$' \ue0a2 ' &> /dev/null
        characterRightFillArrow=$'\ue0b0' &> /dev/null
        characterRightArrow=$' \ue0b1 ' &> /dev/null
        characterLeftFillArrow=$'\ue0b2' &> /dev/null
        characterLeftArrow=$' \ue0b3 ' &> /dev/null
    fi

    local colorReset=$'%{\033[0m%}'
    local colorFG=$'%{\033[38;5;231m%}'
    local colorFGReverse=$'%{\033[38;5;232m%}'
    local colorHostFG=$'%{\033[38;5;25m%}'
    local colorHostBG=$'%{\033[48;5;25m%}'
    local colorDirFG=$'%{\033[38;5;237m%}'
    local colorDirBG=$'%{\033[48;5;237m%}'
    local colorLockFG=$'%{\033[38;5;124m%}'
    local colorLockBG=$'%{\033[48;5;124m%}'
    local colorGitCommitFG=$'%{\033[38;5;226m%}'
    local colorGitCommitBG=$'%{\033[48;5;226m%}'
    local colorGitRemoteFG=$'%{\033[38;5;118m%}'
    local colorGitRemoteBG=$'%{\033[48;5;118m%}'
    local colorGitFG=$'%{\033[38;5;237m%}'
    local colorGitBG=$'%{\033[48;5;237m%}'
    local colorTimeFG=$'%{\033[38;5;237m%}'
    local colorTimeBG=$'%{\033[48;5;237m%}'

    local titlebar=$'%{\033]0;%~\007%}'

    # --------------------------------------------------------------------------
    # Title
    PROMPT="${titlebar}"

    # --------------------------------------------------------------------------
    # Left prompt

    # " [...] > X >"
    PROMPT+="${colorReset}${colorDirBG}${colorFG}"
    PROMPT+=" %~ " # current path
    PROMPT+="${colorReset}${colorDirFG}"
    if [ ! -w "$(pwd)" ]; then
        # " ... [> X] >"
        PROMPT+="${colorLockBG}${characterRightFillArrow}${colorFG}"
        PROMPT+="${characterLock}"
        PROMPT+="${colorReset}${colorLockFG}"
    fi
    # " ... > X [>]"
    PROMPT+="${characterRightFillArrow}"
    PROMPT+="${colorReset} "

    # --------------------------------------------------------------------------
    # Right prompt

    RPROMPT="${colorReset}"
    # check git prompt file
    if ${PROMPT_OPTION_GIT}; then
        local branch=""
        if branch=$(git symbolic-ref HEAD) &>/dev/null; then
            branch="${branch##refs/heads/}"
        else
            branch=$(git rev-parse --short HEAD) &>/dev/null
        fi
        if [ ! -z "${branch}" ]; then
            local colorGitFG="${colorGitFG}"
            local colorGitBG="${colorGitBG}"
            local colorGitText="${colorFG}"
            local count=""
            if git ls-files --others --exclude-standard \
                --directory --no-empty-directory \
                --error-unmatch -- ':/*' &>/dev/null ||
                ! git diff --no-ext-diff --quiet ||
                ! git diff --no-ext-diff --cached --quiet
            then
                colorGitFG="${colorGitCommitFG}"
                colorGitBG="${colorGitCommitBG}"
                colorGitText="${colorFGReverse}"
            elif count=$(git rev-list --count HEAD...origin/HEAD) &>/dev/null
            then
                if [ "$count" = "0" ]; then
                    colorGitFG="${colorGitRemoteFG}"
                    colorGitBG="${colorGitRemoteBG}"
                    colorGitText="${colorFGReverse}"
                fi
            elif count=$(git rev-list --count HEAD...origin/$branch) &>/dev/null
            then
                if [ "$count" = "0" ]; then
                    colorGitFG="${colorGitRemoteFG}"
                    colorGitBG="${colorGitRemoteBG}"
                    colorGitText="${colorFGReverse}"
                fi
            fi
            # " [<] ... < ... "
            RPROMPT+="${colorGitFG}${characterLeftFillArrow}"
            # " < [...] < ... "
            RPROMPT+="${colorGitBG}${colorGitText} ${branch}${characterBranch}"
        fi
    fi

    # " [< ...] < ... "
    RPROMPT+="${colorHostFG}${characterLeftFillArrow}"
    RPROMPT+="${colorHostBG}${colorFG}"
    RPROMPT+=" %n@%m " # user@hostname

    # " < ... [<] ... "
    RPROMPT+="${colorTimeFG}${characterLeftFillArrow}"
    # " < ... < [...] "
    RPROMPT+="${colorReset}${colorTimeBG}${colorFG}"
    RPROMPT+=" %D{%H:%M} " # current date
    RPROMPT+="${colorReset}"
}
