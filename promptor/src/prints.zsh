#
# Promptor/prints
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

__promptor_print_title() {
	# refresh title bar with current command
	builtin printf "\033]0;%.*s\007" "${promptor_config[title.command.max_size]}" "$1"
}

__promptor_print_prompts() {
	builtin typeset -g __promptor_prompt_actions
	builtin typeset -g __promptor_rprompt_actions
	builtin typeset -g __promptor_right_characters
	builtin typeset -g __promptor_left_characters

	builtin local reset_color=$'%{\033[0m%}'
	builtin local _prompt
	builtin local _rprompt
	builtin local __prompt_is_started=false
	builtin local __next_character=''
	builtin local __promptor_prompt
	builtin local action

	# --------------------------------------------------------------------------
	# Left _prompt

	__promptor_prompt='prompt'

	# title
	_prompt=$'%{\033]0;'"${promptor_config[title]}"$'\007%}'
	_prompt+="${reset_color}"
	for action in "${__promptor_prompt_actions[@]}"; do
		builtin eval "$action"
		if [ $# -eq 0 ]; then
			continue
		elif [ $# -eq 1 ] && [[ "$1" =~ '^\[.*\]$' ]]; then
			if $__prompt_is_started && [ -n "$__next_character" ]; then
				if (( $__promptor_right_characters[(Ie)${__next_character}] )) && \
					! (( $__promptor_right_characters[(Ie)${1:1:-1}] )); then
					_prompt+="${__next_character}"
					_prompt+="${reset_color}"
					__prompt_is_started=false
					__next_character=""
				fi
			fi
			if [ "${1:1:-1}" = $'\n' ]; then
				__next_character=""
				_prompt+=$'\n'
			elif [ -z "$__next_character" ] && ; then
				__next_character="$1"
				__next_character="${__next_character:1:-1}"
			fi
		elif [ $# -gt 2 ]; then
			if [ -n "$__next_character" ]; then
				if (( $__promptor_left_characters[(Ie)${__next_character}] )); then
					[ "$1" -ne -1 ] && _prompt+=$'%{\033[38;5;'$1$'m%}'
					_prompt+="${__next_character}"
					[ "$1" -ne -1 ] &&_prompt+=$'%{\033[48;5;'$1$'m%}'
					[ "$2" -ne -1 ] &&_prompt+=$'%{\033[38;5;'$2$'m%}'
				elif (( $__promptor_right_characters[(Ie)${__next_character}] )); then
					[ "$1" -ne -1 ] && _prompt+=$'%{\033[48;5;'$1$'m%}'
					_prompt+="${__next_character}"
					[ "$2" -ne -1 ] && _prompt+=$'%{\033[38;5;'$2$'m%}'
				else
					[ "$1" -ne -1 ] && _prompt+=$'%{\033[48;5;'$1$'m%}'
					[ "$2" -ne -1 ] && _prompt+=$'%{\033[38;5;'$2$'m%}'
				fi
				__next_character=''
			else
				[ "$1" -ne -1 ] && _prompt+=$'%{\033[48;5;'$1$'m%}'
				[ "$2" -ne -1 ] && _prompt+=$'%{\033[38;5;'$2$'m%}'
			fi
			_prompt+="${@:3}"
			_prompt+="${reset_color}"
			[ "$1" -ne -1 ] && _prompt+=$'%{\033[38;5;'$1$'m%}'
			__prompt_is_started=true
		elif [ -n "$1" ]; then
			if $__prompt_is_started && [ -n "$__next_character" ]; then
				_prompt+="${__next_character}"
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
		if (( $__promptor_left_characters[(Ie)${__next_character}] )); then
			_prompt+="${__next_character}"
		elif (( $__promptor_right_characters[(Ie)${__next_character}] )); then
			_prompt+="${__next_character}"
		fi
		__next_character=''
	fi
	_prompt+="${reset_color} "

	__next_character=''
	__prompt_is_started=false

	# --------------------------------------------------------------------------
	# Right prompt

	__promptor_prompt='rprompt'

	builtin local last_fg_color
	builtin local last_bg_color

	if [ "${#__promptor_rprompt_actions[@]}" -ne 0 ]; then
		_rprompt="${reset_color}"
		for action in "${__promptor_rprompt_actions[@]}"; do
			builtin eval "$action"
			if [ $# -eq 0 ]; then
				__next_character=""
				continue
			elif [ $# -eq 1 ] && [[ "$1" =~ '^\[.*\]$' ]]; then
				if $__prompt_is_started && [ -n "$__next_character" ]; then
					if (( $__promptor_left_characters[(Ie)${__next_character}] )); then
						_rprompt+="${__next_character}"
						_rprompt+="${reset_color}"
						__prompt_is_started=false
					elif (( $__promptor_right_characters[(Ie)${__next_character}] )); then
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
					if (( $__promptor_left_characters[(Ie)${__next_character}] )); then
						[ "$1" -ne -1 ] && _rprompt+=$'%{\033[38;5;'$1$'m%}'
						_rprompt+="${__next_character}"
						[ "$1" -ne -1 ] && _rprompt+=$'%{\033[48;5;'$1$'m%}'
						[ "$2" -ne -1 ] && _rprompt+=$'%{\033[38;5;'$2$'m%}'
					elif (( $__promptor_right_characters[(Ie)${__next_character}] )); then
						[ "$1" -ne -1 ] && _rprompt+=$'%{\033[48;5;'$1$'m%}'
						_rprompt+="${__next_character}"
						[ "$2" -ne -1 ] && _rprompt+=$'%{\033[38;5;'$2$'m%}'
					else
						[ "$1" -ne -1 ] && _rprompt+=$'%{\033[48;5;'$1$'m%}'
						[ "$2" -ne -1 ] && _rprompt+=$'%{\033[38;5;'$2$'m%}'
					fi
					__next_character=''
				else
					[ "$1" -ne -1 ] && _rprompt+=$'%{\033[48;5;'$1$'m%}'
					[ "$2" -ne -1 ] && _rprompt+=$'%{\033[38;5;'$2$'m%}'
				fi
				last_fg_color="$1"
				last_bg_color="$1"
				_rprompt+="${@:3}"
				[ "$1" -ne -1 ] && _rprompt+=$'%{\033[38;5;'$1$'m%}'
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
		if (( $__promptor_left_characters[(Ie)${__next_character}] )); then
			_rprompt+="${reset_color}"
			_rprompt+=$'%{\033[38;5;'$last_fg_color$'m%}'
			_rprompt+="${__next_character}"
		elif (( $__promptor_right_characters[(Ie)${__next_character}] )); then
			_rprompt+="${reset_color}"
			_rprompt+=$'%{\033[38;5;'$last_fg_color$'m%}'
			_rprompt+="${__next_character}"
		else
			_rprompt+=" "
		fi
		_rprompt+="${reset_color}"
	else
		_rprompt=""
	fi

	builtin typeset -g PROMPT="$_prompt"
	builtin typeset -g RPROMPT="$_rprompt"

	# vscode update terminal
	(( ${+functions[__vsc_update_prompt]} )) && __vsc_update_prompt
}