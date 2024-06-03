#
# Promptor/colors
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

promptor_colors() {
	builtin local i j k l
	builtin local color
	builtin local str=""

	for i in {0..15}; do
		str+=$'\033[48;5;'$i$'m'
		[ $((i%8)) -eq 0 ] && str+=$'\033[38;5;231m' || str+=$'\033[38;5;232m'
		[ $i -lt 10 ] && str+="  " || str+=" "
		str+="$i"
		str+=$'\033[0m '
		[ $i -eq 7 ] && str+="\n"
	done
	str+="\n\n"
	for i in {0..1}; do
		for j in {0..5}; do
			for k in {0..2}; do
				for l in {0..5}; do
					color=$((j*6+k*36+l+i*108+16))
					str+=$'\033[48;5;'$color$'m'
					[ $((((color-16)%36)/6)) -gt 2 ] && str+=$'\033[38;5;232m' || str+=$'\033[38;5;231m'
					[ $color -lt 100 ] && str+=" "
					str+="$color"
					str+=$'\033[0m '
				done
				[ $k -lt 2 ] && str+="  "
			done
			str+="\n"
		done
	done
	str+="\n"
	for i in {232..255}; do
		str+=$'\033[48;5;'$i$'m'
		[ $i -gt 243 ] && str+=$'\033[38;5;232m' || str+=$'\033[38;5;231m'
		str+="$i"
		str+=$'\033[0m '
		[ $i -eq 243 ] && str+="\n"
	done
	builtin echo -e "$str"
}