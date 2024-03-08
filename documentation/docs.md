<!--
Author:         Emma Gillespie
Date:           2024/03/05
Description:    This is a documentation file for the Assembly Tool chain tool.
                This will teach you how to install, run and teach proper use of the tool.
-->

# Assembly Tool Chain
This program is a tool chain that will compile assembly code for both X86 and ARM. It was created by Lubos Kuzma (https://www.linkedin.com/in/lubos-kuzma-0719a586)

# Installation
Using git:
```
git clone https://github.com/LubosKuzma/AssemblyToolchains.git
cd AssemblyToolchains
chmod +x x86_toolchain.sh
or
chmod +x arm_toolchain.sh
```

Using Zip:
```
Click download zip button
Extract files
cd AssemblyToolchains
chmod +x x86_toolchain.sh
or
chmod +x arm_toolchain.sh
```

Before You run the desired toolchain you will need to run the pre-install.sh which will install required files, programs and the man pages.
From inside AssemblyToolchains folder type:
```
cd pre_requirements_installer
./pre-install.sh
```
This may require you to type in your password. This is just to install the needed files.

# Usage
After you have installed the program and have run the pre-install script we are ready to run the program.

There are some positional arguements which are as follows:
```
-v | --verbose                Show some information about steps performed.
-g | --gdb                    Run gdb command on executable.
-b | --break <break point>    Add breakpoint after running gdb. Default is _start.
-r | --run                    Run program in gdb automatically. Same as run command inside gdb env.
-q | --qemu                   Run executable in QEMU emulator. This will execute the program.
-64| --x86-64                 Compile for 64bit (x86-64) system.
-o | --output <filename>      Output filename.

Additionally in ARM:
-p | --port                   Specify a port for communication between QEMU and GDB. Default is 12222.
```

For example we can use the X86 Toolchain as follows to debug and compile the x86 assembly:
```
./x86_toolchain.sh -v -64 <file path/file name> -g -r
```
This will also show steps performed and compile the assembly for 64bit systems.