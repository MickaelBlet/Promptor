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
builtin autoload -Uz add-zsh-hook

__PROMPTOR_CONFIGFILE="$HOME/.config/promptor/config.zsh"

__promptor_create_config() {
    builtin local default_config
    default_config=(
        # options
        options.powerline=true
        options.git=true
        options.hour=true
        options.title="%~"
        options.prompt=" %~ "
        options.rprompt=" %n@%m "
        # colors
        colors.prompt.fg="231"
        colors.prompt.bg="237"
        colors.lock.fg="231"
        colors.lock.bg="124"
        colors.rprompt.fg="231"
        colors.rprompt.bg="25"
        colors.git.fg="231"
        colors.git.bg="237"
        colors.git.commit.fg="232"
        colors.git.commit.bg="226"
        colors.git.remote.fg="232"
        colors.git.remote.bg="118"
        colors.hour.fg="231"
        colors.hour.bg="237"
    )

    "mkdir" -p "$("dirname" -- "$__PROMPTOR_CONFIGFILE")"
    builtin echo "# PROMPTOR CONFIGURATION" > "$__PROMPTOR_CONFIGFILE"
    builtin echo >> "$__PROMPTOR_CONFIGFILE"
    builtin echo "declare -A __default_promptor" >> "$__PROMPTOR_CONFIGFILE"
    builtin echo "declare -A __promptor" >> "$__PROMPTOR_CONFIGFILE"
    builtin echo >> "$__PROMPTOR_CONFIGFILE"
    builtin echo "__promptor=(" >> "$__PROMPTOR_CONFIGFILE"
    builtin echo >> "$__PROMPTOR_CONFIGFILE"

    # transform array to map
    builtin local value
    for value in ${default_config[@]}; do
        builtin local valueLeft=${value%%=*}
        builtin local valueRight=${value/${valueLeft}=/}
        builtin echo "defaults.${valueLeft}" "\"${valueRight}\"" >> "$__PROMPTOR_CONFIGFILE"
    done

    builtin echo >> "$__PROMPTOR_CONFIGFILE"

    # transform array to map
    for value in ${default_config[@]}; do
        builtin local valueLeft=${value%%=*}
        builtin local valueRight=${value/${valueLeft}=/}
        builtin echo "${valueLeft}" "\"${valueRight}\"" >> "$__PROMPTOR_CONFIGFILE"
    done

    builtin echo >> "$__PROMPTOR_CONFIGFILE"
    builtin echo ")" >> "$__PROMPTOR_CONFIGFILE"
}

if [ ! -f "$__PROMPTOR_CONFIGFILE" ]; then
    __promptor_create_config
fi
# source config file
. "$__PROMPTOR_CONFIGFILE"

# ------------------------------------------------------------------------------
# FUNCTION

__promptor_update_configuration() {
    builtin local promptor_option=$1
    builtin local promptor_value=$2

    sed -i "s/^\s*\($promptor_option\)\s\+.*/\1 \"$promptor_value\"/" "$__PROMPTOR_CONFIGFILE" && \
    __promptor[$promptor_option]="$promptor_value"
}

__promptor_update_bool_option() {
    builtin local promptor_option=$1
    builtin local promptor_value=$2
    if [ -z "$promptor_value" ] || [[ "$promptor_value" == "false" ]] || [[ "$promptor_value" == "0" ]]; then
        promptor_value=false
    else
        promptor_value=true
    fi
    __promptor_update_configuration "$promptor_option" "$promptor_value"
}

__promptor_update_option() {
    builtin local promptor_option=$1
    builtin local promptor_value=$2
    if [ -z "$promptor_value" ]; then
        promptor_value=$3
    fi
    __promptor_update_configuration "$promptor_option" "$promptor_value"
}

# ------------------------------------------------------------------------------

promptor_title() { __promptor_update_option options.title "$1" "${__promptor[defaults.options.title]}"; }

promptor_font() { __promptor_update_bool_option options.powerline "$1"; }
promptor_git() { __promptor_update_bool_option options.git "$1"; }
promptor_hour() { __promptor_update_bool_option options.hour "$1"; }

promptor_prompt() { __promptor_update_option options.prompt "$1" "${__promptor[defaults.options.prompt]}"; }
promptor_rprompt() { __promptor_update_option options.rprompt "$1" "${__promptor[defaults.options.rprompt]}"; }

# ------------------------------------------------------------------------------

