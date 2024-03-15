#! /bin/bash







# Created by Lubos Kuzma



# ISS Program, SADT, SAIT



# August 2022



#Modified by Nate Pudwell
#2024-03-15





if [ $# -lt 1 ]; then

  echo "Usage:"

  echo ""

  echo "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"

  echo ""

  echo "-v | --verbose                Show some information about steps performed."

  echo "-g | --gdb                    Run gdb command on executable."

  echo "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."

  echo "-r | --run                    Run program in gdb automatically. Same as run command inside gdb env."

  echo "-l | --link                    Object file will perform linking with gcc. Default is no linking."

  echo "-ow | --overwrite              Overwrite files with newly compiled files. Default is no overwriting."

  echo "-c | --copy              If overwrite is enabled this option will copy file being overwritten, if it exists. Default is no copying."
  
  echo "-e | --execute             Execute compiled file. Default is no execution."

  echo "-ldd | --libraries           Print shared libraries used by executable file"

  echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."

  echo "-64| --x86-64                 Compile for 64bit (x86-64) system. Enabled by default"

  echo "-32| --x86-32                 Compile for 32bit (x86-32) system."

  echo -e "\e[31mScript will use x86-xx option that is fursthest to the right in arguments.\e[0m"

  echo "-o | --output <filename>      Output filename for the executable."

  exit 1

fi



POSITIONAL_ARGS=()

GDB=False

OUTPUT_FILE=""

VERBOSE=False

BITS=True

QEMU=False

BREAK="_start"

RUN=False

LINK=False

OVERWRITE=False

COPY=False

EXECUTE=False

LDD=False

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

      BITS=True

      shift # past argument

      ;;

    -32|--x86-32)

    BITS=False

    shift # past argument

    ;;

    -q|--qemu)

      QEMU=True

      shift # past argument

      ;;
    -l|--link)

    LINK=True

    shift # past argument

    ;;

    -ow|--overwrite)

    OVERWRITE=True

    shift # past argument

    ;;

    -c|--copy)

    COPY=True

    shift # past argument

    ;;
    -e|--execute)

    EXECUTE=True

    shift # past argument

    ;;
    
    -ldd|----libraries)

    LDD=True

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

if [ "$OVERWRITE" = "True" ]; then

    Copy_name=""
    if [ -f "$OUTPUT_FILE.o" ]; then
        echo "Object file $OUTPUT_FILE.o already exists and overwriting."
        if [ "$COPY" = "True" ]; then
            echo "What name would you like to give your backup? Extension .o will automatically be added."
            read Copy_name

            if [ -f "$Copy_name.o" ]; then
                echo -e "\e[31mCopy file already exists. Exiting program.\e[0m"
                exit -1
            else
                cp "$OUTPUT_FILE.o" "$Copy_name.o"

                if [ -f "$Copy_name.o" ]; then
                    echo -e "\e[32m$Copy_name.o successfully created!\e[0m"
                    echo -e "\e[32mCopy successful.\e[0m"
                else
                    echo -e "\e[31mCopy failed.\e[0m"
                fi
            fi
        fi
    else
        echo -e "\e[32mObject file $OUTPUT_FILE.o does not exist. No overwriting needed.\e[0m"
    fi

    if [ -f "$OUTPUT_FILE" ]; then
        echo "Executable File $OUTPUT_FILE already exists and overwriting."
    else
        echo "File does not exist."
    fi

else
    if [ -f "$OUTPUT_FILE.o" ]; then
         echo -e "\e[31m///////////////Overwrite Protection/////////////// \e[0m"
         echo "$OUTPUT_FILE.o found."
         echo "Overwrite = $OVERWRITE"
         echo "If you want to overwrite existing files please use overwrite option."

         echo "Overwrite option = -ow"
         echo "Exiting"
         exit -1
    fi
fi

