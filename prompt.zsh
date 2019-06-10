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

# export default variable
export PROMPT_FONT="true"
export PROMPT_GIT="true"

# ╔════════════════╗ #
# ║     ALIAS      ║ #
# ╚════════════════╝ #

alias prompt_git_enable='___prompt_git_enable'
alias prompt_git_disable='___prompt_git_disable'
alias prompt_font_enable='___prompt_font_enable'
alias prompt_font_disable='___prompt_font_disable'

# ╔════════════════╗ #
# ║     TOOLS      ║ #
# ╚════════════════╝ #

function ___prompt_git_enable() {
    export PROMPT_GIT="true"
}

function ___prompt_git_disable() {
    export PROMPT_GIT="false"
}

function ___prompt_font_enable() {
    export PROMPT_FONT="true"
}

function ___prompt_font_disable() {
    export PROMPT_FONT="false"
}

# ╔════════════════╗ #
# ║     PROMPT     ║ #
# ╚════════════════╝ #

# pre command event
function precmd() {
    ___prompt
}

function ___prompt() {
    # local variables list
    local characterLeftFillArrow=""
    local characterRightFillArrow=""
    local characterRightArrow=" | "
    local characterBranch=" "
    local characterLock=" X "

    local colorReset=$'%{\e[0m%}'
    local colorFG=$'%{\e[38;5;231m%}'
    local colorBeginDirFG=$'%{\e[38;5;166m%}'
    local colorBeginDirBG=$'%{\e[48;5;166m%}'
    local colorMiddleDirFG=$'%{\e[38;5;237m%}'
    local colorMiddleDirBG=$'%{\e[48;5;237m%}'
    local colorLastDirFG=$'%{\e[38;5;25m%}'
    local colorLastDirBG=$'%{\e[48;5;25m%}'
    local colorLockFG=$'%{\e[38;5;124m%}'
    local colorLockBG=$'%{\e[48;5;124m%}'
    local colorGitCommitFG=$'%{\e[38;5;164m%}'
    local colorGitCommitBG=$'%{\e[48;5;164m%}'
    local colorGitFG=$'%{\e[38;5;240m%}'
    local colorGitBG=$'%{\e[48;5;240m%}'
    local colorTimeFG=$'%{\e[38;5;237m%}'
    local colorTimeBG=$'%{\e[48;5;237m%}'

    local titlebar=$'%{\e]0;%~\a%}'

    # font character
    if [[ $PROMPT_FONT == "true" ]]; then
        characterLeftFillArrow=""
        characterRightFillArrow=""
        characterRightArrow="  "
        characterBranch="  "
        characterLock="  "
    fi

    # set title bar
    PROMPT="${titlebar}"

    local characterHome=""
    local lastDir="$(basename ${PWD})"
    local middleDir=""

    # check if in home
    if [[ $PWD == $HOME* ]]; then
        characterHome="~"
        middleDir=`echo $PWD | sed "s/^${HOME//\//\\/}//" | sed "s/[/]*\(.*\)\?[/]${lastDir}/\1/"`
        if [[ $PWD == $HOME ]]; then
            middleDir=""
            lastDir=""
        fi
    else
        characterHome="@"
        if [[ $PWD == "/" ]]; then
            lastDir=""
        else
            middleDir=`echo $PWD | sed "s/[/]*\(.*\)\?[/]${lastDir}/\1/"`
        fi
    fi
    ___prompt_left "${characterHome}" "${middleDir}" "${lastDir}"
    ___prompt_right
}

# ╔════════════════╗ #
# ║  LEFT  PROMPT  ║ #
# ╚════════════════╝ #

