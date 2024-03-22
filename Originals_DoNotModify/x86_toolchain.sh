#! /bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022

# This script compiles and links assembly code using GCC for x86-64 architecture.

# Function to display usage information
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

	exit 1
fi
# Initialize variables with default values
POSITIONAL_ARGS=()
GDB=False
OUTPUT_FILE=""
VERBOSE=False
BITS=True # Default to 64-bit
QEMU=False
BREAK="_start"
RUN=False

# Parse command line options
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
          	  	BITS=true
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

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# Check if source file is provided
if [ $# -lt 1 ]; then
	echo "Error: Source filename is missing!"
 	usage
fi

# Check if source file exists
if [[ ! -f $1 ]]; then
	echo "Error: Specified file '$1' does not exist"
	exit 1
fi

# Set output file if not provided
if [ "$OUTPUT_FILE" == "" ]; then
	OUTPUT_FILE=${1%.*}
fi

# Display verbose information if enabled
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

	echo "GCC started..."

fi

# Function for compilation
compile_source() {
	local SOURCE_FILE="$1"
 	local OUTPUT_FILE="$2"

# Compile source file with GCC for x86_64 architecture
if [ "$BITS" == "True" ]; then
 
  	gcc -m64 -o "$OUTPUT_FILE" "$1" && echo ""

elif [ "$BITS" == "False" ]; then
	# Link object file for x86_64 architecture
  	gcc -o "$OUTPUT_FILE" "$1" && echo ""
   
fi
}

# Display verbose information if enabled
if [ "$VERBOSE" == "True" ]; then

	echo "GCC finished"
	echo "Linking ..."
	
fi

# Function for linking
link_object() {
	local OBJECT_FILE="$1"
 	local OUTPUT_FILE="$2"

if [ "$BITS" == "True" ]; then

	ld -m elf_x86_64 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""


elif [ "$BITS" == "False" ]; then

	ld -m elf_i386 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""

fi
}

if [ "$VERBOSE" == "True" ]; then

	echo "Linking finished"

fi

# Main function
parse_arguments "$@"
SOURCE_FILE="$1"
OUTPUT_FILE="$OUTPUT_FILE"

compile_source "$SOURCE_FILE" "$OUTPUT_FILE"
link_object "$OUTPUT_FILE" "$OUTPUT_FILE"

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

# Run GDB if requested
if [ "$GDB" == "True" ]; then

	gdb_params=()
	gdb_params+=(-ex "b ${BREAK}")

	if [ "$RUN" == "True" ]; then

		gdb_params+=(-ex "r")

	fi

	gdb "${gdb_params[@]}" $OUTPUT_FILE

fi

# Invoke main function with command line arguments
main "$@"
