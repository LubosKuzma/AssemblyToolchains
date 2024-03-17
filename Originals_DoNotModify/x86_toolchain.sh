#! /bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022


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
	echo "-e | --extra					An extra lil' easter egg"
	echo "-h | --help 					show all options"

	exit 1
fi

POSITIONAL_ARGS=()
GDB=True								# defaulted gdb to True
OUTPUT_FILE=""
VERBOSE=True							# defaulted verbose to True
BITS=True								# defaulted 64bit compilation to True
QEMU=False
BREAK="_start"
RUN=True								# defaulted auto running program in gdb to True
EXTRA="False"
HELP="False"
while [[ $# -gt 0 ]]; do
	case $1 in
		-g|--gdb)
			GDB=False					# if -g/--gdb is included, it changes to False
			shift # past argument
			;;
		-o|--output)
			OUTPUT_FILE="$2"
			shift # past argument
			shift # past value
			;;
		-v|--verbose)					# if -v/--verbose is included, it changes to False
			VERBOSE=False
			shift # past argument
			;;
		-64|--x84-64)					# if -64/--x86-64 is included, it changes to False
			BITS=False
			shift # past argument
			;;
		-q|--qemu)
			QEMU=True
			shift # past argument
			;;
		-r|--run)						# if -r/--run is included, it changes to False
			RUN=False
			shift # past argument
			;;
		-b|--break)
			BREAK="$2"
			shift # past argument
			shift # past value
			;;
		-e|--extra)
			EXTRA="True"
			shift # past argument
			;;
		-h|--help)
			HELP="True"
			shift # past argument
			;;
		-*|--*)
			echo "Unknown option $1"
			echo "Use -h | --help for help"
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
	echo "	GDB = ${GDB}"
	echo "	RUN = ${RUN}"
	echo "	BREAK = ${BREAK}"
	echo "	QEMU = ${QEMU}"
	echo "	Input File = $1"
	echo "	Output File = $OUTPUT_FILE"
	echo "	Verbose = $VERBOSE"
	echo "	64 bit mode = $BITS"
	echo "  Help = $HELP"
	echo "  Something extra = $EXTRA"
	echo ""

	echo "NASM started..."

fi

if [ "$HELP" == "True" ]; then

	echo "Help with usage:"
	echo "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"
	echo ""
	echo "-v | --verbose                Show some information about steps performed."
	echo "-g | --gdb                    Run gdb command on executable."
	echo "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."
	echo "-r | --run                    Run program in gdb automatically. Same as run command inside gdb env."
	echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."
	echo "-64| --x86-64                 Compile for 64bit (x86-64) system."
	echo "-o | --output <filename>      Output filename."
	echo "-e | --extra                  An extra lil' easter egg"
	echo "-h | --help                   Show all options"


elif [ "$HELP" == "False" ]; then

	echo ""

fi

if [ "$EXTRA" == "True" ]; then

	echo ""
	echo "Test adding an extra argument"
	echo "This is just a little something extra"


elif [ "$EXTRA" == "False" ]; then

	echo ""

fi

if [ "$BITS" == "True" ]; then

	nasm -f elf64 $1 -o $OUTPUT_FILE.o && echo ""


elif [ "$BITS" == "False" ]; then

	nasm -f elf $1 -o $OUTPUT_FILE.o && echo ""

fi

if [ "$VERBOSE" == "True" ]; then

	echo "NASM finished"
	echo "Linking ..."
	
fi

if [ "$VERBOSE" == "True" ]; then

	echo "NASM finished"
	echo "Linking ..."
fi

if [ "$BITS" == "True" ]; then

	ld -m elf_x86_64 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""


elif [ "$BITS" == "False" ]; then

	ld -m elf_i386 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""

fi


if [ "$VERBOSE" == "True" ]; then

	echo "Linking finished"

fi

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

if [ "$GDB" == "True" ]; then

	gdb_params=()
	gdb_params+=(-ex "b ${BREAK}")

	if [ "$RUN" == "True" ]; then

		gdb_params+=(-ex "r")

	fi

	gdb "${gdb_params[@]}" $OUTPUT_FILE

fi