# Prompt
promptor_colors_prompt_fg() { __promptor_update_option colors.prompt.fg "$1" "${__promptor[defaults.colors.prompt.fg]}"; }
promptor_colors_prompt_bg() { __promptor_update_option colors.prompt.bg "$1" "${__promptor[defaults.colors.prompt.bg]}"; }
# Lock
promptor_colors_lock_fg() { __promptor_update_option colors.lock.fg "$1" "${__promptor[defaults.colors.lock.fg]}"; }
promptor_colors_lock_bg() { __promptor_update_option colors.lock.bg "$1" "${__promptor[defaults.colors.lock.bg]}"; }

# RPrompt
promptor_colors_rprompt_fg() { __promptor_update_option colors.rprompt.fg "$1" "${__promptor[defaults.colors.rprompt.fg]}"; }
promptor_colors_rprompt_bg() { __promptor_update_option colors.rprompt.bg "$1" "${__promptor[defaults.colors.rprompt.bg]}"; }

# Git
promptor_colors_git_fg() { __promptor_update_option colors.git.fg "$1" "${__promptor[defaults.colors.git.fg]}"; }
promptor_colors_git_bg() { __promptor_update_option colors.git.bg "$1" "${__promptor[defaults.colors.git.bg]}"; }
promptor_colors_git_commit_fg() { __promptor_update_option colors.git.commit.fg "$1" "${__promptor[defaults.colors.git.commit.fg]}"; }
promptor_colors_git_commit_bg() { __promptor_update_option colors.git.commit.bg "$1" "${__promptor[defaults.colors.git.commit.bg]}"; }
promptor_colors_git_remote_fg() { __promptor_update_option colors.git.remote.fg "$1" "${__promptor[defaults.colors.git.remote.fg]}"; }
promptor_colors_git_remote_bg() { __promptor_update_option colors.git.remote.bg "$1" "${__promptor[defaults.colors.git.remote.bg]}"; }

# Hour
promptor_colors_hour_fg() { __promptor_update_option colors.hour.fg "$1" "${__promptor[defaults.colors.hour.fg]}"; }
promptor_colors_hour_bg() { __promptor_update_option colors.hour.bg "$1" "${__promptor[defaults.colors.hour.bg]}"; }

# ------------------------------------------------------------------------------
# HOOK

# pre exec command event
__promptor_preexec() {
    # refresh title bar with current command
    builtin printf "\033]0;%s\007" "$1"
}

