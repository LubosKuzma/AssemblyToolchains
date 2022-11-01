'''
AUTHOR: Kolby MacDonald
DATE: 10/31/2022
PURPOSE: A fast, easily modifiable, and transparent python program that installs Assembly toolchains.
'''

import os
commandlist = '''
    cd ~
    sudo bash -c "$(curl -fsSL https://gef.blah.cat/sh)"
    sudo apt install qemu-user
    sudo apt-get install gdb-multiarch
    sudo git clone https://github.com/LubosKuzma/AssemblyToolchains.git
    cd AssemblyToolchains/scripts
    sudo chmod +rwx *
    sudo echo 'export PATH=$PATH:~/AssemblyTools/scripts' >> ~/.bashrc
'''
#Install Gef, Qemu, Multiarch, Toolchains, Own Files, Add to Path
os.system(commandlist)