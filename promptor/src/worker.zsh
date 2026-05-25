#
# Promptor/worker
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

promptor_create_worker_callback() {
	builtin local function_name="$1"
	builtin local callback="${2:-}"

	if [ -z "$callback" ]; then
		callback="__promptor_worker_${function_name}_callback_default"
		builtin eval "
			$callback() {
				promptor_reload_prompt_from_function \"${function_name}\" \"\$@\"
			}
		"
	fi

	# create function of worker (filter out async internal errors like '[async]')
	builtin eval "
		__promptor_worker_${function_name}_callback_${__promptor_prompt}() {
			[[ \"\$1\" == '[async]' ]] && return
			${callback} \"\$3\"
		}
	"
}

# wrapper run inside the worker: sync PWD then invoke the real function
__promptor_async_run() {
	builtin cd -q -- "$1" 2> /dev/null
	shift
	"$@"
}

promptor_launch_worker_job() {
	builtin local function_name="$1"
	builtin local function_job="$2"

	builtin local worker_name="__promptor_worker_${function_name}_${__promptor_prompt}"

	# start worker once (idempotent), -u skips queued duplicates while one is running
	async_start_worker "$worker_name" -n -u
	async_register_callback "$worker_name" "__promptor_worker_${function_name}_callback_${__promptor_prompt}"
	# pass current PWD so the worker chdir before calling the function
	async_job "$worker_name" __promptor_async_run "$PWD" "$function_job" "${@:3}"
}

promptor_reload_prompt_from_function() {
	builtin local function_name="$1"

	# store answer in global to avoid eval injection with special characters
	builtin typeset -g "__promptor_reload_cache_${function_name}"
	builtin eval "__promptor_reload_cache_${function_name}=\$2"

	# create temporary replace function referencing the global cache
	builtin eval "
		__promptor_function_${function_name}() {
			echo \"\${__promptor_reload_cache_${function_name}}\"
		}
	"

	# set new prompt with temporary function
	__promptor_print_prompts

	# reset
	zle && zle ".reset-prompt"
}

__promptor_launch_workers() {
	builtin typeset -g __promptor_prompt_workers
	builtin typeset -g __promptor_rprompt_workers

	builtin local function_name
	builtin local function_content
	for function_name in $(builtin typeset +mf "__promptor_function_*_default"); do
		# replace by default function
		if is-at-least 5.8; then
			functions -c "$function_name" "${function_name%_default}"
		else
			function_content="$(builtin type -f "$function_name")"
			builtin eval "${function_name%_default}${function_content:${#function_name}}"
		fi
	done
	builtin local __promptor_prompt
	builtin local worker
	__promptor_prompt="prompt"
	for worker in "${__promptor_prompt_workers[@]}"; do
		builtin eval "$worker"
	done
	__promptor_prompt="rprompt"
	for worker in "${__promptor_rprompt_workers[@]}"; do
		builtin eval "$worker"
	done
}