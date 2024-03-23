#! /bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022

# Function to install required dependencies
install_dependencies() {
    echo "Installing required dependencies..."
    # Check if apt-get is available
    if ! [ -x "$(command -v apt-get)" ]; then
        echo "This script requires apt-get for dependency installation, please install dependencies manually."
        exit 1
    fi

    # Install required dependencies
    sudo apt-get update
    sudo apt-get install -y gcc gdb qemu
    if [ $? -eq 0 ]; then
        echo "Dependencies installed successfully."
    else
        echo "Failed to install dependencies. Please install them manually."
        exit 1
    fi
}

# Check if required dependencies are installed
check_dependencies() {
    command -v gcc >/dev/null 2>&1 || { echo >&2 "GCC is required but not installed. Aborting."; exit 1; }
    command -v gdb >/dev/null 2>&1 || { echo >&2 "GDB is required but not installed. Aborting."; exit 1; }
    command -v qemu-system-x86_64 >/dev/null 2>&1 || { echo >&2 "QEMU is required but not installed. Aborting."; exit 1; }
}

# Check and install dependencies if needed
check_dependencies

# Ask user to install dependencies if not available
if [ $? -ne 0 ]; then
    read -p "Do you want to install required dependencies? (Y/N): " choice
    case "$choice" in
        y|Y ) install_dependencies;;
        * ) echo "Aborting."; exit 1;;
    esac
fi

# Display usage information
print_usage() {
    echo "Usage:"
    echo ""
    echo "x86_toolchain.sh [ options ] <source file> [-o | --output <output filename>]"
    echo ""
    echo "Options:"
    echo "-v | --verbose                Show detailed information about steps performed."
    echo "-g | --gdb                    Run gdb command on executable."
    echo "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."
    echo "-r | --run                    Run program in gdb automatically. Same as run command inside gdb env."
    echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."
    echo "-32| --x86-32                 Compile for 32bit (x86) system."
    echo "-o | --output <filename>      Output filename."
    echo ""
    echo "Example:"
    echo "  x86_toolchain.sh -g -b main -r -q -o my_program my_program.c"
}

# Check if no arguments are provided, display usage information
if [ $# -lt 1 ]; then
    print_usage
    exit 1
fi

POSITIONAL_ARGS=()
GDB=False
OUTPUT_FILE=""
VERBOSE=False
BITS="64"
QEMU=False
BREAK="_start"
RUN=False
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--gdb)
            GDB=True
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
        -32|--x86-32)
            BITS="32"
            shift # past argument
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

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [[ ! -f $1 ]]; then
        echo "Specified file does not exist"
        exit 1
fi

if [ "$OUTPUT_FILE" == "" ]; then
    OUTPUT_FILE=${1%.*}
fi

if [ "$VERBOSE" == "True" ]; then
    echo "Arguments being set:"
    echo "    GDB = ${GDB}"
    echo "    RUN = ${RUN}"
    echo "    BREAK = ${BREAK}"
    echo "    QEMU = ${QEMU}"
    echo "    Input File = $1"
    echo "    Output File = $OUTPUT_FILE"
    echo "    Verbose = $VERBOSE"
    echo "    Bit mode = $BITS" 
    echo ""

    echo "Compilation started..."
fi

# Determine compilation type based on file extension
if [[ "$1" == *.s ]]; then
    # Compile assembly code
    if [ "$BITS" == "64" ]; then
        gcc -m64 $1 -o $OUTPUT_FILE
    else
        gcc -m32 $1 -o $OUTPUT_FILE
    fi
elif [[ "$1" == *.c ]]; then
    # Compile C code
    if [ "$BITS" == "64" ]; then
        gcc -m64 $1 -o $OUTPUT_FILE
    else
        gcc -m32 $1 -o $OUTPUT_FILE
    fi
else
    echo "Unsupported file format. Only .s (assembly) or .c (C) files are supported."
    exit 1
fi

# Check compilation status
if [ $? -ne 0 ]; then
    echo "Compilation failed"
    exit 1
fi

# Display verbose information if requested
if [ "$VERBOSE" == "True" ]; then
    echo "Compilation finished"
fi

# Execute the program in QEMU if requested
if [ "$QEMU" == "True" ]; then
    echo "Starting QEMU ..."
    echo ""

    qemu-$([ "$BITS" == "64" ] && echo "x86_64" || echo "i386") $OUTPUT_FILE && echo ""

    exit 0
fi

# Debug the program with GDB if requested
if [ "$GDB" == "True" ]; then
    gdb_params=()
    gdb_params+=(-ex "b ${BREAK}")

    if [ "$RUN" == "True" ]; then
        gdb_params+=(-ex "r")
    fi

    gdb "${gdb_params[@]}" $OUTPUT_FILE
fi
