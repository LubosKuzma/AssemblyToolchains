#!/usr/bin/env python3
#Preston Tan toolchain installer via python
#all functions from original installer are copied verbatum
#some functions have been manually added for ease of readability in the rest of the program
#they can be seen at the top along with the imports
#program starts at the start header
#must be run as root user
import os
import requests
from subprocess import STDOUT, check_call
import sys

def is_root():
    return os.geteuid() == 0

def download(url: str, dest_folder: str):
    if not os.path.exists(dest_folder):
        os.makedirs(dest_folder)  # create folder if it does not exist

    filename = url.split('/')[-1].replace(" ", "_")  # be careful with file names
    file_path = os.path.join(dest_folder, filename)

    r = requests.get(url, stream=True)
    if r.ok:
        print("saving to", os.path.abspath(file_path))
        with open(file_path, 'wb') as f:
            for chunk in r.iter_content(chunk_size=1024 * 8):
                if chunk:
                    f.write(chunk)
                    f.flush()
                    os.fsync(f.fileno())
    else:  # HTTP status code 4XX/5XX
        print("Download failed: status code {}\n{}".format(r.status_code, r.text))

def install(package):
    check_call([sys.executable, "-m", "pip", "install", package])

# start______________________________________________________________________________________________________________

if (is_root == 1):
    print("Please run in root")
    exit(1)

print("You may be prompted for a password. Do not be alarmed, this is normal\nx86, arm, or q?")

while(True):
    archval = input()
    if ((archval == "x86") or (archval == "X86")):
        try:
            check_call("command -v x86_toolchain.sh", stdout=open(os.devnull,'wb'), stderr=STDOUT)
        except:
            download("https://raw.githubusercontent.com/LubosKuzma/ITSC204/main/scripts/x86_toolchain.sh", dest_folder="/usr/bin/")
            os.chmod("/usr/bin/x86_toolchain.sh", 0o555)
            break
        
        else:
            print("x86_toolchain.sh is already installed")
            break

    elif (("$archval" == "arm") or ("$archval" == "ARM")):
        try:
            check_call("command -v arm_toolchain.sh", stdout=open(os.devnull,'wb'), stderr=STDOUT)
        except:
            check_call(['apt', 'install', '-y', 'gcc-arm-linux-gnueabihf'], stdout=open(os.devnull,'wb'), stderr=STDOUT)
            check_call(['apt', 'install', '-y', 'gdb-multiarch'], stdout=open(os.devnull,'wb'), stderr=STDOUT) 
            download("https://raw.githubusercontent.com/LubosKuzma/ITSC204/main/scripts/arm_toolchain.sh", dest_folder="/usr/bin/")
            os.chmod("/usr/bin/x86_toolchain.sh", 0o555)
            break

        else:
            print("arm_toolchain.sh is already installed")
            break

    elif (("$archval" == "Q") or ("$archval" == "q")):
        exit(0)

    else:
        print("Please enter either 'arm' or 'x86'")

try:
    check_call("command -v gdb", stdout=open(os.devnull,'wb'), stderr=STDOUT)
except:
    print("gdb not found. Installing....\nThis may take a few minutes")
    install("gef-gdb")
    print("~/.gdbinit-gef.py >> ~/.gdbinit")

try:
    check_call("command -v gdb -f ~/.gdbinit-gef.py", stdout=open(os.devnull,'wb'), stderr=STDOUT)
except:
    print("gef missing. Installing files")
    install("gef-gdb")
    print("~/.gdbinit-gef.py >> ~/.gdbinit")

try:
    check_call("dpkg -l qemu-user > /dev/null 2>&1", stdout=open(os.devnull,'wb'), stderr=STDOUT)
except:
    print("Installing qemu-user")
    install("qemu")

exit(0)
