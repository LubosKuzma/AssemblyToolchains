#! /bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022

# if no arguments are given when executing...
if [ $# -lt 1 ]; then
	# print instruction on how to use the file
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
	# then exit program (with error)
	exit 1
fi

# various variables we will use later
# will be used for the args above (if prompted by user)
POSITIONAL_ARGS = ()
GDB = False
OUTPUT_FILE = ""
VERBOSE = False
BITS = True # set 64-bit as the default (as per readme)
QEMU = False
BREAK = "_start"
RUN = False

# loop through all arguments
while [[ $# -gt 0 ]]; do
	# for each arg, raise the flag (= TRUE) to run the command later
	# also set any relevant variables as necessary (e.g. user-given break point)
	# also note the special case where arg doesn't match anything
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
		-64|--x84-64)
			BITS=True
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

# check if the given file exists, if not exit program with error
if [[ ! -f $1 ]]; then
	echo "Specified file does not exist"
	exit 1
fi

# default output file name = input file (if user does not give the name)
if [ "$OUTPUT_FILE" == "" ]; then
	OUTPUT_FILE=${1%.*}
fi

# actually do the verbose command if prompted; print relevant arguments
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

# compile with NASM as 64 bit or otherwise depending on user input
if [ "$BITS" == "True" ]; then
	nasm -f elf64 $1 -o $OUTPUT_FILE.o && echo ""


elif [ "$BITS" == "False" ]; then
	nasm -f elf $1 -o $OUTPUT_FILE.o && echo ""

fi

# notify user about NASM compilation (might as well)
if [ "$VERBOSE" == "True" ]; then
	echo "NASM finished"
	echo "Linking ..."
fi

# same with NASM but for ld (NOTE: replaced with gcc as per readme)
if [ "$BITS" == "True" ]; then
	gcc -m64 -o $OUTPUT_FILE $1 && echo ""


elif [ "$BITS" == "False" ]; then
	gcc -m32 -o $OUTPUT_FILE $1 && echo ""

fi

# notify user about ld as well 
if [ "$VERBOSE" == "True" ]; then
	echo "Linking finished"
fi

# run program in QEMU in 64 bit or otherwise based on user input (if prompted)
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

# same as QEMU but for gdb. However, note the parameters given by the user as well (as well as if the user wants to run the file)
if [ "$GDB" == "True" ]; then

	gdb_params=()
	gdb_params+=(-ex "b ${BREAK}")

	if [ "$RUN" == "True" ]; then

		gdb_params+=(-ex "r")

	fi

	gdb "${gdb_params[@]}" $OUTPUT_FILE

fi