#
# Promptor/widgets
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

__promptor_call_widget() {
	if builtin zle "$@"; then
		# reset callback
		builtin local __promptor_prompt
		builtin local worker
		builtin local worker_name
		__promptor_prompt="prompt"
		for worker in "${__promptor_prompt_workers[@]}"; do
			worker_name="${worker%% *}_${__promptor_prompt}"
			async_stop_worker "$worker_name" 2> /dev/null
			async_start_worker "$worker_name" -n
		done
		__promptor_prompt="rprompt"
		for worker in "${__promptor_rprompt_workers[@]}"; do
			worker_name="${worker%% *}_${__promptor_prompt}"
			async_stop_worker "$worker_name" 2> /dev/null
			async_start_worker "$worker_name" -n
		done
	fi
}

__promptor_bind_widgets() {
	setopt localoptions noksharrays
	typeset -F SECONDS
	local prefix=promptor-s$SECONDS-r$RANDOM # unique each time, in case we're sourced more than once

	if ! zmodload zsh/zleparameter 2>/dev/null; then
		print -r -- >&2 'Promptor: failed loading zsh/zleparameter.'
		return 1
	fi

	local -U widgets_to_bind

	widgets_to_bind+=(self-insert)

	local cur_widget
	for cur_widget in $widgets_to_bind; do
		case ${widgets[$cur_widget]:-""} in
			# Already rebound event: do nothing.
			user:__promptor_*);;

			# User defined widget: override and rebind old one with prefix "promptor-".
			user:*) zle -N $prefix-$cur_widget ${widgets[$cur_widget]#*:}
					eval "__promptor_${(q)prefix}-${(q)cur_widget}() { __promptor_call_widget ${(q)prefix}-${(q)cur_widget} -- \"\$@\" }"
					zle -N $cur_widget __promptor_$prefix-$cur_widget;;
		esac
	done
}