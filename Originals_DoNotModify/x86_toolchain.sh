#!/bin/bash

# Created by Sujal Vyas 
# ISS Program, SADT, SAIT
# March 2024

usage() {
    cat <<EOF
Usage: $0 [options] <assembly filename> [-o | --output <output filename>]

Options:
  -v, --verbose                  Show some information about steps performed.
  -g, --gdb                      Run gdb command on executable.
  -b, --break <break point>      Add breakpoint after running gdb. Default is _start.
  -r, --run                      Run program in gdb automatically. Same as run command inside gdb env.
  -q, --qemu                     Run executable in QEMU emulator. This will execute the program.
  -64, --x86-64                  Compile for 64bit (x86-64) system.
  -o, --output <filename>        Output filename.
EOF
    exit 1
}

POSITIONAL_ARGS=()
GDB=false
OUTPUT_FILE=""
VERBOSE=false
BITS=false
QEMU=false
BREAK="_start"
RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--gdb)
            GDB=true
            shift
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -64|--x86-64)
            BITS=true
            shift
            ;;
        -q|--qemu)
            QEMU=true
            shift
            ;;
        -r|--run)
            RUN=true
            shift
            ;;
        -b|--break)
            BREAK="$2"
            shift 2
            ;;
        -*|--*)
            echo "Unknown option $1"
            usage
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}"

if [ $# -lt 1 ]; then
    usage
fi

if [[ ! -f $1 ]]; then
    echo "Specified file does not exist"
    exit 1
fi

if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="${1%.*}"
fi

if [ "$VERBOSE" = true ]; then
    echo "Arguments being set:"
    echo "    GDB = $GDB"
    echo "    RUN = $RUN"
    echo "    BREAK = $BREAK"
    echo "    QEMU = $QEMU"
    echo "    Input File = $1"
    echo "    Output File = $OUTPUT_FILE"
    echo "    Verbose = $VERBOSE"
    echo "    64 bit mode = $BITS"
    echo ""
    echo "NASM started..."
fi

if [ "$BITS" = true ]; then
    nasm -f elf64 "$1" -o "$OUTPUT_FILE.o" && echo ""
else
    nasm -f elf "$1" -o "$OUTPUT_FILE.o" && echo ""
fi

if [ "$VERBOSE" = true ]; then
    echo "NASM finished"
    echo "Linking ..."
fi

if [ "$BITS" = true ]; then
    ld -m elf_x86_64 "$OUTPUT_FILE.o" -o "$OUTPUT_FILE" && echo ""
else
    ld -m elf_i386 "$OUTPUT_FILE.o" -o "$OUTPUT_FILE" && echo ""
fi

if [ "$VERBOSE" = true ]; then
    echo "Linking finished"
fi

if [ "$QEMU" = true ]; then
    echo "Starting QEMU ..."
    echo ""

    if [ "$BITS" = true ]; then
        qemu-x86_64 "$OUTPUT_FILE" && echo ""
    else
        qemu-i386 "$OUTPUT_FILE" && echo ""
    fi

    exit 0
fi

if [ "$GDB" = true ]; then
    gdb_params=()
    gdb_params+=(-ex "b $BREAK")

    if [ "$RUN" = true ]; then
        gdb_params+=(-ex "r")
    fi

    gdb "${gdb_params[@]}" "$OUTPUT_FILE"
fi