# pre command event
__promptor_precmd() {
    builtin local promptor
    builtin local rpromptor

    builtin local characterBranch=" "
    builtin local characterLock=" X "
    builtin local characterRightFillArrow=""
    builtin local characterRightArrow=" | "
    builtin local characterLeftFillArrow=""
    builtin local characterLeftArrow=" | "

    # font character
    if ${__promptor[options.powerline]}; then
        characterBranch=$' \ue0a0 ' &> /dev/null
        characterLock=$' \ue0a2 ' &> /dev/null
        characterRightFillArrow=$'\ue0b0' &> /dev/null
        characterRightArrow=$' \ue0b1 ' &> /dev/null
        characterLeftFillArrow=$'\ue0b2' &> /dev/null
        characterLeftArrow=$' \ue0b3 ' &> /dev/null
    fi

    # --------------------------------------------------------------------------
    # Color

    builtin local colorReset=$'%{\033[0m%}'
    # Prompt
    builtin local colorPromptFG=$'%{\033[38;5;'${__promptor[colors.prompt.fg]}$'m%}'
    builtin local colorPromptBG=$'%{\033[48;5;'${__promptor[colors.prompt.bg]}$'m%}'
    builtin local colorPromptChar=$'%{\033[38;5;'${__promptor[colors.prompt.bg]}$'m%}'
    # Lock
    builtin local colorLockFG=$'%{\033[38;5;'${__promptor[colors.lock.fg]}$'m%}'
    builtin local colorLockBG=$'%{\033[48;5;'${__promptor[colors.lock.bg]}$'m%}'
    builtin local colorLockChar=$'%{\033[38;5;'${__promptor[colors.lock.bg]}$'m%}'

    # RPrompt
    builtin local colorRPromptFG=$'%{\033[38;5;'${__promptor[colors.rprompt.fg]}$'m%}'
    builtin local colorRPromptBG=$'%{\033[48;5;'${__promptor[colors.rprompt.bg]}$'m%}'
    builtin local colorRPromptChar=$'%{\033[38;5;'${__promptor[colors.rprompt.bg]}$'m%}'

    # Git
    builtin local colorGitFG=$'%{\033[38;5;'${__promptor[colors.git.fg]}$'m%}'
    builtin local colorGitBG=$'%{\033[48;5;'${__promptor[colors.git.bg]}$'m%}'
    builtin local colorGitChar=$'%{\033[38;5;'${__promptor[colors.git.bg]}$'m%}'
    builtin local colorGitCommitFG=$'%{\033[38;5;'${__promptor[colors.git.commit.fg]}$'m%}'
    builtin local colorGitCommitBG=$'%{\033[48;5;'${__promptor[colors.git.commit.bg]}$'m%}'
    builtin local colorGitCommitChar=$'%{\033[38;5;'${__promptor[colors.git.commit.bg]}$'m%}'
    builtin local colorGitRemoteFG=$'%{\033[38;5;'${__promptor[colors.git.remote.fg]}$'m%}'
    builtin local colorGitRemoteBG=$'%{\033[48;5;'${__promptor[colors.git.remote.bg]}$'m%}'
    builtin local colorGitRemoteChar=$'%{\033[38;5;'${__promptor[colors.git.remote.bg]}$'m%}'

    # Hour
    builtin local colorHourFG=$'%{\033[38;5;'${__promptor[colors.hour.fg]}$'m%}'
    builtin local colorHourBG=$'%{\033[48;5;'${__promptor[colors.hour.bg]}$'m%}'
    builtin local colorHourChar=$'%{\033[38;5;'${__promptor[colors.hour.bg]}$'m%}'

    # --------------------------------------------------------------------------
    # Title
    builtin local titleBar=$'%{\033]0;'${__promptor[options.title]}$'\007%}'
    promptor="${titleBar}"

    # --------------------------------------------------------------------------
    # Left prompt

    # " [...] > X >"
    promptor+="${colorReset}${colorPromptBG}${colorPromptFG}"
    promptor+="${__promptor[options.prompt]}"
    promptor+="${colorReset}${colorPromptChar}"
    if [ ! -w "$(pwd)" ]; then
        # " ... [> X] >"
        promptor+="${colorLockBG}${characterRightFillArrow}${colorLockFG}"
        promptor+="${characterLock}"
        promptor+="${colorReset}${colorLockChar}"
    fi
    # " ... > X [>]"
    promptor+="${characterRightFillArrow}"
    promptor+="${colorReset} "

    # --------------------------------------------------------------------------
    # Right prompt

    rpromptor="${colorReset}"
    # check git prompt file
    if ${__promptor[options.git]}; then
        builtin local branch=""
        if branch="$(git symbolic-ref HEAD)" &>/dev/null; then
            branch="${branch##refs/heads/}"
        else
            branch="$(git rev-parse --short HEAD)" &>/dev/null
        fi
        if [ -n "${branch}" ]; then
            builtin local colorGitFG="${colorGitFG}"
            builtin local colorGitBG="${colorGitBG}"
            builtin local colorGitChar="${colorGitChar}"
            builtin local count=""
            if git ls-files --others --exclude-standard \
                --directory --no-empty-directory \
                --error-unmatch -- ':/*' &>/dev/null ||
                ! git diff --no-ext-diff --quiet ||
                ! git diff --no-ext-diff --cached --quiet
            then
                colorGitFG="${colorGitCommitFG}"
                colorGitBG="${colorGitCommitBG}"
                colorGitChar="${colorGitCommitChar}"
            elif count=$(git rev-list --count HEAD...origin/HEAD) &>/dev/null
            then
                if [ "$count" = "0" ]; then
                    colorGitFG="${colorGitRemoteFG}"
                    colorGitBG="${colorGitRemoteBG}"
                    colorGitChar="${colorGitRemoteChar}"
                fi
            elif count=$(git rev-list --count HEAD...origin/$branch) &>/dev/null
            then
                if [ "$count" = "0" ]; then
                    colorGitFG="${colorGitRemoteFG}"
                    colorGitBG="${colorGitRemoteBG}"
                    colorGitChar="${colorGitRemoteChar}"
                fi
            fi
            # " [<] ... < ... "
            rpromptor+="${colorGitChar}${characterLeftFillArrow}"
            # " < [...] < ... "
            rpromptor+="${colorGitBG}${colorGitFG} ${branch}${characterBranch}"
        fi
    fi

    # " [< ...] < ... "
    rpromptor+="${colorRPromptChar}${characterLeftFillArrow}"
    rpromptor+="${colorRPromptBG}${colorRPromptFG}"
    rpromptor+="${__promptor[options.rprompt]}"

    if ${__promptor[options.hour]}; then
        # " < ... [<] ... "
        rpromptor+="${colorHourChar}${characterLeftFillArrow}"
        # " < ... < [...] "
        rpromptor+="${colorReset}${colorHourBG}${colorHourFG}"
        rpromptor+=" %D{%H:%M} " # current date
    fi

    rpromptor+="${colorReset}"

    PS1="${promptor}"
    RPROMPT="${rpromptor}"
}

add-zsh-hook precmd __promptor_precmd
add-zsh-hook preexec __promptor_preexec