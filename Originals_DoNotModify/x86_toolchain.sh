#! /bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022

# Checking if NASM is installed.
if ! command -v nasm &> /dev/null; then
    echo "NASM is not installed. Installing NASM..."
    sudo apt update
    sudo apt install -y nasm		# Installing NASM.
fi

# Number of command-line arguments.
if [ $# -lt 1 ]; then
    echo "Usage:"			# Display usage instructions.
    echo ""  				# Blank line for clarity.
    echo "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"  	# Specify command usage with options.
    echo "" 				# Blank line for clarity.
    echo "-v | --verbose                Show some information about steps performed."  		# Display verbose option.
    echo "-g | --gdb                    Run gdb command on executable."  			# Display gdb option.
    echo "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."  	# Display breakpoint option.
    echo "-r | --run                    Run program in gdb automatically. Same as run command inside gdb env."  # Display run option.
    echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."  # Display QEMU option.
    echo "-64| --x86-64                 Compile for 64bit (x86-64) system."  			# Display 64-bit option.
    echo "-o | --output <filename>      Output filename."  					# Display output filename option.
    exit 1  				# Exit script with error status.
fi

# Initializing variables.
POSITIONAL_ARGS=()  		# An array storing positional arguments.
GDB=False  			# Variable that stores gdb.
OUTPUT_FILE=""  		# Variable that stores output file.
VERBOSE=False  			# Variable that stores if verbose is enabled.
BITS=True  			# Variable that stores if 64-bit mode is enabled.
QEMU=False 			# Variable that stores QEMU.
BREAK="_start"  		# Variable storing breakpoint.
RUN=False

# Command-line arguments.
while [[ $# -gt 0 ]]; do  	# Looping through all command-line arguments.
    case $1 in
        -g|--gdb)
            GDB=True  		# Enable gdb.
            shift 		# past argument
            ;;
        -o|--output)
            OUTPUT_FILE="$2"  	# Setting output filename.
            shift 		# past argument
            shift 		# past value
            ;;
        -v|--verbose)
            VERBOSE=True  	# Enabling verbose mode.
            shift 		# past argument
            ;;
        -64|--x84-64)
            BITS=True  		# Compiling for 64-bit system.
            shift 		# past argument
            ;;
        -q|--qemu)
            QEMU=True  		# Enabling QEMU.
            shift 		# past argument
            ;;
        -r|--run)
            RUN=True  		# Running program automatically in gdb.
            shift 		# past argument
            ;;
        -b|--break)
            BREAK="$2"  	# Setting breakpoint.
            shift 		# past argument
            shift 		# past value
            ;;
        -|--)
            echo "Unknown option $1"  	# Displaying error for unknown option.
            exit 1  			# Exiting script with error.
            ;;
        *)
            POSITIONAL_ARGS+=("$1") 	# positional arg
            shift 			# past argument
            ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}" 		# restore positional parameters

# Checking input file existence.
if [[ ! -f $1 ]]; then
    echo "Specified file does not exist"  	# Displaying error for non-existing file.
    exit 1  					# Exiting script.
fi

if [ "$OUTPUT_FILE" == "" ]; then
    OUTPUT_FILE=${1%.*}  			# Setting output filename if not specified.
fi

# Information regarding VERBOSE.
if [ "$VERBOSE" == "True" ]; then
    echo "Arguments being set:"  		# Displaying arguments being set.
    echo "    GDB = ${GDB}"  			# Displaying GDB status.
    echo "    RUN = ${RUN}"  			# Displaying RUN status.
    echo "    BREAK = ${BREAK}"  		# Displaying breakpoint.
    echo "    QEMU = ${QEMU}"  			# Displaying QEMU status.
    echo "    Input File = $1"  		# Displaying input file.
    echo "    Output File = $OUTPUT_FILE"  	# Displaying output file.
    echo "    Verbose = $VERBOSE"  		# Displaying verbose mode.
    echo "    64 bit mode = $BITS"  		# Displaying 64-bit mode.
    echo "" 
    echo "NASM started..."  			# Notifying about NASM start.
fi

# Assembling the code.
if [ "$BITS" == "True" ]; then
    nasm -f elf64 $1 -o $OUTPUT_FILE.o && echo ""  	# Assembler for 64-bit system.
elif [ "$BITS" == "False" ]; then
    nasm -f elf $1 -o $OUTPUT_FILE.o && echo ""  	# Assembler for 32-bit system.
fi

if [ "$VERBOSE" == "True" ]; then
    echo "NASM finished"  				# NASM completion.
    echo "Linking ..."  				# Linking start.
fi

# Linking of object file.
if [ "$BITS" == "True" ]; then
    ld -m elf_x86_64 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""  # Link for 64-bit system.
elif [ "$BITS" == "False" ]; then
    ld -m elf_i386 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""  	# Link for 32-bit system.
fi

if [ "$VERBOSE" == "True" ]; then
    echo "Linking finished"  			# Linking completion.
fi

# Executing the file in QEMU.
if [ "$QEMU" == "True" ]; then
    echo "Starting QEMU ..."  			# QEMU start.
    echo ""
    if [ "$BITS" == "True" ]; then
        qemu-x86_64 $OUTPUT_FILE && echo ""  	# Executing in QEMU for 64-bit system.
    elif [ "$BITS" == "False" ]; then
        qemu-i386 $OUTPUT_FILE && echo ""  	# Executing in QEMU for 32-bit system.
    fi
    exit 0  					# Exiting.
fi

# GDB Debugging.
if [ "$GDB" == "True" ]; then
    gdb_params=()  				# Initializing gdb parameters.
    gdb_params+=(-ex "b ${BREAK}") 		# Adding breakpoint to gdb parameters.

    if [ "$RUN" == "True" ]; then
        gdb_params+=(-ex "r")  			# Adding run command to gdb parameters.
    fi

    gdb "${gdb_params[@]}" $OUTPUT_FILE  	# Running gdb with specified parameters.
fi
