#
# Promptor/compile
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

__promptor_precompile_prompts() {
	builtin typeset -g __promptor_prompt_actions
	builtin typeset -g __promptor_rprompt_actions
	builtin typeset -g __promptor_prompt_workers
	builtin typeset -g __promptor_rprompt_workers
	builtin typeset -g __promptor_right_characters
	builtin typeset -g __promptor_left_characters

	if [ "${promptor_config[powerline]}" = true ]; then
		__promptor_right_characters=(
			$'\ue0b0' # left_hard_divider
			$'\ue0b1' # left_soft_divider
			$'\ue0b4' # right_half_circle_thick
			$'\ue0b5' # right_half_circle_thin
			$'\ue0b8' # lower_left_triangle
			$'\ue0b9' # backslash_separator
			$'\ue0bc' # upper_left_triangle
			$'\ue0bd' # forwardslash_separator_redundant
			$'\ue0c0' # flame_thick
			$'\ue0c1' # flame_thin
			$'\ue0c4' # pixelated_squares_small
			$'\ue0c6' # pixelated_squares_big
			$'\ue0c8' # ice_waveform
			$'\ue0cc' # honeycomb
			$'\ue0cd' # honeycomb_outline
			$'\ue0ce' # lego_separator
			$'\ue0cf' # lego_separator_thin
			$'\ue0d1' # lego_block_sideways
			$'\ue0d2' # trapezoid_top_bottom
			$'\ue0d6' # right_hard_divider_inverse
		)
		__promptor_left_characters=(
			$'\ue0b2' # right_hard_divider
			$'\ue0b3' # right_soft_divider
			$'\ue0b6' # left_half_circle_thick
			$'\ue0b7' # left_half_circle_thin
			$'\ue0ba' # lower_right_triangle
			$'\ue0bb' # forwardslash_separator
			$'\ue0be' # upper_right_triangle
			$'\ue0bf' # backslash_separator_redundant
			$'\ue0c2' # flame_thick_mirrored
			$'\ue0c3' # flame_thin_mirrored
			$'\ue0c5' # pixelated_squares_small_mirrored
			$'\ue0c7' # pixelated_squares_big_mirrored
			$'\ue0ca' # ice_waveform_mirrored
			$'\ue0d4' # trapezoid_top_bottom_mirrored
			$'\ue0d7' # left_hard_divider_inverse
		)
	else
		__promptor_right_characters=()
		__promptor_left_characters=()
	fi

	__promptor_prompt_actions=()
	__promptor_rprompt_actions=()
	__promptor_prompt_workers=()
	__promptor_rprompt_workers=()

	__promptor_split_prompt() {
		builtin local array_name="$1"
		builtin local prompt="$2"
		builtin local left
		builtin local right
		builtin local in_bracket
		builtin local ret_array
		builtin local i=0
		ret_array=()
		while [[ "$prompt" =~ '\[' ]]; do
			right="${prompt##*\[}"
			left="${prompt%\[*}"
			if [ -n "$right" ]; then
				in_bracket="[${right%\]*}]"
				right="${right#*\]}"
				if [ -n "$right" ]; then
					ret_array=("${right}" "${ret_array[@]}")
				fi
				ret_array=("${in_bracket}" "${ret_array[@]}")
			fi
			prompt="${left}"
			i=$((i + 1))
			if [ $i -gt 255 ]; then
				break
			fi
		done
		if [ -n "$prompt" ]; then
			ret_array=("${prompt}" "${ret_array[@]}")
		fi
		eval $array_name'=("$ret_array[@]")'
	}

	__promptor_parse_prompt() {
		builtin local prompt_name="$1"
		builtin local prompt_steps
		builtin local prompt_step
		builtin local glyph_name
		builtin local function_name
		builtin local function_args
		builtin local prefix
		builtin local suffix
		builtin local args
		__promptor_split_prompt "prompt_steps" "${promptor_config[${prompt_name}]}"
		for prompt_step in "${prompt_steps[@]}"; do
			# section with background and foreground and other...
			if [[ "$prompt_step" =~ '^\s*[-0-9]+\s+[-0-9]+\s.*$' ]]; then
				prefix="${prompt_step%%[-0-9]*}"
				prompt_step="${prompt_step:${#prefix}}"
				bg="${prompt_step%%[[:blank:]]*}"
				prompt_step="${prompt_step#*[[:blank:]]}"
				fg="${prompt_step%%[[:blank:]]*}"
				prompt_step="${prompt_step#*[[:blank:]]}"
				args="${prompt_step}"
				if [ "$prompt_name" = "prompt" ]; then
					__promptor_prompt_actions=($__promptor_prompt_actions "
						builtin set -- '$bg' '$fg' $'$prefix$args'
					")
				else
					__promptor_rprompt_actions=($__promptor_rprompt_actions "
						builtin set -- '$bg' '$fg' $'$prefix$args'
					")
				fi
			elif [[ "$prompt_step" =~ '^\s*\{\{[_[:alnum:]]+.*\}\}\s*$' ]]; then
				prefix="${prompt_step%%\{\{*}"
				suffix="${prompt_step:$((${#prefix}+2))}"
				function_args="${suffix%%[[:blank:]]*}"
				function_args="${suffix%%\}\}*}"
				function_name="${function_args%%[[:blank:]]*}"
				suffix="${suffix##*\}\}}"
				# check if worker exists
				if builtin typeset -f "__promptor_worker_$function_name" > /dev/null; then
					# prepare to launch worker with prompt argument
					if [ "$prompt_name" = "prompt" ]; then
						__promptor_prompt_workers=($__promptor_prompt_workers "__promptor_worker_$function_args")
					else
						__promptor_rprompt_workers=($__promptor_rprompt_workers "__promptor_worker_$function_args")
					fi
				fi
				# check if function exist
				if builtin typeset -f "__promptor_function_$function_name" > /dev/null; then
					if [ "$prompt_name" = "prompt" ]; then
						__promptor_prompt_actions=($__promptor_prompt_actions "
							builtin set -- \$(__promptor_function_$function_args)
							[ \$# -gt 2 ] && builtin set -- \"\$1\" \"\$2\" \"$prefix\${@:3}$suffix\"
						")
					else
						__promptor_rprompt_actions=($__promptor_rprompt_actions "
							builtin set -- \$(__promptor_function_$function_args)
							[ \$# -gt 2 ] && builtin set -- \"\$1\" \"\$2\" \"$prefix\${@:3}$suffix\"
						")
					fi
				elif builtin typeset -f "$function_name" > /dev/null || builtin command -v "$function_name" > /dev/null; then
					if [ "$prompt_name" = "prompt" ]; then
						__promptor_prompt_actions=($__promptor_prompt_actions "
							builtin set -- \"$prefix\$($function_args)$suffix\"
						")
					else
						__promptor_rprompt_actions=($__promptor_rprompt_actions "
							builtin set -- \"$prefix\$($function_args)$suffix\"
						")
					fi
				else
					if [ "$prompt_name" = "prompt" ]; then
						__promptor_prompt_actions=($__promptor_prompt_actions "
							builtin set -- $'${prompt_step}'
						")
					else
						__promptor_rprompt_actions=($__promptor_rprompt_actions "
							builtin set -- $'${prompt_step}'
						")
					fi
				fi
			elif [[ "$prompt_step" =~ '^\[.*\]$' ]]; then
				glyph_name="${prompt_step:1:-1}"
				if [ "${__promptor_glyph[$glyph_name]+abracadabra}" ]; then
					prompt_step="[\u${__promptor_glyph[$glyph_name]}]"
				fi
				if [ "$prompt_name" = "prompt" ]; then
					__promptor_prompt_actions=($__promptor_prompt_actions "
						builtin set -- $'${prompt_step}'
					")
				else
					__promptor_rprompt_actions=($__promptor_rprompt_actions "
						builtin set -- $'${prompt_step}'
					")
				fi
			else
				if [ "$prompt_name" = "prompt" ]; then
					__promptor_prompt_actions=($__promptor_prompt_actions "
						builtin set -- $'${prompt_step}'
					")
				else
					__promptor_rprompt_actions=($__promptor_rprompt_actions "
						builtin set -- $'${prompt_step}'
					")
				fi
			fi
		done
	}
	__promptor_parse_prompt "prompt"
	__promptor_parse_prompt "rprompt"
}