#
# Promptor/configuration
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

builtin declare -A promptor_config

# default configuration
promptor_config[powerline]=true
promptor_config[prompt]='[left_half_circle_thick]237 231 %~ [left_hard_divider] {{unwritten}} [left_hard_divider] {{exit_code}} [left_hard_divider]'
promptor_config[rprompt]='[right_hard_divider] {{git_async}} [right_hard_divider] 25 231 %n@%m [right_hard_divider] 237 231 %D{%H:%M}[right_half_circle_thick]'
promptor_config[title.command.max_size]=100
promptor_config[title]='%n: %~'

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
	builtin local line key value
	builtin eval "
		config_array=(
			$(<"$__PROMPTOR_CONFIG_PATH")
		)
	"
	for line in "${config_array[@]}"; do
		key="${line%%=*}"
		value="${line:$((${#key}+1))}"
		promptor_config[$key]="$value"
	done
}

__promptor_update_config_file() {
	builtin local content=""
	# create default key if not exists
	for key in "${(@k)promptor_config}"; do
		if ! [[ "$key" =~ "default."* ]] && ! [ "${promptor_config[default.$key]+abracadabra}" ]; then
			promptor_config[default.$key]="${promptor_config[$key]}"
		fi
	done
	content+="# You can edit this file!\n"
	content+="# Execute 'promptor_reload' for take your change(s)\n"
	content+="\n"
	content+="# ----------------------------------------\n"
	content+="# VALUES\n"
	content+="# ----------------------------------------\n"
	for key in "${(@ko)promptor_config}"; do
		if ! [[ "$key" =~ "default."* ]]; then
			content+="$key='${promptor_config[${key}]//\\/\\\\}'\n"
		fi
	done
	content+="# ----------------------------------------\n"
	content+="# DEFAULTS\n"
	content+="# ----------------------------------------\n"
	for key in "${(@ko)promptor_config}"; do
		if [[ "$key" =~ "default."* ]]; then
			content+="$key='${promptor_config[${key}]//\\/\\\\}'\n"
		fi
	done
	builtin echo -e "$content" > "$__PROMPTOR_CONFIG_PATH"
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
					__promptor_precompile_prompts
				}
			"
		fi
	done
}