#! /bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022

#In this modified version: revision: Ernesto Samandre
#I changed the assembly compiler from NASM to GCC.
#I set the default bit mode to 64-bit.
#Removed the conditional compilation based on bit mode since GCC handles it internally.
#Updated the linker command to use GCC instead of LD.
#Updated the options for 64-bit mode to -m64 for GCC.

# Check if the number of arguments is sufficient
if [ $# -lt 1 ]; then
    # Print usage information
    echo "Usage:"
    echo ""
    echo "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"
    echo ""
    echo "-v | --verbose                Show some information about steps performed."
    echo "-g | --gdb                    Run gdb command on executable."
    echo "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."
    echo "-r | --run                    Run program in gdb automatically. Same as run command inside gdb env."
    echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."
    echo "-64| --x86-64                 Compile for 64bit (x86-64) system."
    echo "-o | --output <filename>      Output filename."

    exit 1
fi

# Define an array to store positional arguments
POSITIONAL_ARGS=()

# Initialize variables
GDB=False
OUTPUT_FILE=""
VERBOSE=False
BITS=True  # Set 64-bit as default
QEMU=False
BREAK="_start"
RUN=False

# Parse command line arguments
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
        -64|--x86-64)
            BITS=True  # Set 64-bit mode
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

# Check if the input file exists
if [[ ! -f $1 ]]; then
    echo "Specified file does not exist"
    exit 1
fi

# Set the output file if not provided
if [ "$OUTPUT_FILE" == "" ]; then
    OUTPUT_FILE=${1%.*}
fi

# Check if verbose mode is enabled
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

    echo "GCC started..."
fi

# Compile the assembly code with GCC
if [ "$BITS" == "True" ]; then
    gcc -m64 $1 -o $OUTPUT_FILE && echo ""  # Use -m64 flag for 64-bit mode
else
    gcc $1 -o $OUTPUT_FILE && echo ""
fi

# Check if verbose mode is enabled
if [ "$VERBOSE" == "True" ]; then
    echo "GCC finished"
    echo "Linking ..."
fi

# Link the object file (handled by GCC) based on bit mode
if [ "$BITS" == "True" ]; then
    ld -m elf_x86_64 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""  # No need for separate LD command, GCC handles linking
else
    ld -m elf_i386 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""
fi

# Check if verbose mode is enabled
if [ "$VERBOSE" == "True" ]; then
    echo "Linking finished"
fi
