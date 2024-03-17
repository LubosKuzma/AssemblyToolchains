-h|--help)
	echo "Usage: arm_toolchain.sh [OPTIONS] <assembly filename>"
	echo "Options:"
	echo "  -g | --gdb                    Run gdb command on executable."
	echo "  -o | --output <filename>      Specify the output filename."
	echo "  -v | --verbose                Show detailed step information."
	echo "  -q | --qemu                   Execute the program in QEMU."
	echo "  -p | --port <port>            Set the port for QEMU and GDB communication. Default: 12222."
	echo "  -b | --break <break point>    Set a breakpoint. Default: main."
	echo "  -r | --run                    Automatically run the program in gdb."
	exit 0
	;;
