#!/usr/bin/env bash
#
# copyright (c) 2013 by Roderick W. Smith
#
# This program is licensed under the terms of the GNU GPL, version 3,
# or (at your option) any later version.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Program to generate a PNG file suitable for use as a rEFInd font
# To obtain a list of available font names, type:
#
# convert -list font | less
#
# The font used MUST be a monospaced font; searching for the string
# "Mono" will turn up most suitable candidates.
#
# Usage:
# ./mkfont.sh font-name font-size font-Y-offset bitmap-filename.png
#
# This script is part of the rEFInd package. Version numbers refer to
# the rEFInd version with which the script was released.
#
# Version history:
#
#  0.6.6  -  Initial release
#  0.13.2 -  Add getopt parsing from munlik's refind-regular theme, remove
#            y-offset option and add color option.

CONVERT="$(command -v convert 2> /dev/null)"

FONT_NAME=""
FONT_SIZE=""

function print_help() {
    echo "Generate a PNG file suitable for use as a rEFInd font"
    echo "Usage:"
    echo "$0 [[-f|--font] <font_name>] [[-s|--size] <number>] <outfile.png>"
    echo "or"
    echo "$0 [options]... <outfile.png>"
    echo ""
    echo "Options:"
    echo "-f,--font: <font_name>              Name of font"
    echo "-s,--size: <number>                 Font size in points"
    echo "-c,--color: <color>                 Imagemagick color, see https://imagemagick.org/script/color.php"
    echo ""
    echo ""
    echo "-l,--list-font                      Display fonts list and exit"
    echo "-h,--help                           Display this help message and exit"
    echo ""
    exit 1
}

if [ $# -ne 0 ]
then
    ARGS="$(getopt -a -o hlf:s:c: -l help,list-font,font,color:,size: -n "$0" -- "$@")"
    eval set -- "$ARGS"

    while [ $# -gt 0 ]
    do
        case "$1" in
            -h|--help)
                print_help
                exit 1
                ;;
            -l|--list-font)
                "$CONVERT" -list font
                exit 1
                ;;
            -f|--font)
                FONT_NAME="$2"
                shift 2
                ;;
            -s|--size)
                FONT_SIZE="$2"
                shift 2
                ;;
            -c|--color)
                FONT_COLOR="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
        esac
    done
else
    echo "Try \`$0 --help' for more information." 1>&2
    exit 1
fi

# font-name
if ! [ "$FONT_NAME" ]
then
    echo "$0 --font must be specified." 1>&2
    exit 1
fi

# font-size
if ! [ "$FONT_SIZE" ]
then
    echo "$0 --size must be specified." 1>&2
    exit 1
elif [[ "$FONT_SIZE" =~ ^-?[0-9]+([.][0-9]+)?$ ]]
then
    FONT_SIZE="${${FONT_SIZE#-}%.*}" # Remove leading - and truncate
else
    echo "$0 --size \`$FONT_SIZE' wrong numerical." 1>&2
    exit 1
fi

# color default=black
if ! [ "$FONT_COLOR" ]
then
    FONT_COLOR='black'
fi

# output_file
if [ $# -gt 0 ] && [ "${OUTPUT_PNG%.png}" = "$OUTPUT_PNG" ]
then
    OUTPUT_PNG="$1"
    shift $#
else
    echo "$0 Output file must be specified and a PNG image." 1>&2
    exit 1
fi

CEllWIDTH=$(( (FONT_SIZE * 6 + 5) / 10 ))
WIDTH=$(( CEllWIDTH * 96 ))
HEIGHT=$(( (150 * FONT_SIZE) / 100 ))

echo "Creating ${WIDTH}x${HEIGHT} font bitmap...."
"$CONVERT" -size "${WIDTH}x${HEIGHT}" xc:transparent \
-gravity SouthWest \
-font "$FONT_NAME" \
-fill "$FONT_COLOR" \
-pointsize "$FONT_SIZE" \
-draw "text 0,0 ' !\"#\$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_\`abcdefghijklmnopqrstuvwxyz{|}~?'" \
"$OUTPUT_PNG"
