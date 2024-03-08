#! /bin/bash

# Author:       Emma Gillespie
# Date:         2024/03/05
# Description:  A shell script that will install the requirements for the tool chain.
#               Will also add man pages for the tool chain under man8.

# Might make it do this in a python file instead for ease of use

sudo apt-get install nasm -y
sudo apt-get install gdb -y
sudo apt-get install python3 -y
curl -fsSL https://gef.blah.cat/sh -y # Might have to install gef directly in gdb
sudo apt-get install qemu-user -y

# For adding the tool chains man pages to man
sudo cp ../documentation/x86_toolchain /usr/share/man/man8/x86_toolchain.8 -y
sudo gzip /usr/share/man/man8/x86_toolchain.8
#man x86_toolchain # For testing purpose only

sudo cp ../documentation/arm_toolchain /usr/share/man/man8/arm_toolchain.8 -y
sudo gzip /usr/share/man/man8/arm_toolchain.8
#man arm_toolchain # For testing purpose only