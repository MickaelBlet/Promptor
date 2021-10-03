#
# ZSH Prompt
#
# Licensed under the MIT License <http://opensource.org/licenses/MIT>.
# Copyright (c) 2021 BLET Mickaël.
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

# ------------------------------------------------------------------------------
# ALIAS

alias prompt_git_enable='touch "$HOME/.prompt_git"'
alias prompt_git_disable='rm -f "$HOME/.prompt_git"'
alias prompt_font_enable='touch "$HOME/.powerline_font"'
alias prompt_font_disable='rm -f "$HOME/.powerline_font"'

# ------------------------------------------------------------------------------
# HOOK

# pre exec command event
function preexec() {
    # refresh title bar with current command
    printf "\e]0;%s\a" "$1"
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
    if [ -f "$HOME/.powerline_font" ]; then
        characterBranch=$' \ue0a0 '
        characterLock=$' \ue0a2 '
        characterRightFillArrow=$'\ue0b0'
        characterRightArrow=$' \ue0b1 '
        characterLeftFillArrow=$'\ue0b2'
        characterLeftArrow=$' \ue0b3 '
    fi

    local colorReset=$'%{\e[0m%}'
    local colorFG=$'%{\e[38;5;231m%}'
    local colorFGReverse=$'%{\e[38;5;232m%}'
    local colorHostFG=$'%{\e[38;5;25m%}'
    local colorHostBG=$'%{\e[48;5;25m%}'
    local colorDirFG=$'%{\e[38;5;237m%}'
    local colorDirBG=$'%{\e[48;5;237m%}'
    local colorLockFG=$'%{\e[38;5;124m%}'
    local colorLockBG=$'%{\e[48;5;124m%}'
    local colorGitCommitFG=$'%{\e[38;5;226m%}'
    local colorGitCommitBG=$'%{\e[48;5;226m%}'
    local colorGitRemoteFG=$'%{\e[38;5;118m%}'
    local colorGitRemoteBG=$'%{\e[48;5;118m%}'
    local colorGitFG=$'%{\e[38;5;237m%}'
    local colorGitBG=$'%{\e[48;5;237m%}'
    local colorTimeFG=$'%{\e[38;5;237m%}'
    local colorTimeBG=$'%{\e[48;5;237m%}'

    local titlebar=$'%{\e]0;%~\a%}'

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
    if [ -f "$HOME/.prompt_git" ]; then
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