function ___prompt_left() {
    # "[ ~ ]> ... > ... > X >"
    PROMPT+="${colorReset}${colorBeginDirBG}${colorFG} ${characterHome} "

    if [[ -n $middleDir ]]; then
        local middleDirDecorate
        if [ `echo ${middleDir} | wc -c` -gt '24' ]; then
            middleDirDecorate=`echo ".../$(basename ${middleDir})" | sed "s/\//${characterRightArrow}/g"`
        else
            middleDirDecorate=`echo ${middleDir} | sed "s/\//${characterRightArrow}/g"`
        fi
        # " ~ [>] ... > ... > X >"
        PROMPT+="${colorReset}${colorMiddleDirBG}${colorBeginDirFG}${characterRightFillArrow}"
        # " ~ > [...] > ... > X >"
        PROMPT+="${colorReset}${colorMiddleDirBG}${colorFG} ${middleDirDecorate} "
        # " ~ > ... [>] ... > X >"
        PROMPT+="${colorReset}${colorLastDirBG}${colorMiddleDirFG}${characterRightFillArrow}"
        # " ~ > ... > [...] > X >"
        PROMPT+="${colorReset}${colorLastDirBG}${colorFG} ${lastDir} "
        # " ~ > ... > ... [> X >]"
        PROMPT+="${colorReset}${colorLastDirFG}$(___prompt_permition) "
        PROMPT+="${colorReset}"
    else
        if [[ -n $lastDir ]]; then
            # " ~ [>] ... > X >"
            PROMPT+="${colorReset}${colorLastDirBG}${colorBeginDirFG}${characterRightFillArrow}"
            # " ~ > [...] > X >"
            PROMPT+="${colorReset}${colorLastDirBG}${colorFG} ${lastDir} "
            # " ~ > ... [> X >]"
            PROMPT+="${colorReset}${colorLastDirFG}$(___prompt_permition) "
            PROMPT+="${colorReset}"
        else
            # " ~ [> X >]"
            PROMPT+="${colorReset}${colorBeginDirFG}$(___prompt_permition) "
            PROMPT+="${colorReset}"
        fi
    fi
}

function ___prompt_permition() {
    local permition=""
    if [ ! -w $PWD ]; then
        # " ~ > ... > ... [> X] >"
        permition+="${colorLockBG}${characterRightFillArrow}${colorFG}${characterLock}"
        permition+="${colorReset}${colorLockFG}"
    fi
    # " ~ > ... > ... > X [>]"
    permition+="${characterRightFillArrow}"
    echo $permition
}

# ╔════════════════╗ #
# ║  RIGHT PROMPT  ║ #
# ╚════════════════╝ #

function ___prompt_right() {
    RPROMPT="${colorReset}"

    local branch="$(___prompt_git_branch)"

    if [[ -n ${branch} ]]; then
        local colorGitFG="${colorGitFG}"
        local colorGitBG="${colorGitBG}"
        if [[ -n $(___prompt_git_status) ]]; then
            colorGitFG="${colorGitCommitFG}"
            colorGitBG="${colorGitCommitBG}"
        fi
        # " [<] ... < ... "
        RPROMPT+="${colorGitFG}${characterLeftFillArrow}"
        # " < [...] < ... "
        RPROMPT+="${colorGitBG}${colorFG} ${branch}${characterBranch}"
    fi

    # " < ... [<] ... "
    RPROMPT+="${colorTimeFG}${characterLeftFillArrow}"
    # " < ... < [...] "
    RPROMPT+="${colorReset}${colorTimeBG}${colorFG} %D{%H:%M} "
    RPROMPT+="${colorReset}"
}

function ___prompt_git_branch() {
    local gittest
    if [ -n $PROMPT_GIT ]; then
        if [[ $PROMPT_GIT == "true" ]]; then
            if gittest=`git symbolic-ref -q HEAD` &> /dev/null; then
                local branch=`basename $gittest`
                echo "${branch}"
            fi
        fi
    fi
}

function ___prompt_git_status() {
    local gittest
    if [ -n $PROMPT_GIT ]; then
        if [[ $PROMPT_GIT == "true" ]]; then
            if gittest=`git status --ignore-submodules` &> /dev/null; then
                local testgit="nothing to commit"
                if [[ "$gittest" != *$testgit* ]]; then
                    echo "${gittest}"
                fi
            fi
        fi
    fi
}