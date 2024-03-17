#!/bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022

# Usage information - x86
display_usage() {
    echo "Usage:"
    echo ""
    echo "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"
    echo ""
    echo "Options:"
    echo "-v | --verbose                Show detailed information about steps performed."
    echo "-g | --gdb                    Run GDB (GNU Debugger) command on executable."
    echo "-b | --break <break point>    Add breakpoint after running GDB. Default is _start."
    echo "-r | --run                    Run the program in GDB automatically. Same as 'run' command inside GDB env."
    echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."
    echo "-64| --x86-64                 Compile for 64-bit (x86-64) system. Default is 64-bit."
    echo "-o | --output <filename>      Output filename."

    exit 1
}

# Default values
GDB=false
OUTPUT_FILE=""
VERBOSE=false
BITS=true  # Default is 64-bit
QEMU=false
BREAK="_start"
RUN=false

# Parse command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--gdb)                   # Enable GDB mode
            GDB=true
            shift
            ;;
        -o|--output)                # Set output filename
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -v|--verbose)               # Enable verbose mode
            VERBOSE=true
            shift
            ;;
        -64|--x86-64)               # Compile for 64-bit system
            BITS=true
            shift
            ;;
        -q|--qemu)                  # Run in QEMU emulator
            QEMU=true
            shift
            ;;
        -r|--run)                   # Run program automatically in GDB
            RUN=true
            shift
            ;;
        -b|--break)                 # Set breakpoint for GDB
            BREAK="$2"
            shift 2
            ;;
        -*|--*)                     # Unknown options
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift
            ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# Check if input file exists
if [[ ! -f $1 ]]; then
    echo "Specified file does not exist"
    exit 1
fi

# Set output file name if not provided
if [ "$OUTPUT_FILE" == "" ]; then
    OUTPUT_FILE="${1%.*}"  # Default output filename
fi

# Display verbose information if enabled
if [ "$VERBOSE" == "true" ]; then
    echo "Arguments being set:"  # x86
    echo "    GDB = ${GDB}"
    echo "    RUN = ${RUN}"
    echo "    BREAK = ${BREAK}"
    echo "    QEMU = ${QEMU}"
    echo "    Input File = $1"
    echo "    Output File = $OUTPUT_FILE"
    echo "    Verbose = $VERBOSE"
    echo "    64-bit mode = $BITS" 
    echo ""

    echo "GCC assembling and linking started..."  # x86
fi

# Compile and link assembly code using GCC
if [ "$BITS" == "true" ]; then
    gcc -m64 $1 -o "$OUTPUT_FILE" && echo ""  # x86
else
    gcc -m32 $1 -o "$OUTPUT_FILE" && echo ""  # x86
fi

# Display verbose information if enabled
if [ "$VERBOSE" == "true" ]; then
    echo "GCC assembling and linking finished"  # x86
fi

# Execute in QEMU if enabled
if [ "$QEMU" == "true" ]; then
    echo "Starting QEMU ..."  # x86
    echo ""

    if [ "$BITS" == "true" ]; then
        qemu-x86_64 "$OUTPUT_FILE" && echo ""  # x86
    else
        qemu-i386 "$OUTPUT_FILE" && echo ""  # x86
    fi

    exit 0
fi

# Execute in GDB if enabled
if [ "$GDB" == "true" ]; then
    gdb_params=()
    gdb_params+=(-ex "b ${BREAK}")

    if [ "$RUN" == "true" ]; then
        gdb_params+=(-ex "r")
    fi

    gdb "${gdb_params[@]}" "$OUTPUT_FILE"
fi
