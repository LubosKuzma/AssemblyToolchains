#! /bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022

# Edited by Youssef Awad
# ISS Program, SADT, SAIT
# March 2024

#!/bin/bash
# Shebang line to specify the script should be run with bash

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
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
	
	exit 1  # Exit the script if not enough arguments are provided
fi

POSITIONAL_ARGS=()  # Initialize an empty array for storing positional arguments
GDB=False           # Initialize GDB option as false
OUTPUT_FILE=""      # Initialize output file name as empty
VERBOSE=False       # Initialize verbose option as false
BITS=False          # Initialize BITS as false (default to 32-bit compilation)
QEMU=False          # Initialize QEMU option as false
BREAK="_start"      # Default breakpoint for gdb is set to _start
RUN=False           # Initialize run option for gdb as false

# Process all arguments passed to the script
while [[ $# -gt 0 ]]; do
	case $1 in
		-g|--gdb)
			GDB=True               # Set GDB flag to true
			shift                  # Move past argument
			;;
		-o|--output)
			OUTPUT_FILE="$2"       # Set output file name to the next argument
			shift                  # Move past argument
			shift                  # Move past value
			;;
		-v|--verbose)
			VERBOSE=True           # Set verbose flag to true
			shift                  # Move past argument
			;;
		-64|--x84-64)
			BITS=True              # Set BITS flag to true
			shift                  # Move past argument
			;;
		-q|--qemu)
			QEMU=True              # Set QEMU flag to true
			shift                  # Move past argument
			;;
		-r|--run)
			RUN=True               # Set run flag to true for gdb
			shift                  # Move past argument
			;;
		-b|--break)
			BREAK="$2"             # Set breakpoint to the next argument
			shift                  # Move past argument
			shift                  # Move past value
			;;
		-*|--*)
			echo "Unknown option $1"  # Handle unknown options
			exit 1
			;;
		*)
			POSITIONAL_ARGS+=("$1")  # Save positional argument
			shift                    # Move past argument
			;;
	esac
done

# Restore positional parameters
set -- "${POSITIONAL_ARGS[@]}"

# Check if the input file exists
if [[ ! -f $1 ]]; then
	echo "Specified file does not exist"
	exit 1  # Exit if file doesn't exist
fi

# Set the output file name to the input file name without extension if not provided
if [ "$OUTPUT_FILE" == "" ]; then
	OUTPUT_FILE=${1%.*}
fi

# Display arguments and settings if verbose is enabled
if [ "$VERBOSE" == "True" ]; then
	echo "Arguments being set:"
	echo "	GDB = ${GDB}"
	echo "	RUN = ${RUN}"
	echo "	BREAK = ${BREAK}"
	echo "	QEMU = ${QEMU}"
	echo "	Input File = $1"
	echo "	Output File = $OUTPUT_FILE"
	echo "	Verbose = $VERBOSE"
	echo "	64 bit mode = $BITS" 
	echo ""
	echo "NASM started..."
fi

# Assemble with NASM for 64-bit or 32-bit depending on the BITS flag
if [ "$BITS" == "True" ]; then
	nasm -f elf64 $1 -o $OUTPUT_FILE.o && echo ""
elif [ "$BITS" == "False" ]; then
	nasm -f elf $1 -o $OUTPUT_FILE.o && echo ""
fi

# Linking stage using LD with the appropriate architecture
if [ "$VERBOSE" == "True" ]; then
	echo "NASM finished"
	echo "Linking ..."
fi

# Check if verbose mode is on and display messages accordingly
if [ "$VERBOSE" == "True" ]; then
	echo "NASM finished"  # Inform user that NASM assembly process is complete
	echo "Linking ..."    # Inform user that linking is about to start
fi

# Check if compiling for a 64-bit system
if [ "$BITS" == "True" ]; then
	ld -m elf_x86_64 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""  # Link the object file for a 64-bit system
elif [ "$BITS" == "False" ]; then
	ld -m elf_i386 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""   # Link the object file for a 32-bit system
fi

# Inform user that linking has finished if verbose mode is on
if [ "$VERBOSE" == "True" ]; then
	echo "Linking finished"  # Confirmation message that linking is complete
fi

# Check if QEMU execution is requested
if [ "$QEMU" == "True" ]; then
	echo "Starting QEMU ..."  # Inform user that QEMU will now start
	echo ""

	# Execute the binary with QEMU based on the architecture
	if [ "$BITS" == "True" ]; then
		qemu-x86_64 $OUTPUT_FILE && echo ""  # Execute 64-bit binary in QEMU
	elif [ "$BITS" == "False" ]; then
		qemu-i386 $OUTPUT_FILE && echo ""    # Execute 32-bit binary in QEMU
	fi

	exit 0  # Exit the script after running QEMU
fi

# Check if GDB debugging is requested
if [ "$GDB" == "True" ]; then
	gdb_params=()  # Initialize an empty array for GDB parameters
	gdb_params+=(-ex "b ${BREAK}")  # Add a breakpoint command with the specified break point

	# Check if the program should be run automatically in GDB
	if [ "$RUN" == "True" ]; then
		gdb_params+=(-ex "r")  # Add the run command for GDB
	fi

	# Start GDB with the specified parameters
	gdb "${gdb_params[@]}" $OUTPUT_FILE
fi
