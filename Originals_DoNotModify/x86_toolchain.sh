#! /bin/bash							# bash script - should be executed in bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022

# Checking to see if the number of command-line arguments is less than 1, then displays the following message and exits
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

# 
POSITIONAL_ARGS=()						# default setting for POSITIONAL_ARGS is an empty array
GDB=False							# default setting for GDB set to "False"
OUTPUT_FILE=""							# defualt setting for OUTPUT_FILE set to empty ""
VERBOSE=False							# defualt setting for VERBOSE set to "False"
BITS=True							# default setting for BITS set to "False" changed the default setting to "True", resulting in 64-bit architecture
QEMU=False							# default setting for QEMU set to "False"
BREAK="_start"							# default setting for BREAK to start at "_start"
RUN=False							# defualt setting for RUN set to "False"
while [[ $# -gt 0 ]]; do
	case $1 in
		-g|--gdb)					# checks if the positional argument is "-g" 
			GDB=True				# set GDB to "True"
			shift # past argument
			;;
		-o|--output)					# checks if the positional argument is "-o" 
			OUTPUT_FILE="$2"			# set OUTPUT_FILE to the second argument
			shift # past argument
			shift # past value
			;;
		-v|--verbose)					# checks if the positional argument is "-v" 					
			VERBOSE=True				# set VERBOSE to "True"
			shift # past argument
			;;
		-64|--x84-64)					# checks if the positional argument is "-64" 
			BITS=True				# set BITS to "True"
			shift # past argument
			;;
		-q|--qemu)					# checks if the positional argument is "-q" 
			QEMU=True				# set QEMU to "True"
			shift # past argument
			;;
		-r|--run)					# checks if the positional argument is "-r" 
			RUN=True				# set RUN to "True"
			shift # past argument
			;;
		-b|--break)					# checks if the positional argument is "-b" 
			BREAK="$2"				# set BREAK to the second argument
			shift # past argument
			shift # past value
			;;
		-*|--*)						# checks if the positional argument is anything other than those listed above  
			echo "Unknown option $1"		# prints error
			exit 1					# exits
			;;
		*)
			POSITIONAL_ARGS+=("$1") # save positional arg
			shift # past argument
			;;
	esac
done

# updates positional arguments stored in the POSITIONAL_ARGS array
set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# checks if the first positional argument is incorrect - then print an error message and quit
if [[ ! -f $1 ]]; then
	echo "Specified file does not exist"
	exit 1
fi

#checks if the OUTPUT_FILE variable is empty the 
if [ "$OUTPUT_FILE" == "" ]; then
	# set OUTPUT_FILE to expand the first argument without the suffix at the end of the argument
 	OUTPUT_FILE=${1%.*}
fi

#checks if the verbose value is "True", then prints the following arguments
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

# checks if BITS are valued at "True" or "False" and changes the format to 64-bit and 32-bit, respectively and starts NASM
if [ "$BITS" == "True" ]; then

	# NASM for 64-bit
	nasm -f elf64 $1 -o $OUTPUT_FILE.o && echo ""


elif [ "$BITS" == "False" ]; then

	# NASM for 32-bit
	nasm -f elf $1 -o $OUTPUT_FILE.o && echo ""

fi

# checks if verbose is set to "True", prints the following
if [ "$VERBOSE" == "True" ]; then

	echo "NASM finished"
	echo "Linking ..."
	
fi

# checks if verbose is set to "True", prints the following, not sure why it here twice
if [ "$VERBOSE" == "True" ]; then

	echo "NASM finished"
	echo "Linking ..."
	
fi

# checks if BITS are valued at "True" or "False" and uses the ld linker to link the object file into an executable for its respective architecture
if [ "$BITS" == "True" ]; then

 	#ld linker for 64-bit
	ld -m elf_x86_64 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""


elif [ "$BITS" == "False" ]; then

	#ld linker for 32-bit
	ld -m elf_i386 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""

fi

# prints if verbose is "True"
if [ "$VERBOSE" == "True" ]; then

	echo "Linking finished"

fi

# checks if the emulator QEMU value is "True" or "False" and starts the QEMU based on the bit architecture
if [ "$QEMU" == "True" ]; then

	echo "Starting QEMU ..."
 	echo ""

	if [ "$BITS" == "True" ]; then

 		# QEMU for 64-bit
		qemu-x86_64 $OUTPUT_FILE && echo ""

	elif [ "$BITS" == "False" ]; then

		# QEMU for 32-bit
		qemu-i386 $OUTPUT_FILE && echo ""

	fi

 	#if correctly compiled exit
	exit 0
	
fi

# checks if the GDB value is "True"; if so, creates an array "gdb_params"
if [ "$GDB" == "True" ]; then

	gdb_params=()

  	# adds a BREAK parameter
	gdb_params+=(-ex "b ${BREAK}")

	# if the RUN value is "True", adds a run command
	if [ "$RUN" == "True" ]; then

		gdb_params+=(-ex "r")

	fi

	# executes the GDB debugger with saved parameters and the executable file
	gdb "${gdb_params[@]}" $OUTPUT_FILE

fi
