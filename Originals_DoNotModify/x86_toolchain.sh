#! /bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022

show_status() {
	echo "[$9date '+%Y-%m-%d %H:%M:%S')] $1"
}

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
 	echo "-u | --update 		    Updates system before executing specified arguments 

	exit 1
fi

POSITIONAL_ARGS=()
GDB=False
OUTPUT_FILE=""
VERBOSE=False
BITS=True 	# sets x86_64 (64 bit) as default
QEMU=False
BREAK="_start"
RUN=False
UPDATE=False
while [[ $# -gt 0 ]]; do
	case $1 in
		-u|--update)			# New argument allows user to specify if they would like their system updated before executing other arguments
  			UPDATE=True
     			shift # past argument
			;;
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
		-32|--x84-32)			# New argument that allows the user to specify if they want to use 32 bit
			BITS=False
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

update_system() {				# Function that updates/upgrades the system while presenting status and messages to inform the user
	show_status "Updating system..."
 	sudo apt update && show_status "Update complete" 			
  	sudo apt upgrade-y && show_status "Upgrade complete" 

if [[ ! -f $1 ]]; then
	echo "Specified file does not exist"
	exit 1
fi

if [ "$OUTPUT_FILE" == "" ]; then
	OUTPUT_FILE=${1%.*}
fi

if [ "$UPDATE" == "True" ]; then
	update_system
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

	
 	nasm -f elf64 $1 -o $OUTPUT_FILE.o && show_status "Assembly complete"


elif [ "$BITS" == "False" ]; then

 
	nasm -f elf $1 -o $OUTPUT_FILE.o && show_status "Assembly complete"

fi

if [ "$VERBOSE" == "True" ]; then

	echo "NASM finished"
fi

if [ "$VERBOSE" == "True" ]; then

	echo "NASM finished"
fi

if [ "$BITS" == "True" ]; then

	ld -m elf_x86_64 $OUTPUT_FILE.o -o $OUTPUT_FILE && show_status "Linking process complete"


elif [ "$BITS" == "False" ]; then

	ld -m elf_i386 $OUTPUT_FILE.o -o $OUTPUT_FILE && show_status "Linking process complete"

fi

if [ "$QEMU" == "True" ]; then

 	show_status
	echo "Starting QEMU ..."
	echo ""

	if [ "$BITS" == "True" ]; then
	
		qemu-x86_64 $OUTPUT_FILE && show_status "Process Complete"

	elif [ "$BITS" == "False" ]; then

		qemu-i386 $OUTPUT_FILE && show_status "Process Complete"

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
