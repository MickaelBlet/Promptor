#
# Promptor
#
# Licensed under the MIT License <http://opensource.org/licenses/MIT>.
# Copyright (c) 2024 BLET Mickaël.
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

readonly __PROMPTOR_CONFIG_PATH="${0:a:h}/promptor.conf"
readonly __PROMPTOR_FUNCS_DIR="${0:a:h}/promptor_functions"
readonly __PROMPTOR_PATH="${0:a}"

# ------------------------------------------------------------------------------
# LIBRARIES

# async
if (( ! ${+functions[async_init]} )); then
	# shellcheck source=./lib/async.zsh
	source "${0:A:h}/lib/async.zsh" && async_init
fi

builtin autoload -Uz add-zsh-hook

# ------------------------------------------------------------------------------
# CONFIGURATION

builtin declare -A promptor_config

# default configuration
promptor_config=(
	[powerline]=true
	[prompt]="[\ue0b6]237 231 %~ [\ue0b0] unwritten [\ue0b0] exit_code [\ue0b0]"
	[rprompt]="[\ue0b2] git_async [\ue0b2] 25 231 %n@%m [\ue0b2] 237 231 %D{%H:%M}[\ue0b4]"
	[title.command.max_size]=100
	[title]="%n: %~"
)
# actions of prompt
__promptor_prompt_actions=()
__promptor_rprompt_actions=()
__promptor_prompt_workers=()
__promptor_rprompt_workers=()
__promptor_left_characters=()
__promptor_right_characters=()

