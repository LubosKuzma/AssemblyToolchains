#!/bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022

# Function to display usage information
usage() {
    echo "Usage: $0 [-v] [-g] [-b breakpoint] [-r] [-q] [-64] [-o output_file] <assembly_filename>"
    echo "Options:"
    echo "  -v                Show verbose output."
    echo "  -g                Run the program in GDB."
    echo "  -b breakpoint     Set a breakpoint for GDB (default is _start)."
    echo "  -r                Run the program automatically in GDB (same as 'run' command)."
    echo "  -q                Run the program in QEMU emulator."
    echo "  -64               Compile for 64-bit (x86-64) system."
    echo "  -o output_file    Specify the output filename."
    exit 1
}

# Initialize variables with default values
VERBOSE=false
GDB=false
BREAK="_start"
RUN=false
QEMU=false
BITS=false
OUTPUT_FILE=""

# Parse options
while getopts ":vgb:rq64o:" opt; do
    case $opt in
        v)
            VERBOSE=true
            ;;
        g)
            GDB=true
            ;;
        b)
            BREAK="$OPTARG"
            ;;
        r)
            RUN=true
            ;;
        q)
            QEMU=true
            ;;
        6)
            BITS=true
            ;;
        o)
            OUTPUT_FILE="$OPTARG"
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Check if an assembly filename is provided
if [ $# -lt 1 ]; then
    echo "Error: Assembly filename is required."
    usage
fi

# Assign the assembly filename
ASSEMBLY_FILE="$1"

# If output filename is not provided, use default
if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="${ASSEMBLY_FILE%.*}"
fi

# Display verbose output if enabled
if [ "$VERBOSE" = true ]; then
    echo "Verbose mode enabled."
    echo "Options:"
    echo "  GDB: $GDB"
    echo "  Breakpoint: $BREAK"
    echo "  Run in GDB: $RUN"
    echo "  QEMU: $QEMU"
    echo "  64-bit mode: $BITS"
    echo "  Output file: $OUTPUT_FILE"
    echo "  Assembly file: $ASSEMBLY_FILE"
fi

# Compile the assembly file
if [ "$BITS" = true ]; then
    nasm -f elf64 "$ASSEMBLY_FILE" -o "${OUTPUT_FILE}.o"
else
    nasm -f elf "$ASSEMBLY_FILE" -o "${OUTPUT_FILE}.o"
fi

# Link the object file
if [ "$BITS" = true ]; then
    ld -m elf_x86_64 "${OUTPUT_FILE}.o" -o "$OUTPUT_FILE"
else
    ld -m elf_i386 "${OUTPUT_FILE}.o" -o "$OUTPUT_FILE"
fi

# Run the program in QEMU if specified
if [ "$QEMU" = true ]; then
    if [ "$BITS" = true ]; then
        qemu-x86_64 "$OUTPUT_FILE"
    else
        qemu-i386 "$OUTPUT_FILE"
    fi
    exit 0
fi

# Run the program in GDB if specified
if [ "$GDB" = true ]; then
    gdb_params=()
    gdb_params+=(-ex "b $BREAK")
    if [ "$RUN" = true ]; then
        gdb_params+=(-ex "r")
    fi
    gdb "${gdb_params[@]}" "$OUTPUT_FILE"
fi
