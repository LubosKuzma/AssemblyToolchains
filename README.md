#! /bin/bash

# Usage function for displaying help
usage() {
    echo "Usage: $0 [options] <assembly filename>"
    echo ""
    echo "Options:"
    echo "  -v                       Verbose output."
    echo "  -g                       Run gdb command on executable."
    echo "  -b <break point>         Add breakpoint after running gdb. Default is _start."
    echo "  -r                       Run program in gdb automatically."
    echo "  -q                       Run executable in QEMU emulator."
    echo "  -o <output filename>     Specify the output filename."
    echo ""
    echo "By default, the script compiles for a 64-bit (x86-64) system."
    exit 1
}

# Default values
GDB=false
OUTPUT_FILE=""
VERBOSE=false
BREAK="_start"
RUN=false
QEMU=false

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    usage
fi

# Argument parsing
while getopts ":vgb:ro:q" opt; do
  case $opt in
    v) VERBOSE=true ;;
    g) GDB=true ;;
    b) BREAK="$OPTARG" ;;
    r) RUN=true ;;
    o) OUTPUT_FILE="$OPTARG" ;;
    q) QEMU=true ;;
    \?) echo "Invalid option -$OPTARG" >&2; usage ;;
  esac
done

# Shift off the options and optional --
shift $((OPTIND-1))

# Check for the input assembly file
if [ -z "$1" ]; then
    echo "Error: Assembly filename not provided."
    usage
fi
ASM_FILE="$1"

# Check if the file exists
if [ ! -f "$ASM_FILE" ]; then
    echo "Error: Specified file does not exist."
    exit 1
fi

# If no output file is specified, use the input filename without the extension
if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="${ASM_FILE%.*}"
fi

# Compile the assembly file using GCC (as NASM is being replaced)
gcc -m64 "$ASM_FILE" -o "$OUTPUT_FILE" # default to 64-bit

# Verbose output
if [ "$VERBOSE" == "true" ]; then
    echo "Compilation finished. Output file is $OUTPUT_FILE"
fi

# Running in QEMU emulator if requested
if [ "$QEMU" == "true" ]; then
    qemu-system-x86_64 -drive format=raw,file="$OUTPUT_FILE"
fi

# Running with gdb if requested
if [ "$GDB" == "true" ]; then
    gdb --batch -ex "b $BREAK" "$OUTPUT_FILE"
    if [ "$RUN" == "true" ]; then
        gdb --batch -ex "b $BREAK" -ex "run" "$OUTPUT_FILE"
    fi
fi