promptor_config_list() {
	builtin local key
	builtin local max_key_len=0
	for key in "${(@k)promptor_config}"; do
		if ! [[ "$key" =~ "default."* ]] && [ ${#key} -gt $max_key_len ]; then
			max_key_len=${#key}
		fi
	done
	for key in "${(@ko)promptor_config}"; do
		if ! [[ "$key" =~ "default."* ]]; then
			if [[ "${promptor_config[${key}]}" =~ [:space:]*'[\][u]'[:space:]* ]]; then
				builtin printf "%-*s = \"%s\" (%s)\n" "$max_key_len" "$key" "${promptor_config[${key}]}" "$(builtin echo -en  ${promptor_config[${key}]})"
			else
				builtin printf "%-*s = \"%s\"\n" "$max_key_len" "$key" "${promptor_config[${key}]}"
			fi
		fi
	done
}

__promptor_load_config_file() {
	builtin local config_array
	builtin eval "
		config_array=(
			$(cat "$__PROMPTOR_CONFIG_PATH")
		)
	"
	builtin local line key value
	for line in "${config_array[@]}"; do
		key="${line%%=*}"
		value="${line/${key}=/}"
		promptor_config[$key]="$value"
	done
}

__promptor_update_config_file() {
	# create default key if not exists
	for key in "${(@k)promptor_config}"; do
		if ! [[ "$key" =~ "default."* ]] && ! [[ -v promptor_config[default.$key] ]]; then
			promptor_config[default.$key]="${promptor_config[$key]}"
		fi
	done
	# reset old config file
	builtin printf "" > "$__PROMPTOR_CONFIG_PATH"
	builtin echo "# You can edit this file!" >> "$__PROMPTOR_CONFIG_PATH"
	builtin echo "# Execute 'promptor_reload' for take your change(s)" >> "$__PROMPTOR_CONFIG_PATH"
	builtin echo "" >> "$__PROMPTOR_CONFIG_PATH"
	builtin echo "# ----------------------------------------" >> "$__PROMPTOR_CONFIG_PATH"
	builtin echo "# VALUES" >> "$__PROMPTOR_CONFIG_PATH"
	builtin echo "# ----------------------------------------" >> "$__PROMPTOR_CONFIG_PATH"
	for key in "${(@ko)promptor_config}"; do
		if ! [[ "$key" =~ "default."* ]]; then
			builtin printf "%s='%s'\n" "$key" "${promptor_config[${key}]}" >> "$__PROMPTOR_CONFIG_PATH"
		fi
	done
	builtin echo "# ----------------------------------------" >> "$__PROMPTOR_CONFIG_PATH"
	builtin echo "# DEFAULTS" >> "$__PROMPTOR_CONFIG_PATH"
	builtin echo "# ----------------------------------------" >> "$__PROMPTOR_CONFIG_PATH"
	for key in "${(@ko)promptor_config}"; do
		if [[ "$key" =~ "default."* ]]; then
			builtin printf "%s='%s'\n" "$key" "${promptor_config[${key}]}" >> "$__PROMPTOR_CONFIG_PATH"
		fi
	done
}

__promptor_create_config_functions() {
	builtin local key
	for key in "${(@k)promptor_config}"; do
		if ! [[ "$key" =~ "default."* ]]; then
			builtin eval "
				promptor_config::${key}() {
					if [ -n \"\$1\" ] || [ \"\${1+x\$1}\" = \"x\" ] ; then
						promptor_config[${key}]="\$1"
					else
						builtin local reply=\${promptor_config[${key}]}
						builtin vared -p \"Promptor config: \\\"${key}\\\"
Default value: \${promptor_config[default.${key}]:gs/%/%%}
New value    : \" -c reply
						promptor_config[${key}]=\$reply
					fi
					__promptor_update_config_file
					__promptor_compile_prompts
				}
			"
		fi
	done
}

__promptor_compile_prompts() {
	if [ "${promptor_config[powerline]}" = true ]; then
		__promptor_left_characters=(
			"$(builtin echo -en "\ue0b0" 2> /dev/null)" # arrow.fill.left
			"$(builtin echo -en "\ue0b1" 2> /dev/null)" # arrow.left
			"$(builtin echo -en "\ue0b4" 2> /dev/null)" # curvy.fill.left
			"$(builtin echo -en "\ue0b5" 2> /dev/null)" # curvy.left
			"$(builtin echo -en "\ue0b8" 2> /dev/null)" # angly_down.fill.left
			"$(builtin echo -en "\ue0b9" 2> /dev/null)" # angly_down.left
			"$(builtin echo -en "\ue0bc" 2> /dev/null)" # angly_up.fill.left
			"$(builtin echo -en "\ue0bd" 2> /dev/null)" # angly_up.left
			"$(builtin echo -en "\ue0c0" 2> /dev/null)" # flame.fill.left
			"$(builtin echo -en "\ue0c1" 2> /dev/null)" # flame.left
			"$(builtin echo -en "\ue0c4" 2> /dev/null)" # pixel.left
			"$(builtin echo -en "\ue0c6" 2> /dev/null)" # big_pixel.left
			"$(builtin echo -en "\ue0c8" 2> /dev/null)" # signal.left
			"$(builtin echo -en "\ue0cc" 2> /dev/null)" # hexagon.fill.left
			"$(builtin echo -en "\ue0cd" 2> /dev/null)" # hexagon.left
			"$(builtin echo -en "\ue0ce" 2> /dev/null)" # lego.fill.left
			"$(builtin echo -en "\ue0cf" 2> /dev/null)" # lego.fill.up
			"$(builtin echo -en "\ue0d1" 2> /dev/null)" # lego.fill.left.side
			"$(builtin echo -en "\ue0d2" 2> /dev/null)" # bracket.fill.left
		)
		__promptor_right_characters=(
			"$(builtin echo -en "\ue0b3" 2> /dev/null)" # arrow.right
			"$(builtin echo -en "\ue0b6" 2> /dev/null)" # curvy.fill.right
			"$(builtin echo -en "\ue0b7" 2> /dev/null)" # curvy.right
			"$(builtin echo -en "\ue0ba" 2> /dev/null)" # angly_down.fill.right
			"$(builtin echo -en "\ue0bb" 2> /dev/null)" # angly_down.right
			"$(builtin echo -en "\ue0be" 2> /dev/null)" # angly_up.fill.right
			"$(builtin echo -en "\ue0bf" 2> /dev/null)" # angly_up.right
			"$(builtin echo -en "\ue0c2" 2> /dev/null)" # flame.fill.right
			"$(builtin echo -en "\ue0c3" 2> /dev/null)" # flame.right
			"$(builtin echo -en "\ue0c5" 2> /dev/null)" # pixel.right
			"$(builtin echo -en "\ue0c7" 2> /dev/null)" # big_pixel.right
			"$(builtin echo -en "\ue0ca" 2> /dev/null)" # signal.right
			"$(builtin echo -en "\ue0d4" 2> /dev/null)" # bracket.fill.right
			"$(builtin echo -en "\ue0b2" 2> /dev/null)" # arrow.fill.right
		)
	else
		__promptor_left_characters=()
		__promptor_right_characters=()
	fi

	__promptor_prompt_actions=()
	__promptor_rprompt_actions=()
	__promptor_prompt_workers=()
	__promptor_rprompt_workers=()

	__promptor_parse_prompt() {
		builtin local prompt_name="$1"
		builtin local prompt_step
		builtin local function_name
		builtin local prefix
		builtin local suffix
		builtin local args
		if builtin echo -en "${promptor_config[${prompt_name}]}" | grep -zo '\([^[]*\|\[[^]]*\]\)' &> /dev/null; then
			builtin echo -en "${promptor_config[${prompt_name}]}" | grep -zo '\([^[]*\|\[[^]]*\]\)' |
			while IFS='' builtin read -d $'\0' prompt_step; do
				function_name="$(builtin echo -e "$prompt_step" | sed 's/^\s*\([_[:alnum:]]\+\)\s*/\1/')"
				# check if worker exists
				if builtin typeset -f "__promptor_worker_$function_name" > /dev/null; then
					# prepare to launch worker with prompt argument
					if [ "$prompt_name" = "prompt" ]; then
						__promptor_prompt_workers=($__promptor_prompt_workers "__promptor_worker_$function_name '${prompt_name}'")
					else
						__promptor_rprompt_workers=($__promptor_rprompt_workers "__promptor_worker_$function_name '${prompt_name}'")
					fi
				fi
				# check if function exist
				if builtin typeset -f "__promptor_function_$function_name" > /dev/null; then
					prefix="$(builtin echo -e "$prompt_step" | sed 's/^\(\s*\)[_[:alnum:]]\+\s*/\1/')"
					suffix="$(builtin echo -e "$prompt_step" | sed 's/^\s*[_[:alnum:]]\+\(\s*\)/\1/')"
					if [ "$prompt_name" = "prompt" ]; then
						__promptor_prompt_actions=($__promptor_prompt_actions "
							builtin set -- \$(__promptor_function_${function_name} '${prompt_name}')
							[ \$# -gt 2 ] && builtin set -- \"\$1\" \"\$2\" \"$prefix\${@:3}$suffix\"
						")
					else
						__promptor_rprompt_actions=($__promptor_rprompt_actions "
							builtin set -- \$(__promptor_function_${function_name} '${prompt_name}')
							[ \$# -gt 2 ] && builtin set -- \"\$1\" \"\$2\" \"$prefix\${@:3}$suffix\"
						")
					fi
				else
					# section with background and foreground and other...
					if builtin echo -e "$prompt_step" | tr '\n' '\r' | grep '^\s*[0-9]\+\s\+[0-9]\+\s.*' &> /dev/null; then
						prefix="$(builtin echo -e "$prompt_step" | tr '\n' '\r' | sed 's/^\(\s*\)[0-9]\+\s\+[0-9]\+\s.*/\1/')"
						suffix="$(builtin echo -e "$prompt_step" | tr '\n' '\r' | sed 's/^\s*[0-9]\+\s\+[0-9]\+\s.*\(\s*\)$/\1/')"
						bg="$(builtin echo -e "$prompt_step" | tr '\n' '\r' | sed 's/^\s*\([0-9]\+\)\s\+[0-9]\+\s.*/\1/')"
						fg="$(builtin echo -e "$prompt_step" | tr '\n' '\r' | sed 's/^\s*[0-9]\+\s\+\([0-9]\+\)\s.*/\1/')"
						args="$(builtin echo -e "$prompt_step" | tr '\n' '\r' | sed 's/^\s*[0-9]\+\s\+[0-9]\+\s\(.*\)\s*$/\1/' | tr '\r' '\n')"
						if [ "$prompt_name" = "prompt" ]; then
							__promptor_prompt_actions=($__promptor_prompt_actions "
								builtin set -- '$bg' '$fg' '$prefix$args$suffix'
							")
						else
							__promptor_rprompt_actions=($__promptor_rprompt_actions "
								builtin set -- '$bg' '$fg' '$prefix$args$suffix'
							")
						fi
					else
						if [ "$prompt_name" = "prompt" ]; then
							__promptor_prompt_actions=($__promptor_prompt_actions "
								builtin set -- '${prompt_step}'
							")
						else
							__promptor_rprompt_actions=($__promptor_rprompt_actions "
								builtin set -- '${prompt_step}'
							")
						fi
					fi
				fi
			done
		else
			if [ "$prompt_name" = "prompt" ]; then
				__promptor_prompt_actions=($__promptor_prompt_actions "
					builtin set -- '${promptor_config[$prompt_name]}'
				")
			else
				__promptor_rprompt_actions=($__promptor_rprompt_actions "
					builtin set -- '${promptor_config[$prompt_name]}'
				")
			fi
		fi
	}
	__promptor_parse_prompt "prompt"
	__promptor_parse_prompt "rprompt"
}

# ------------------------------------------------------------------------------
# FUNCTION

__promptor_load_functions() {
	builtin local function_file
	builtin local function_name
	builtin local worker_name
	builtin local key
	builtin local value
	# load functions
	for function_file in "$__PROMPTOR_FUNCS_DIR/"*; do
		# source function file
		source "$function_file"
	done
	# rename function to private
	for function_name in $(typeset +mf "promptor_function_*"); do
		functions -c $function_name __$function_name
		unfunction $function_name
	done
	# rename worker to private
	for worker_name in $(typeset +mf "promptor_worker_*"); do
		functions -c $worker_name __$worker_name
		unfunction $worker_name
		# if function exists with worker
		if builtin typeset -f "__promptor_function_${worker_name#promptor_worker_}" > /dev/null; then
			functions -c __promptor_function_${worker_name#promptor_worker_} __promptor_function_${worker_name#promptor_worker_}_default
		else
			# create empty function
			eval "
				__promptor_function_${worker_name#promptor_worker_}(){}
				__promptor_function_${worker_name#promptor_worker_}_default(){}
			"
		fi
	done
}

# ------------------------------------------------------------------------------
# WORKER

promptor_launch_worker_job() {
	builtin local function_name="$1"
	builtin local prompt="$2"
	builtin local job="$3"
	builtin local callback="${4:-}"

	builtin local worker_name="__promptor_worker_${function_name}_${prompt}"

	if [ -z "$callback" ]; then
		callback="__promptor_worker_${function_name}_callback_default"
		eval "
			$callback() {
				promptor_reload_prompt_from_function \"${function_name}\" \"\$2\"
			}
		"
	fi

	# create function of worker
	eval "
		__promptor_worker_${function_name}_callback_${prompt}() {
			${callback} \"${prompt}\" \"\$3\"
			async_stop_worker \"$worker_name\" -n
		}
	"

	async_start_worker "$worker_name" -n
	async_register_callback "$worker_name" "__promptor_worker_${function_name}_callback_${prompt}"
	async_job "$worker_name" "$job" "$prompt"
}

# ------------------------------------------------------------------------------
# RELOAD

promptor_reload() {
	builtin echo "Reload $__PROMPTOR_PATH and $__PROMPTOR_CONFIG_PATH"
	__promptor_load_config_file
	builtin source "$__PROMPTOR_PATH"
}

promptor_reload_prompt_from_function() {
	builtin local function_name="$1"
	builtin local function_answer="$2"

	# create temporary replace function
	eval "__promptor_function_$function_name() { echo \"$function_answer\" }"

	# set new prompt with temporary function
	__promptor_print_prompts
	# reset prompt
	zle && zle .reset-prompt
}

# ------------------------------------------------------------------------------
# GLYPHS

promptor_glyphs() {
	builtin local i
	builtin local j=0
	for i in {57520..57556}; do
		[ $i -eq 57545 ] || [ $i -eq 57547 ] || [ $i -eq 57555 ] && continue
		if [ $j -gt 0 ] && [ $((j % 2)) -eq 0 ]; then
			builtin printf "\n"
		fi
		builtin printf "\\\\u%x %b  " "$i" "$(printf '\\u%x' "i")"
		j=$((j + 1))
	done
	builtin printf "\n"
}

# ------------------------------------------------------------------------------
# COLORS

promptor_colors() {
	builtin local i j k l
	builtin local color
	builtin local colors=""

	for i in {0..15}; do
		colors+=$'\033[48;5;'$i$'m'
		[ $((i%8)) -eq 0 ] && colors+=$'\033[38;5;231m' || colors+=$'\033[38;5;232m'
		[ $i -lt 10 ] && colors+="  " || colors+=" "
		colors+="$i"
		colors+=$'\033[0m '
		[ $i -eq 7 ] && colors+="\n"
	done
	colors+="\n\n"
	for i in {0..1}; do
		for j in {0..5}; do
			for k in {0..2}; do
				for l in {0..5}; do
					color=$((j*6+k*36+l+i*108+16))
					colors+=$'\033[48;5;'$color$'m'
					[ $((((color-16)%36)/6)) -gt 2 ] && colors+=$'\033[38;5;232m' || colors+=$'\033[38;5;231m'
					[ $color -lt 100 ] && colors+=" "
					colors+="$color"
					colors+=$'\033[0m '
				done
				[ $k -lt 2 ] && colors+="  "
			done
			colors+="\n"
		done
	done
	colors+="\n"
	for i in {232..255}; do
		colors+=$'\033[48;5;'$i$'m'
		[ $i -gt 243 ] && colors+=$'\033[38;5;232m' || colors+=$'\033[38;5;231m'
		colors+="$i"
		colors+=$'\033[0m '
		[ $i -eq 243 ] && colors+="\n"
	done
	builtin echo -e "$colors\033[0m"
}

# ------------------------------------------------------------------------------
# HOOK

__promptor_print_title() {
	# refresh title bar with current command
	builtin printf "\033]0;%.*s\007" "${promptor_config[title.command.max_size]}" "$1"
}

__promptor_launch_workers() {
	builtin local function_name
	for function_name in $(typeset +mf "__promptor_function_*_default"); do
		# replace by default function
		functions -c "$function_name" "${function_name%_default}"
	done
	builtin local worker
	for worker in "${__promptor_prompt_workers[@]}"; do
		builtin eval "$worker"
	done
	for worker in "${__promptor_rprompt_workers[@]}"; do
		builtin eval "$worker"
	done
}

__promptor_print_prompts() {
	builtin local reset_color=$'%{\033[0m%}'
	builtin local _prompt
	builtin local _rprompt
	builtin local __prompt_is_started=false
	builtin local __next_character=''
	builtin local action

	# --------------------------------------------------------------------------
	# Left _prompt

	_prompt=$'%{\033]0;'"${promptor_config[title]}"$'\007%}'
	_prompt+="${reset_color}"
	for action in "${__promptor_prompt_actions[@]}"; do
		builtin eval "$action"
		if [ $# -eq 0 ]; then
			__next_character=""
			continue
		elif [ $# -eq 1 ] && [[ "$1" =~ "\["*"\]" ]]; then
			if $__prompt_is_started && [ -n "$__next_character" ]; then
				if (( $__promptor_right_characters[(Ie)${__next_character}] )); then
					_prompt+="${__next_character}"
					_prompt+="${reset_color}"
					__prompt_is_started=false
				elif (( $__promptor_left_characters[(Ie)${__next_character}] )); then
					_prompt+="${__next_character}"
					_prompt+="${reset_color}"
					__prompt_is_started=false
				fi
			fi
			__next_character="$1"
			__next_character="${__next_character:1:-1}"
		elif [ $# -gt 2 ]; then
			if [ -n "$__next_character" ]; then
				if (( $__promptor_right_characters[(Ie)${__next_character}] )); then
					_prompt+=$'%{\033[38;5;'$1$'m%}'
					_prompt+="${__next_character}"
					_prompt+=$'%{\033[48;5;'$1$'m%}'
					_prompt+=$'%{\033[38;5;'$2$'m%}'
				elif (( $__promptor_left_characters[(Ie)${__next_character}] )); then
					_prompt+=$'%{\033[48;5;'$1$'m%}'
					_prompt+="${__next_character}"
					_prompt+=$'%{\033[38;5;'$2$'m%}'
				else
					_prompt+=$'%{\033[48;5;'$1$'m%}'
					if ! $__prompt_is_started; then
						_prompt+=" "
					fi
					_prompt+=$'%{\033[38;5;'$2$'m%}'
				fi
				__next_character=''
			else
				_prompt+=$'%{\033[48;5;'$1$'m%}'
				_prompt+=$'%{\033[38;5;'$2$'m%}'
			fi
			_prompt+="${@:3}"
			_prompt+="${reset_color}"
			_prompt+=$'%{\033[38;5;'$1$'m%}'
			__prompt_is_started=true
		elif [ -n "$1" ]; then
			if $__prompt_is_started && [ -n "$__next_character" ]; then
				if (( $__promptor_right_characters[(Ie)${__next_character}] )); then
					_prompt+="${__next_character}"
				elif (( $__promptor_left_characters[(Ie)${__next_character}] )); then
					_prompt+="${__next_character}"
				fi
				__next_character=''
			fi
			_prompt+="${reset_color}"
			_prompt+="$@"
			__prompt_is_started=false
		else
			_prompt+="${reset_color}"
			__prompt_is_started=false
		fi
	done
	if $__prompt_is_started && [ -n "$__next_character" ]; then
		if (( $__promptor_right_characters[(Ie)${__next_character}] )); then
			_prompt+="${__next_character}"
		elif (( $__promptor_left_characters[(Ie)${__next_character}] )); then
			_prompt+="${__next_character}"
		fi
		__next_character=''
	fi
	_prompt+="${reset_color} "

	__next_character=''
	__prompt_is_started=false

	# --------------------------------------------------------------------------
	# Right prompt

	builtin local last_fg_color
	builtin local last_bg_color

	_rprompt="${reset_color}"
	for action in "${__promptor_rprompt_actions[@]}"; do
		builtin eval "$action"
		if [ $# -eq 0 ]; then
			__next_character=""
			continue
		elif [ $# -eq 1 ] && [[ "$1" =~ "\["*"\]" ]]; then
			if $__prompt_is_started && [ -n "$__next_character" ]; then
				if (( $__promptor_right_characters[(Ie)${__next_character}] )); then
					_rprompt+="${__next_character}"
					_rprompt+="${reset_color}"
					__prompt_is_started=false
				elif (( $__promptor_left_characters[(Ie)${__next_character}] )); then
					_rprompt+="${reset_color}"
					_rprompt+=$'%{\033[38;5;'$last_bg_color$'m%}'
					_rprompt+="${__next_character}"
					__prompt_is_started=false
				fi
			fi
			__next_character="$1"
			__next_character="${__next_character:1:-1}"
		elif [ $# -gt 2 ]; then
			 if [ -n "$__next_character" ]; then
				if (( $__promptor_right_characters[(Ie)${__next_character}] )); then
					_rprompt+=$'%{\033[38;5;'$1$'m%}'
					_rprompt+="${__next_character}"
					_rprompt+=$'%{\033[48;5;'$1$'m%}'
					_rprompt+=$'%{\033[38;5;'$2$'m%}'
				elif (( $__promptor_left_characters[(Ie)${__next_character}] )); then
					_rprompt+=$'%{\033[48;5;'$1$'m%}'
					_rprompt+="${__next_character}"
					_rprompt+=$'%{\033[38;5;'$2$'m%}'
				else
					_rprompt+=$'%{\033[48;5;'$1$'m%}'
					_rprompt+=$'%{\033[38;5;'$2$'m%}'
				fi
				__next_character=''
			else
				_rprompt+=$'%{\033[48;5;'$1$'m%}'
				_rprompt+=$'%{\033[38;5;'$2$'m%}'
			fi
			last_fg_color="$1"
			last_bg_color="$1"
			_rprompt+="${@:3}"
			_rprompt+=$'%{\033[38;5;'$1$'m%}'
			__prompt_is_started=true
		elif [ -n "$1" ]; then
			_rprompt+="${reset_color}"
			_rprompt+="$@"
			__prompt_is_started=true
		else
			_rprompt+="${reset_color}"
			__prompt_is_started=false
		fi
	done
	if (( $__promptor_right_characters[(Ie)${__next_character}] )); then
		_rprompt+="${reset_color}"
		_rprompt+=$'%{\033[38;5;'$last_fg_color$'m%}'
		_rprompt+="${__next_character}"
	elif (( $__promptor_left_characters[(Ie)${__next_character}] )); then
		_rprompt+="${reset_color}"
		_rprompt+=$'%{\033[38;5;'$last_fg_color$'m%}'
		_rprompt+="${__next_character}"
	else
		_rprompt+=" "
	fi
	_rprompt+="${reset_color}"

	typeset -g PROMPT="$_prompt"
	typeset -g RPROMPT="$_rprompt"
}

# pre exec command event
__promptor_preexec() {
	__promptor_print_title "$@"
}

# pre command event
__promptor_precmd() {
	typeset -g __promptor_last_exit_code=$?
	__promptor_launch_workers
	__promptor_print_prompts
	__vsc_in_command_execution="1"
}

# create config if not exist
if [ ! -f "$__PROMPTOR_CONFIG_PATH" ]; then
	"touch" "$__PROMPTOR_CONFIG_PATH"
fi

if [ ! -d "$__PROMPTOR_FUNCS_DIR" ]; then
	"mkdir" -p "$__PROMPTOR_FUNCS_DIR"
fi

__promptor_load_functions
__promptor_load_config_file
__promptor_create_config_functions
__promptor_update_config_file
__promptor_compile_prompts

add-zsh-hook precmd __promptor_precmd
add-zsh-hook preexec __promptor_preexec