#
# Promptor/functions
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

__promptor_load_functions() {
	builtin local function_file
	builtin local function_name
	builtin local content
	builtin local worker_name
	# load functions
	for function_file in "$__PROMPTOR_FUNCS_DIR/"*; do
		# source function file
		builtin source "$function_file"
	done
	# rename function to private
	for function_name in $(builtin typeset +mf "promptor_function_*"); do
		if is-at-least 5.8; then
			functions -c "$function_name" "__$function_name"
		else
			content="$(builtin type -f "$function_name")"
			builtin eval "__$function_name${content:${#function_name}}"
		fi
		unfunction $function_name
	done
	# rename worker to private
	for worker_name in $(builtin typeset +mf "promptor_worker_*"); do
		if is-at-least 5.8; then
			functions -c "$worker_name" "__$worker_name"
		else
			content="$(builtin type -f "$worker_name")"
			builtin eval "__$worker_name${content:${#worker_name}}"
		fi
		unfunction $worker_name
		function_name="__promptor_function_${worker_name#promptor_worker_}"
		# if function exists with worker
		if builtin typeset -f "$function_name" > /dev/null; then
			if is-at-least 5.8; then
				functions -c "$function_name" "${function_name}_default"
			else
				content="$(builtin type -f "$function_name")"
				builtin eval "${function_name}_default${content:${#function_name}}"
			fi
		else
			# create empty function
			builtin eval "
				${function_name}(){}
				${function_name}_default(){}
			"
		fi
	done
}