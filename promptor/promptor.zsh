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

# ------------------------------------------------------------------------------
# CONFIGURATION

builtin declare -A promptor_config

__PROMPTOR_CONFIG_PATH="${0:a:h}/promptor_config.conf"
__PROMPTOR_FUNCS_DIR="${0:a:h}/promptor_functions"

promptor_config_list() {
    builtin local config_array
    builtin eval "
        config_array=(
            $(cat "$__PROMPTOR_CONFIG_PATH")
        )
    "
    builtin local value value_left value_right max_len_value_left
    max_len_value_left=0
    for value in ${(o)config_array[@]}; do
        value_left=${value%%=*}
        if ! [[ "$value" =~ "default."* ]]; then
            if [[ ${#value_left} -gt $max_len_value_left ]]; then
                max_len_value_left=${#value_left}
            fi
        fi
    done
    for value in ${(o)config_array[@]}; do
        value_left=${value%%=*}
        value_right=${value/${value_left}=/}
        if ! [[ "$value" =~ "default."* ]]; then
            builtin printf "%-*s = \"%s\"\n" $max_len_value_left $value_left $value_right
        fi
    done
}

__promptor_add_config() {
    builtin local value="$1"
    builtin local value_left=${value%%=*}
    builtin local value_right=${value/${value_left}=/}

    # check if configuration is already exist
    if ! grep -q "^default\.${value_left//./\.}=\".*\"" "$__PROMPTOR_CONFIG_PATH"; then
        # insert new element in configuration
        builtin echo "default.${value_left}=\"${value_right}\"" >> "$__PROMPTOR_CONFIG_PATH"
    fi
    if ! grep -q "^${value_left//./\.}=\".*\"" "$__PROMPTOR_CONFIG_PATH"; then
        # insert new element in configuration
        builtin echo "${value_left}=\"${value_right}\"" >> "$__PROMPTOR_CONFIG_PATH"
    fi

    promptor_config[${value_left}]="${value_right}"
}

__promptor_create_config() {
    builtin local config_array
    config_array=(
        # default options
        powerline="false"
        title="%n: %~"
        max_command_title_size="100"
        prompt="{{237 231 %~}}{{git}}{{unwritten}}"
        rprompt="{{25 231 %n@%m}}{{237 231 %D{%H:%M}}}"
    )

    builtin echo "# PROMPTOR CONFIGURATION" > "$__PROMPTOR_CONFIG_PATH"
    builtin echo >> "$__PROMPTOR_CONFIG_PATH"

    # transform array to config format
    builtin local value
    for value in ${config_array[@]}; do
        __promptor_add_config "$value"
    done
}

# update or add configuration in configuration file
__promptor_update_config() {
    builtin local promptor_option="$1"
    builtin local promptor_value="$2"

    sed -i "s/^\(""${promptor_option//./\.}""\)=.*/\1=\"${promptor_value//\\/\\\\}\"/" "$__PROMPTOR_CONFIG_PATH" && \
    promptor_config[$promptor_option]="$(builtin echo "$promptor_value")"
}

__promptor_load_configs() {
    builtin local config_array
    builtin eval "
        config_array=(
            $(cat "$__PROMPTOR_CONFIG_PATH")
        )
    "
    builtin local value value_left value_right

    for value in ${config_array[@]}; do
        value_left=${value%%=*}
        value_right=${value/${value_left}=/}
        # create update config function
        if ! [[ "$value" =~ "default."* ]]; then
            builtin eval "
                export promptor_config_${${value%%=*}//'.'/'_'} () {
                    if [ -n \"\$1\" ] || [ \"\${1+x\$1}\" = \"x\" ] ; then
                        __promptor_update_config "${value%%=*}" "\$1"
                    else
                        builtin local reply
                        reply=\"\${promptor_config[${value%%=*}]}\"
                        builtin vared -p \"Default value: \${promptor_config[default.${value%%=*}]:gs/%/%%}
New value of \\\"${value%%=*}\\\" configuration: \" -c reply
                        __promptor_update_config "${value%%=*}" "\$reply"
                    fi
                }
            "
        fi
        promptor_config[$value_left]="$value_right"
    done
}

# ------------------------------------------------------------------------------
# FUNCTION

__promptor_load_functions() {
    builtin local function_file
    builtin local config_array
    builtin local value
    # load functions
    for function_file in "$__PROMPTOR_FUNCS_DIR/"*; do
        # config
        builtin eval "
            config_array=(
                $(cat "$function_file" | sed -n "/^#\s*CONFIG.*$/,/#\s*FUNCTION.*/ { /^#\s*CONFIG.*$/d ; /#\s*FUNCTION.*/d ; /^$/d ; p }")
            )
        "
        for value in ${(o)config_array[@]}; do
            # insert in configuration file if not exist
            __promptor_add_config "$value"
        done

        # function
        builtin eval "
            __promptor_function_$( basename "$function_file" )() {
                $(cat "$function_file" | sed '/#\s*CONFIG.*/,/#\s*FUNCTION.*/d')
            }
        "
    done
}

# ------------------------------------------------------------------------------
# HOOK

# pre exec command event
__promptor::preexec() {
    # refresh title bar with current command
    builtin printf "\033]0;%*.*s\007" "${promptor_config[max_command_title_size]}" "${promptor_config[max_command_title_size]}" "$1"
}

# pre command event
__promptor::precmd() {
    builtin local reset_color=$'%{\033[0m%}'
    builtin local _prompt _rpompt
    builtin local right_fill_arrow=''
    builtin local left_fill_arrow=''

    # font character
    if ${promptor_config[powerline]}; then
        right_fill_arrow=$'\ue0b0' &> /dev/null
        left_fill_arrow=$'\ue0b2' &> /dev/null
    fi

    # --------------------------------------------------------------------------
    # Left _prompt

    builtin local title_bar=$'%{\033]0;'${promptor_config[title]}$'\007%}'

    _prompt="${title_bar}"
    _prompt+="${reset_color}"

    builtin local __prompt_is_started=false
    builtin local promptor_functions
    builtin echo "${promptor_config[prompt]}" | grep -o '[^{]*{{[^}]\+}}[^{]*' |
    while builtin read -A promptor_functions; do
        builtin local promptor_function="__promptor_function_$(echo "$promptor_functions" | sed 's/^[^{]*{{\(.\+\)}}.*/\1/')"
        # check if function exist
        if builtin typeset -f "$promptor_function" > /dev/null; then
            builtin set -- $($promptor_function)
            if [ -n "$*" ]; then
                builtin set -- "$argv[1]" "$argv[2]" "$argv[3,-1]"
            else
                continue
            fi
        else
            # section
            if echo "$promptor_functions" | grep '^[^{]*{{[0-9]\+\s\+[0-9]\+\s.*}}.*' &> /dev/null; then
                builtin set -- "$(echo "$promptor_functions" | sed 's/^[^{]*{{\([0-9]\+\).*}}.*/\1/')" \
                               "$(echo "$promptor_functions" | sed 's/^[^{]*{{[0-9]\+\s\+\([0-9]\+\).*}}.*/\1/')" \
                               "$(echo "$promptor_functions" | sed 's/^[^{]*{{[0-9]\+\s\+[0-9]\+\s\(.*\)}}.*/\1/')"
            else
                builtin set --
            fi
        fi
        if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
            builtin local color_char=$'%{\033[38;5;'$1$'m%}'
            builtin local color_bg=$'%{\033[48;5;'$1$'m%}'
            builtin local color_fg=$'%{\033[38;5;'$2$'m%}'
            _prompt+="${color_bg}"
            if $__prompt_is_started; then
                _prompt+="${right_fill_arrow}"
            fi
            _prompt+="${color_fg}"
            _prompt+="$(echo "$promptor_functions" | sed 's/^\([^{]*\){{.\+}}.*/\1/')"
            _prompt+=" $3 "
            _prompt+="$(echo "$promptor_functions" | sed 's/^[^{]*{{.\+}}\(.*\)/\1/')"
            _prompt+="${reset_color}${color_char}"
            __prompt_is_started=true
        else
            if $__prompt_is_started; then
                _prompt+="${right_fill_arrow}"
            fi
            _prompt+="${reset_color}"
            _prompt+="$promptor_functions"
            __prompt_is_started=false
        fi
    done
    if ! builtin echo "${promptor_config[prompt]}" | grep -o '[^{]*{{[^}]\+}}[^{]*' &> /dev/null; then
        _prompt+="${promptor_config[prompt]}"
    else
        if $__prompt_is_started; then
            _prompt+="${right_fill_arrow}"
        fi
    fi
    _prompt+="${reset_color} "

    # --------------------------------------------------------------------------
    # Right prompt

    _rprompt="${reset_color}"

    builtin echo "${promptor_config[rprompt]}" | grep -o '[^{]*{{[^}]\+}}[^{]*' |
    while builtin read -A promptor_functions; do
        builtin local promptor_function="__promptor_function_$(echo "$promptor_functions" | sed 's/^[^{]*{{\(.\+\)}}.*/\1/')"
        # check if function exist
        if builtin typeset -f "$promptor_function" > /dev/null; then
            builtin set -- $($promptor_function)
            if [ -n "$*" ]; then
                builtin set -- "$argv[1]" "$argv[2]" "$argv[3,-1]"
            else
                continue
            fi
        else
            # section
            if echo "$promptor_functions" | grep '^[^{]*{{[0-9]\+\s\+[0-9]\+\s.*}}.*' &> /dev/null; then
                builtin set -- "$(echo "$promptor_functions" | sed 's/^[^{]*{{\([0-9]\+\).*}}.*/\1/')" \
                               "$(echo "$promptor_functions" | sed 's/^[^{]*{{[0-9]\+\s\+\([0-9]\+\).*}}.*/\1/')" \
                               "$(echo "$promptor_functions" | sed 's/^[^{]*{{[0-9]\+\s\+[0-9]\+\s\(.*\)}}.*/\1/')"
            else
                builtin set --
            fi
        fi
        if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
            builtin local color_char=$'%{\033[38;5;'$1$'m%}'
            builtin local color_bg=$'%{\033[48;5;'$1$'m%}'
            builtin local color_fg=$'%{\033[38;5;'$2$'m%}'
            _rprompt+="${color_char}${left_fill_arrow}"
            _rprompt+="${color_bg}"
            _rprompt+="${color_fg}"
            _rprompt+="$(echo "$promptor_functions" | sed 's/^\([^{]*\){{.\+}}.*/\1/')"
            _rprompt+=" $3 "
            _rprompt+="$(echo "$promptor_functions" | sed 's/^[^{]*{{.\+}}\(.*\)/\1/')"
        else
            _rprompt+="${reset_color}"
            _rprompt+="$promptor_functions"
        fi
    done

    _rprompt+="${reset_color}"

    PROMPT="${_prompt}"
    RPROMPT="${_rprompt}"
}

# create config if not exist
if [ ! -f "$__PROMPTOR_CONFIG_PATH" ]; then
    __promptor_create_config
fi


if [ ! -d "$__PROMPTOR_FUNCS_DIR" ]; then
    "mkdir" -p "$__PROMPTOR_FUNCS_DIR"
fi

__promptor_load_functions
__promptor_load_configs

add-zsh-hook precmd __promptor::precmd
add-zsh-hook preexec __promptor::preexec