#
# ZSH Prompt
#
# Licensed under the MIT License <http://opensource.org/licenses/MIT>.
# Copyright (c) 2019 BLET Mickaël.
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

# ╔════════════════╗ #
# ║     ALIAS      ║ #
# ╚════════════════╝ #

alias prompt_git_enable='touch "$HOME/.prompt_git"'
alias prompt_git_disable='rm -f "$HOME/.prompt_git"'
alias prompt_font_enable='touch "$HOME/.powerline_font"'
alias prompt_font_disable='rm -f "$HOME/.powerline_font"'

# ╔════════════════╗ #
# ║     PROMPT     ║ #
# ╚════════════════╝ #

# powerline unicode
___unicode_Branch="$(echo -e "\ue0a0")"
___unicode_Lock="$(echo -e "\ue0a2")"
___unicode_RightFillArrow="$(echo -e "\ue0b0")"
___unicode_RightArrow="$(echo -e "\ue0b1")"
___unicode_LeftFillArrow="$(echo -e "\ue0b2")"
___unicode_LeftArrow="$(echo -e "\ue0b3")"

# pre command event
function preexec() {
    # refresh title bar with current command
    printf "\e]0;%s\a" "$1"
}

function precmd() {
    ___prompt
}

function ___prompt() {
    # local variables list
    local characterBranch=" "
    local characterLock=" X "
    local characterRightFillArrow=""
    local characterRightArrow=" | "
    local characterLeftFillArrow=""
    local characterLeftArrow=" | "

    # font character
    if [ -f $HOME/.powerline_font ]; then
        characterBranch=" $___unicode_Branch "
        characterLock=" $___unicode_Lock "
        characterRightFillArrow="$___unicode_RightFillArrow"
        characterRightArrow=" $___unicode_RightArrow "
        characterLeftFillArrow="$___unicode_LeftFillArrow"
        characterLeftArrow=" $___unicode_LeftArrow "
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

    # set title bar
    PROMPT="${titlebar}"

    ___prompt_left
    ___prompt_right
}

# ╔════════════════╗ #
# ║  LEFT  PROMPT  ║ #
# ╚════════════════╝ #

function ___prompt_left() {
    # " [...] > X >"
    PROMPT+="${colorReset}${colorDirBG}${colorFG} %~ "
    # " ... [> X >]"
    PROMPT+="${colorReset}${colorDirFG}$(___prompt_permission)"
    PROMPT+="${colorReset} "
}

function ___prompt_permission() {
    local permission=""
    if [ ! -w $PWD ]; then
        # " ... [> X] >"
        permission+="${colorLockBG}${characterRightFillArrow}${colorFG}${characterLock}"
        permission+="${colorReset}${colorLockFG}"
    fi
    # " ... > X [>]"
    permission+="${characterRightFillArrow}"
    echo $permission
}

# ╔════════════════╗ #
# ║  RIGHT PROMPT  ║ #
# ╚════════════════╝ #

function ___prompt_right() {
    RPROMPT="${colorReset}"

    if [ -f $HOME/.prompt_git ]; then
        local branch="$(___prompt_git_branch)"

        if [[ -n ${branch} ]]; then
            local gitStatus="$(timeout 5 git status --ignore-submodules)"

            local colorGitFG="${colorGitFG}"
            local colorGitBG="${colorGitBG}"
            local colorGitText="${colorFG}"
            if [[ "$gitStatus" != *"nothing to commit"* ]]; then
                colorGitFG="${colorGitCommitFG}"
                colorGitBG="${colorGitCommitBG}"
                colorGitText="${colorFGReverse}"
            elif [[ "$gitStatus" == *"up to date"* ]]; then
                colorGitFG="${colorGitRemoteFG}"
                colorGitBG="${colorGitRemoteBG}"
                colorGitText="${colorFGReverse}"
            fi
            # " [<] ... < ... "
            RPROMPT+="${colorGitFG}${characterLeftFillArrow}"
            # " < [...] < ... "
            RPROMPT+="${colorGitBG}${colorGitText} ${branch}${characterBranch}"
        fi
    fi

    RPROMPT+="${colorHostFG}${characterLeftFillArrow}"
    RPROMPT+="${colorHostBG}${colorFG} %n@%m "

    # " < ... [<] ... "
    RPROMPT+="${colorTimeFG}${characterLeftFillArrow}"
    # " < ... < [...] "
    RPROMPT+="${colorReset}${colorTimeBG}${colorFG} %D{%H:%M} "
    RPROMPT+="${colorReset}"
}

function ___prompt_git_branch() {
    local gittest
    if gittest=$(timeout 5 git symbolic-ref -q HEAD) &> /dev/null; then
        local branch="$(basename $gittest)"
        echo "${branch}"
    elif gittest=$(timeout 5 git rev-parse --short HEAD) &> /dev/null; then
        echo "${gittest}"
    fi
}
