#! /bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022

#Changes made by Tobias Tomana
#ISS Student, SADT, SAIT
#March 2024 

#Function to display specific help option.
display_help() {
    local option="$1"
    case $option in
        -v|--verbose)
            echo "Option -v or --verbose: Show some information about steps performed."
            ;;
        -g|--gdb)
            echo "Option -g or --gdb: Run gdb command on executable."
            ;;
        -b|--break)
            echo "Option -b or --break <break point>: Add breakpoint after running gdb. Default is _start."
            ;;
        -r|--run)
            echo "Option -r or --run: Run program in gdb automatically. Same as run command inside gdb env."
            ;;
        -q|--qemu)
            echo "Option -q or --qemu: Run executable in QEMU emulator. This will execute the program."
            ;;
        -64|--x84-64)
            echo "Option -64 or --x86-64: Compile for 64bit (x86-64) system."
            ;;
        -o|--output)
            echo "Option -o or --output <filename>: Output filename."
            ;;
        -h|--help)
            echo "Option -h <option>: Show further information."
            ;;
        *)
            echo "Unknown option: $opt"
            ;;
    esac
}

# Function to display all help information
display_all_help() {
    echo "Usage: $0 [options] <assembly filename> [-o | --output <output filename>]"
    echo ""
    echo "-v | --verbose                Show some information about steps performed."
    echo "-g | --gdb                    Run gdb command on executable."
    echo "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."
    echo "-r | --run                    Run program in gdb automatically. Same as run command inside gdb env."
    echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."
    echo "-64| --x86-64                 Compile for 64bit (x86-64) system."
    echo "-o | --output <filename>      Output filename."
    echo "-h | --help                   Show further information about options."
}

if [ $# -lt 1 ]; then
	echo "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"
	exit 1
fi

#Set parameter to False or Empty
POSITIONAL_ARGS=()
GDB=False
OUTPUT_FILE=""
VERBOSE=False
BITS=False
QEMU=False
BREAK="_start"
RUN=False
HELP=False

while getopts ":gvo:64qrb:h:" opt; do # was [[ $# -gt 0 ]]; do
	case $opt in #was case $1 in
		-g|--gdb)
			GDB=True
			shift # past argument
			;;
		-o|--output)
			OUTPUT_FILE="$OPTARG" # was "$2"
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
			BREAK="$OPTARG" #"$2"
			shift # past argument
			shift # past value
			;;
		-h| --help) 
			HELP="OPTARG"
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

#Check for help, call for help 
if [ "$HELP" == "True" ]; then
    if [ $# -gt 1 ]; then
        shift
        if [ "$1" == "all" ]; then
            display_all_help
        else
            display_help "$1"
        fi
    else
        display_all_help
    fi
    exit 0
fi
shift $((OPTIND - 1)) # Shift to process non-option arguments

if [ $# -lt 1]; then #Error handling when there are no arguments
	echo "Usage: $0 [options] <assembly filename> [-o | --output <output filename>]"
	exit 1
fi

INPUT_FILE="$1" #Set input filename

#Check OUTPUT_FILE value, if empty fill it with the INPUT_FILE
if [-z "$OUTPUT_FILE"]; then
	OUTPUT_FILE="${INPUT_FILE%.*}"
fi

#Error handling: Arg 1 check 
if [[ ! -f "$1" ]]; then
	echo "Specified file does not exist"
	exit 1
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
	echo ""

	echo "NASM started..."

fi

if [ "$BITS" == "True" ]; then

	nasm -f elf64 $1 -o $OUTPUT_FILE.o && echo ""
else 
	nasm -f elf $1 -o $OUTPUT_FILE.o && echo ""
fi

if [ "$VERBOSE" == "True" ]; then

	echo "NASM finished"
	echo "Linking ..."
	
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
