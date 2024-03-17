#! /bin/bash

# Script: x86_toolchain.sh
# Author: Lubos Kuzma
#Modified By Kirk
# Description: This script compiles and runs x86 assembly code using NASM and GNU tools.
# Version: 1.0
# Date: August 2022

# Check if no arguments are provided
if [ $# -lt 1 ]; then
    echo "Usage:"
    echo ""
    echo "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"
    echo ""
    echo "-v | --verbose                Show some information about steps performed."
    echo "-dis | --disable                    Disable GDB on boot"
    echo "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."
    echo "-r | --run                    Run program in gdb automatically. Same as run command inside gdb env."
    echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."
    echo "-32| --x86-32                 Compile for 32bit (x86-32) system."
    echo "-o | --output <filename>      Output filename."

    exit 1
fi

# Initialize variables
POSITIONAL_ARGS=()
GDB=True  # Auto runs GDB
OUTPUT_FILE=""
VERBOSE=False
BITS=True
QEMU=False
BREAK="_start"
RUN=False

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case $1 in
        -dis|--disable) # disable gdb
            GDB=False
            shift # past argument
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift # past argument
            shift # past value
            ;;
        -v|--verbose)
            VERBOSE=True
            shift # past argument
            ;;
        -32|--x84-32)
            BITS=False
            shift # past argument
            ;;
        -q|--qemu)
            QEMU=True
            shift # past argument
            ;;
        -r|--run)
            RUN=True
            shift # past argument
            ;;
        -b|--break)
            BREAK="$2"
            shift # past argument
            shift # past value
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done

# Restore positional parameters
set -- "${POSITIONAL_ARGS[@]}"

# Check if input file exists
if [[ ! -f $1 ]]; then
    echo "Specified file does not exist"
    exit 1
fi

# Set output file name if not provided
if [ "$OUTPUT_FILE" == "" ]; then
    OUTPUT_FILE=${1%.*}
fi

# Print verbose information
if [ "$VERBOSE" == "True" ]; then
    echo "Arguments being set:"
    echo "    GDB = ${GDB}"
    echo "    RUN = ${RUN}"
    echo "    BREAK = ${BREAK}"
    echo "    QEMU = ${QEMU}"
    echo "    Input File = $1"
    echo "    Output File = $OUTPUT_FILE"
    echo "    Verbose = $VERBOSE"
    echo "    64 bit mode = $BITS" 
    echo ""

    echo "NASM started..."
fi

# Compile assembly code
if [ "$BITS" == "True" ]; then
    nasm -f elf64 $1 -o $OUTPUT_FILE.o && echo ""
elif [ "$BITS" == "False" ]; then
    nasm -f elf $1 -o $OUTPUT_FILE.o && echo ""
fi

# Print verbose information
if [ "$VERBOSE" == "True" ]; then
    echo "NASM finished"
    echo "Linking ..."
fi

# Link object file
if [ "$BITS" == "True" ]; then
    ld -m elf_x86_64 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""
elif [ "$BITS" == "False" ]; then
    ld -m elf_i386 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""
fi

# Print verbose information
if [ "$VERBOSE" == "True" ]; then
    echo "Linking finished"
fi

# Run executable in QEMU if requested
if [ "$QEMU" == "True" ]; then
    echo "Starting QEMU ..."
    echo ""

    if [ "$BITS" == "True" ]; then
        qemu-x86_64 $OUTPUT_FILE && echo ""
    elif [ "$BITS" == "False" ]; then
        qemu-i386 $OUTPUT_FILE && echo ""
    fi

    exit 0
fi

# Run GDB on executable if requested
if [ "$GDB" == "True" ]; then
    gdb_params=()
    gdb_params+=(-ex "b ${BREAK}")

    if [ "$RUN" == "True" ]; then
        gdb_params+=(-ex "r")
    fi

    gdb "${gdb_params[@]}" $OUTPUT_FILE
fi
