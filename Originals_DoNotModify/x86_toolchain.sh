#!/bin/bash

# Created by Jasmeen Kaur
# ISS Program, SADT, SAIT
# March 2024

if [ $# -lt 1 ]; then
	echo "Usage:"
	echo ""
	echo "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"
	echo ""
	echo "-v | --verbose                Display detailed information about the process."
	echo "-g | --gdb                    Run gdb command on the executable."
	echo "-b | --break <break point>    Specify a breakpoint after running gdb. Default is _start."
	echo "-r | --run                    Automatically run the program in gdb. Same as 'run' command inside gdb environment."
	echo "-q | --qemu                   Execute the program in QEMU emulator."
	echo "-32 | --x86-32                Compile for a 32-bit (x86) system."
	echo "-o | --output <filename>      Specify the output filename."

	exit 1
fi

POSITIONAL_ARGS=()
GDB=False
OUTPUT_FILE=""
VERBOSE=False
BITS=True  # 64-bit as default
QEMU=False
BREAK="_start"
RUN=False

while [[ $# -gt 0 ]]; do
	case $1 in
		-g|--gdb)
			GDB=True
			shift # move to the next argument
			;;
		-o|--output)
			OUTPUT_FILE="$2"
			shift # move to the next argument
			;;
		-v|--verbose)
			VERBOSE=True
			shift # move to the next argument
			;;
		-32|--x86-32)
			BITS=False
			shift # move to the next argument
			;;
		-q|--qemu)
			QEMU=True
			shift # move to the next argument
			;;
		-r|--run)
			RUN=True
			shift # move to the next argument
			;;
		-b|--break)
			BREAK="$2"
			shift # move to the next argument
			;;
		-*|--*)
			echo "Unknown option $1"
			exit 1
			;;
		*)
			POSITIONAL_ARGS+=("$1") # save positional argument
			shift # move to the next argument
			;;
	esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [[ ! -f $1 ]]; then
	echo "The specified file does not exist."
	exit 1
fi

if [ "$OUTPUT_FILE" == "" ]; then
	OUTPUT_FILE=${1%.*}
fi

if [ "$VERBOSE" == "True" ]; then
	echo "Options being set:"
	echo "	GDB = ${GDB}"
	echo "	RUN = ${RUN}"
	echo "	BREAK = ${BREAK}"
	echo "	QEMU = ${QEMU}"
	echo "	Input File = $1"
	echo "	Output File = $OUTPUT_FILE"
	echo "	Verbose = $VERBOSE"
	echo "	64-bit mode = $BITS" 
	echo ""

	echo "GCC execution started..."
fi

if [ "$BITS" == "True" ]; then
	gcc -m64 -o $OUTPUT_FILE $1 && echo ""
else
	gcc -m32 -o $OUTPUT_FILE $1 && echo ""
fi

if [ "$VERBOSE" == "True" ]; then
	echo "GCC execution completed."
fi

if [ "$QEMU" == "True" ]; then
	echo "Starting QEMU..."
	echo ""

	if [ "$BITS" == "True" ]; then
		qemu-x86_64 $OUTPUT_FILE && echo ""
	else
		qemu-i386 $OUTPUT_FILE && echo ""
	fi

	exit 0
fi

if [ "$GDB" == "True" ]; then
	gdb_params=()
	gdb_params+=(-ex "b ${BREAK}")

	if [ "$RUN" == "True" ]; then
		gdb_params+=(-ex "r")
	fi

	gdb "${gdb_params[@]}" $OUTPUT_FILE
fi
