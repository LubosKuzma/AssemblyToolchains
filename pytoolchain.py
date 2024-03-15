#!/usr/bin/env python3

import argparse
import os
from subprocess import check_call
import subprocess
import sys

arg = argparse.ArgumentParser()

arg.add_argument('-v', '--verbose', action="store_true", dest="VERBOSE", default=False, help="Show some information about steps performed.")
arg.add_argument('-g', '--gdb', action="store_true", dest="GDB", default=False, help="Run gdb command on executable.")
arg.add_argument('-b', '--break', action="store_const", dest="BREAK", default="_start", help="Add breakpoint after running gdb. Default is _start.")
arg.add_argument('-r', '--run', action="store_true", dest="RUN", default=False, help="Run program in gdb automatically. Same as run command inside gdb env.")
arg.add_argument('-q', '--qemu', action="store_true", dest="QEMU", default=False, help="Run executable in QEMU emulator. This will execute the program.")
arg.add_argument('-64', '--x86-64', action="store_true", dest="BITS", default=False, help="Compile for 64bit (x86-64) system.")
arg.add_argument('-o', '--output', action="store_const", dest="OUTPUT_FILE", help="Output filename")
arg.add_argument('filename', type=str, help='Input file name')

args = arg.parse_args()

if(os.path.isfile(args.filename) != True):
    print("Specified file does not exist")
    exit(1)

if (str(args.OUTPUT_FILE) == "None"):
    args.OUTPUT_FILE = str(args.filename)[:-2]

if (args.VERBOSE == True):
    print("Arguments being set:")
    print("	GDB = " + str(args.GDB))
    print("	RUN = " + str(args.RUN))
    print("	BREAK = " + str(args.BREAK))
    print("	QEMU = " + str(args.QEMU))
    print("	Input File = " + str(args.filename))
    print("	Output File = " + str(args.OUTPUT_FILE))
    print("	Verbose = " + str(args.VERBOSE))
    print("	64 bit mode = " + str(args.BITS))
    print("")

    print("NASM started...")

if (args.BITS == True):
    subprocess.run(["nasm", "-f", "elf64", "-o", str(args.OUTPUT_FILE)+".o", args.filename])

elif (args.BITS == False):
    subprocess.run(["nasm", "-f", "elf", "-o", str(args.OUTPUT_FILE)+".o", args.filename])

if (args.VERBOSE == True):
    print("NASM finished")
    print("Linking ...")

if (args.BITS == True):
    subprocess.run(["ld", "-m", "elf_x86_64", str(args.OUTPUT_FILE)+".o", "-o", str(args.OUTPUT_FILE)])

elif (args.BITS == False):
    subprocess.run(["ld", "-m", "elf_i386", str(args.OUTPUT_FILE)+".o", "-o", str(args.OUTPUT_FILE)])

if (args.VERBOSE == True):
    print("Linking finished")

if (args.QEMU == True):
    print("Starting QEMU ...")
    print("")

    if (args.BITS == True):
        check_call([sys.executable, "qemu-x86_64", str(args.OUTPUT_FILE)])

    elif(args.BITS == False):
        check_call([sys.executable, "qemu-i386", str(args.OUTPUT_FILE)])

    exit(0)

if (args.GDB == True):
    gdb_params= []
    gdb_params.extend(["-ex", f"b {args.BREAK}"])

    if (args.RUN == True):
        gdb_params.extend(["-ex", "r"])

    subprocess.run(["gdb"] + gdb_params + [args.OUTPUT_FILE])