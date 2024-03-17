#! /bin/bash

# Created by Ivan Pedro
# ISS Program, SADT, SAIT
# March 2024

# NASM -> GCC

if [ $# -lt 1 ]; then
    echo "Usage:"
    echo ""
    echo "x86_toolchain.sh <c code filename> [-o | --output <output filename>]"
    exit 1
fi

POSITIONAL_ARGS=()
OUTPUT_FILE=""
BITS=False
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT_FILE="$2"
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

if [ "$BITS" == "True" ]; then
    gcc $1 -o $OUTPUT_FILE && echo ""

elif [ "$BITS" == "False" ]; then
    gcc $1 -o $OUTPUT_FILE && echo ""

fi

if [ "$VERBOSE" == "True" ]; then
    echo "GCC finished"

fi
