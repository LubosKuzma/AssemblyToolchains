#! /bin/bash

# Created by xiao yan
# ISS Program, SADT, SAIT
# March 17


if [ $# -lt 1 ]; then
	echo "Usage:"
	echo ""
	echo "gcc_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"
	echo ""
	echo "-v | --verbose                Show some information about steps performed."
	echo "-g | --gdb                    Run gdb command on executable."
	echo "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."
	echo "-r | --run                    Run program in gdb automatically. Same as run command inside gdb env."
	echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."
 	echo "-32| --x86          	    Comple for 32bit system"
	echo "-o | --output <filename>      Output filename."
	echo ""
	exit 1
fi

POSITIONAL_ARGS=()
GDB=False
OUTPUT_FILE=""
VERBOSE=False
BITS="64"
QEMU=False
BREAK="main"
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
   		-32|--x84-64)
			BITS="32"
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

if [[ ! -f $1 ]]; then
	echo "Specified file does not exist"
	exit 1
fi

if [ "$OUTPUT_FILE" == "" ]; then
	OUTPUT_FILE=${1%.*}
fi

GCC_FLAGS=""
if [ "$BITS" == "64" ]; then
	GCC_FLAGS="-m64"
else
	GCC_FLAGS="-m32"
fi

if [ "$VERBOSE" == "True" ]; then
	echo "Arguments being set:"
	echo "	GDB = ${GDB}"
	echo "	RUN = ${RUN}"
	echo "	BREAK = ${BREAK}"
	echo "	QEMU = ${QEMU}"
	echo "	Input File = $1"
	echo "	Output File = $OUTPUT_FILE"
	echo "	Verbose = $VERBOSE"
	echo "	Architecture = ${BITS}-bit"
	echo ""
 	echo "GCC started"

fi

gcc $GCC_FLAGS $1 -o $OUTPUT_FILE

if [ "$VERBOSE" == "True" ]; then

	echo "gcc finished"
fi

if [ "$QEMU" == "True" ]; then
	echo "Starting QEMU..."
	if [ "$BITS" == "64" ]; then
		qemu-x86_64 $OUTPUT_FILE
	else
		qemu-i386 $OUTPUT_FILE
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
