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
readonly __PROMPTOR_FUNCS_DIR="${0:a:h}/functions"
readonly __PROMPTOR_PATH="${0:a}"

# ------------------------------------------------------------------------------
# LIBRARIES

# async
if (( ! ${+functions[async_init]} )); then
	# shellcheck source=./lib/async.zsh
	builtin source "${0:A:h}/lib/async.zsh" && async_init
fi

builtin autoload -Uz add-zsh-hook
builtin autoload -Uz is-at-least

# ------------------------------------------------------------------------------
# SOURCE

# shellcheck source=./src/configuration.zsh
builtin source "${0:A:h}/src/configuration.zsh"
# shellcheck source=./src/compile.zsh
builtin source "${0:A:h}/src/compile.zsh"
# shellcheck source=./src/prints.zsh
builtin source "${0:A:h}/src/prints.zsh"
# shellcheck source=./src/colors.zsh
builtin source "${0:A:h}/src/colors.zsh"
# shellcheck source=./src/glyphs.zsh
builtin source "${0:A:h}/src/glyphs.zsh"
# shellcheck source=./src/widgets.zsh
builtin source "${0:A:h}/src/widgets.zsh"
# shellcheck source=./src/worker.zsh
builtin source "${0:A:h}/src/worker.zsh"
# shellcheck source=./src/functions.zsh
builtin source "${0:A:h}/src/functions.zsh"

# ------------------------------------------------------------------------------
# RELOAD

promptor_reload() {
	builtin echo "Reload $__PROMPTOR_CONFIG_PATH"
	__promptor_load_config_file
	builtin source "$__PROMPTOR_PATH"
}

# ------------------------------------------------------------------------------
# HOOK

# pre exec command event
__promptor_preexec() {
	__promptor_print_title "$@"
}

# pre command event
__promptor_precmd() {
	typeset -g __promptor_last_exit_code=$?
	__promptor_launch_workers
	__promptor_print_prompts
}

# create config if not exist
if [ ! -f "$__PROMPTOR_CONFIG_PATH" ]; then
	"touch" "$__PROMPTOR_CONFIG_PATH"
fi
# create function directory if not exists
if [ ! -d "$__PROMPTOR_FUNCS_DIR" ]; then
	"mkdir" -p "$__PROMPTOR_FUNCS_DIR"
fi

__promptor_bind_widgets
__promptor_load_functions
__promptor_load_config_file
__promptor_create_config_functions
__promptor_update_config_file
__promptor_precompile_prompts

add-zsh-hook precmd __promptor_precmd
add-zsh-hook preexec __promptor_preexec