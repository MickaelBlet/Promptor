#
# Promptor/glyphs
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

declare -A __promptor_glyph
__promptor_glyph[left_hard_divider]='e0b0'
__promptor_glyph[left_soft_divider]='e0b1'
__promptor_glyph[right_hard_divider]='e0b2'
__promptor_glyph[right_soft_divider]='e0b3'
__promptor_glyph[right_half_circle_thick]='e0b4'
__promptor_glyph[right_half_circle_thin]='e0b5'
__promptor_glyph[left_half_circle_thick]='e0b6'
__promptor_glyph[left_half_circle_thin]='e0b7'
__promptor_glyph[lower_left_triangle]='e0b8'
__promptor_glyph[backslash_separator]='e0b9'
__promptor_glyph[lower_right_triangle]='e0ba'
__promptor_glyph[forwardslash_separator]='e0bb'
__promptor_glyph[upper_left_triangle]='e0bc'
__promptor_glyph[forwardslash_separator_redundant]='e0bd'
__promptor_glyph[upper_right_triangle]='e0be'
__promptor_glyph[backslash_separator_redundant]='e0bf'
__promptor_glyph[flame_thick]='e0c0'
__promptor_glyph[flame_thin]='e0c1'
__promptor_glyph[flame_thick_mirrored]='e0c2'
__promptor_glyph[flame_thin_mirrored]='e0c3'
__promptor_glyph[pixelated_squares_small]='e0c4'
__promptor_glyph[pixelated_squares_small_mirrored]='e0c5'
__promptor_glyph[pixelated_squares_big]='e0c6'
__promptor_glyph[pixelated_squares_big_mirrored]='e0c7'
__promptor_glyph[ice_waveform]='e0c8'
__promptor_glyph[ice_waveform_mirrored]='e0ca'
__promptor_glyph[honeycomb]='e0cc'
__promptor_glyph[honeycomb_outline]='e0cd'
__promptor_glyph[lego_separator]='e0ce'
__promptor_glyph[lego_separator_thin]='e0cf'
__promptor_glyph[lego_block_facing]='e0d0'
__promptor_glyph[lego_block_sideways]='e0d1'
__promptor_glyph[trapezoid_top_bottom]='e0d2'
__promptor_glyph[trapezoid_top_bottom_mirrored]='e0d4'
__promptor_glyph[right_hard_divider_inverse]='e0d6'
__promptor_glyph[left_hard_divider_inverse]='e0d7'

promptor_glyphs() {
	builtin local value=""
	builtin local i
	builtin local j
	builtin local key
	builtin local names
	builtin local unicodes
	builtin local max_key_len=0
	builtin local str=""

	names=()
	unicodes=()
	# for in order
	for value in "${(@o)__promptor_glyph}"; do
		key="${(k)__promptor_glyph[(r)${value}]}"
		names=($names "$key")
		unicodes=($unicodes "$value")
		[ "$max_key_len" -lt "${#key}" ] && max_key_len="${#key}"
	done

	# first line
	str+='\u250c'
	for _ in {0..$((max_key_len + 1))}; do
		str+='\u2500'
	done
	str+='\u252c'
	for _ in {0..7}; do
		str+='\u2500'
	done
	str+='\u252c'
	for _ in {0..3}; do
		str+='\u2500'
	done
	str+='\u2510\n'

	# lines
	for i in {1..${#names[@]}}; do
		str+='\u2502'
		str+=" "
		str+="${names[$i]}"
		j="${#names[$i]}"
		for _ in {0..$((max_key_len-j))}; do
			str+=" "
		done
		str+='\u2502'
		str+=" "
		str+="\\\\u${unicodes[$i]}"
		str+=" "
		str+='\u2502'
		str+=" "
		str+="\u${unicodes[$i]}"
		str+=" "
		str+=" "
		str+='\u2502\n'
	done

	# last line
	str+='\u2514'
	for _ in {0..$((max_key_len + 1))}; do
		str+='\u2500'
	done
	str+='\u2534'
	for _ in {0..7}; do
		str+='\u2500'
	done
	str+='\u2534'
	for _ in {0..3}; do
		str+='\u2500'
	done
	str+='\u2518'
	echo -e "$str"
}