if [ "$VERBOSE" == "True" ]; then

  echo "Arguments being set:"

  echo "	GDB(-g | --gdb) = ${GDB}"

  echo "	RUN(-r | --run) = ${RUN}"

  echo "	BREAK(-b | --break <break point) = ${BREAK}"

  echo "	QEMU(-q | --qemu) = ${QEMU}"

  echo "	Input File = $1"

  echo "	Output File = $OUTPUT_FILE"

  echo "	Verbose(-v | --verbose) = $VERBOSE"

  echo "	64 bit mode(-64 | --x86=64) = $BITS" 
  
  
  echo -e "\e[36m	Blue = \e[31m86_toolchain.sh addons\e[0m"
  
  echo -e "\e[36m	32 bit mode(-32 | --x86=32) = $BITS\e[0m" 

  echo -e "\e[36m  	GCC linking(-l | --link) = $LINK\e[0m"

  echo -e "\e[36m  	OVERWRITE(-ow | --overwrite) = $OVERWRITE\e[0m"

  echo -e "\e[36m  	COPY(-c | --copy) = $COPY\e[0m"

  echo -e "\e[36m  	EXECUTE(-e | --execute) = $EXECUTE\e[0m"

  echo -e "\e[36m  	LDD(-ldd | --libraries) = $LDD\e[0m"

  echo ""

  echo "NASM started..."

fi



if [ "$LINK" == "True" ]; then
    echo -e "\e[36mLinking is enabled.\e[0m"
    echo -e "\e[36mChecking if GCC is installed.\e[0m"

    if command -v gcc &> /dev/null; then
        echo -e "\e[32mGCC is installed.\e[0m"

        echo "Your GCC version"

        gcc --version


    else
        echo "\e[31mGCC is not installed.\e[0m"
        exit -1
    fi



fi









if [ "$BITS" == "True" ]; then

  echo " Generating object file."

  nasm -f elf64 $1 -o $OUTPUT_FILE.o && echo ""


if [ -f "$OUTPUT_FILE.o" ]; then
    echo "File exists."
    echo -e "\e[32m$OUTPUT_FILE.o successfully created!\e[0m"

else
    echo "File does not exist."
fi




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


echo "BITs = ${BITS} "
echo "Link = ${LINK} "

if [ "$BITS" == "True" ]; then
  if [ "$LINK" == "True" ]; then
    echo -e "\e[36mStarting GCC 64 bit on $OUTPUT_FILE.o.\e[0m"
    gcc -no-pie -o $OUTPUT_FILE $OUTPUT_FILE.o -nostartfiles -e _start
  elif [ "$LINK" == "False" ]; then
    ld -m elf_x86_64 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""
  fi
elif [ "$BITS" == "False" ]; then
  echo " Starting GCC 32 bit on $OUTPUT_FILE.o."




  if [ "$LINK" == "True" ]; then
    echo -e "\e[36mStarting GCC 36 bit on $OUTPUT_FILE.o.\e[0m"
    gcc -m32 -mx32 -no-pie -o $OUTPUT_FILE $OUTPUT_FILE.o -nostartfiles -e _start

  elif [ "$LINK" == "False" ]; then
     ld -m elf_i386 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""
  fi

fi



if [ -f "$OUTPUT_FILE" ]; then
    echo "$OUTPUT_FILE file exists."
    echo -e "\e[32m$OUTPUT_FILE successfully created! \e[0m"

else
    echo "$OUTPUT_FILE File does not exist."
    echo -e "\e[31m$OUTPUT_FILE not sucessfully created! Exiting program!\e[0m"
    exit -1
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


if [ "$EXECUTE" == "True" ]; then
    echo "Execute = $EXECUTE"
    echo "Starting execution ..."
    echo -e "\e[36mStart of execute for executable file $OUTPUT_FILE: \e[0m"

    ./$OUTPUT_FILE

    echo ""
    echo -e "\e[36mEnd of execution.\e[0m"
fi


if [ "$LDD" == "True" ]; then
    echo "Starting ldd ..."
    echo -e "\e[36mShared libraries used by $OUTPUT_FILE: \e[0m"
    ldd ./$OUTPUT_FILE


fi
