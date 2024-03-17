#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int updates(void)
{   /*all the command values*/

    char apt_update[] = "sudo apt update";
    char apt_upgrade[] = "sudo apt upgrade";

    int return_value[3];
    return_value[0] = system(apt_update);
    return_value[1] = system(apt_upgrade);


    for(int i = 0; i < 2; i++)
    {/*loops through the return values*/
        if (return_value[i] != 0) 
        {
            switch(i) 
            {
            case 0:
                printf("sudo apt update failed\n");
                break;
            case 1:
                printf("sudo apt upgrade failed\n");
                break;
            }
            return 1; // Indicate failure
        } 
    }
    return 0;
}

int visualStudio_installer(void)
{
    char apt_install[] = "sudo apt install dirmngr ca-certificates software-properties-common apt-transport-https curl -y";
    char import_GPG_key[] = "curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg >/dev/null";
    char add_repository[] = "echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main | sudo tee /etc/apt/sources.list.d/vscode.list";
    char install_code[] = "sudo apt install code";
    char apt_update[] = "sudo apt update";

    int return_value[6];
    return_value[0] = system(apt_install);
    return_value[1] = system(import_GPG_key);
    return_value[2] = system(add_repository);
    return_value[3] = system(install_code);
    return_value[4] = system(apt_update);

    for(int i = 0; i < 6; i++)
    {/*loops through the return values*/
        if (return_value[i] != 0) 
        {
            switch(i) 
            {
            case 0:
                printf("apt_install of certificates failed\n");
                break;
            case 1:
                printf("importing GPG key failed\n");
                break;
            case 2:
                printf("adding repository failed\n");
                break;
            case 3:
                printf("installing visual studio code failed\n");
                break;
            case 4:
                printf("sudo apt update failed\n");
                break;
            }
            return 1; // Indicate failure
        } 
    }
    return 0;
}

int x86_toolchain_create_and_run(void) 
{
    char chmod[] = "sudo chmod +x x86_tollchain_script.sh";
    char x86_toolchain_installer[] = "sudo ./x86_tollchain_script.sh";

    FILE *file;
    file = fopen("x86_toolchain_script.sh", "w");

    fprintf(file, "#! /bin/bash\n\n# Created by Lubos Kuzma\n# ISS Program, SADT, SAIT\n# August 2022\n\nif [ $# -lt 1 ]; then\necho \"Usage:\"\necho \"\"\necho \"x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]\"\necho \"\"\necho \"-v | --verbose                Show some information about steps performed.\"\necho \"-g | --gdb                    Run gdb command on executable.\"\necho \"-b | --break <break point>    Add breakpoint after running gdb. Default is _start.\"\necho \"-r | --run                    Run program in gdb automatically. Same as run command inside gdb env.\"\necho \"-q | --qemu                   Run executable in QEMU emulator. This will execute the program.\"\necho \"-64| --x86-64                 Compile for 64bit (x86-64) system.\"\necho \"-o | --output <filename>      Output filename.\"\nexit 1\nfi\n\n");
    fprintf(file, "POSITIONAL_ARGS=()\nGDB=False\nOUTPUT_FILE=\"\"\nVERBOSE=False\nBITS=False\nQEMU=False\nBREAK=\"_start\"\nRUN=False\nwhile [[ $# -gt 0 ]]; do\ncase $1 in\n-g|--gdb)\nGDB=True\nshift # past argument\n;;\n-o|--output)\nOUTPUT_FILE=\"$2\"\nshift # past argument\nshift # past value\n;;\n-v|--verbose)\nVERBOSE=True\nshift # past argument\n;;\n-64|--x84-64)\nBITS=True\nshift # past argument\n;;\n-q|--qemu)\nQEMU=True\nshift # past argument\n;;\n-r|--run)\nRUN=True\nshift # past argument\n;;\n-b|--break)\nBREAK=\"$2\"\nshift # past argument\nshift # past value\n;;\n-*)\necho \"Unknown option $1\"\nexit 1\n;;\n*)\nPOSITIONAL_ARGS+=(\"$1\") # save positional arg\nshift # past argument\n;;\nesac\ndone\n\nset -- \"${POSITIONAL_ARGS[@]}\" # restore positional parameters\n\nif [[ ! -f $1 ]]; then\necho \"Specified file does not exist\"\nexit 1\nfi\n\nif [ \"$OUTPUT_FILE\" == \"\" ]; then\nOUTPUT_FILE=${1%.*}\nfi\n\nif [ \"$VERBOSE\" == \"True\" ]; then\necho \"Arguments being set:\"\necho \"	GDB = ${GDB}\"\necho \"	RUN = ${RUN}\"\necho \"	BREAK = ${BREAK}\"\necho \"	QEMU = ${QEMU}\"\necho \"	Input File = $1\"\necho \"	Output File = $OUTPUT_FILE\"\necho \"	Verbose = $VERBOSE\"\necho \"	64 bit mode = $BITS\" \necho \"\"\n\necho \"NASM started...\"\nfi\n\nif [ \"$BITS\" == \"True\" ]; then\n\nnasm -f elf64 $1 -o $OUTPUT_FILE.o && echo \"\"\n\nelif [ \"$BITS\" == \"False\" ]; then\n\nnasm -f elf $1 -o $OUTPUT_FILE.o && echo \"\"\n\nfi\n\nif [ \"$VERBOSE\" == \"True\" ]; then\n\necho \"NASM finished\"\necho \"Linking ...\"\n\nfi\n\nif [ \"$VERBOSE\" == \"True\" ]; then\n\necho \"NASM finished\"\necho \"Linking ...\"\nfi\n\nif [ \"$BITS\" == \"True\" ]; then\n\nld -m elf_x86_64 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo \"\"\n\nelif [ \"$BITS\" == \"False\" ]; then\n\nld -m elf_i386 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo \"\"\n\nfi\n\nif [ \"$VERBOSE\" == \"True\" ]; then\necho \"Linking finished\"\nfi\n\nif [ \"$QEMU\" == \"True\" ]; then\necho \"Starting QEMU ...\"\necho \"\"\nif [ \"$BITS\" == \"True\" ]; then\nqemu-x86_64 $OUTPUT_FILE && echo \"\"\nelif [ \"$BITS\" == \"False\" ]; then\nqemu-i386 $OUTPUT_FILE && echo \"\"\nfi\nexit 0\nfi\n\nif [ \"$GDB\" == \"True\" ]; then\ngdb_params=()\ngdb_params+=(-ex \"b ${BREAK}\")\nif [ \"$RUN\" == \"True\" ]; then\ngdb_params+=(-ex \"r\")\nfi\ngdb \"${gdb_params[@]}\" $OUTPUT_FILE\nfi\n");
    fclose(file);

    int return_value[3];
    return_value[0] = system(chmod);
    return_value[1] = system(x86_toolchain_installer);

    for(int i = 0; i < 3; i++)
    {/*loops through the return values*/
        if (return_value[i] != 0) 
        {
            switch(i) 
            {
            case 0:
                printf("changing x86 toolchain installer permissions failed\n");
                break;
            case 1:
                printf("running the toolchain failed\n");
                break;
            }
            return 1; // Indicate failure
        } 
    }
    return 0;
}

int gef_installer(void)
{
    char gef_install[] ="bash -c \"$(wget https://gef.blah.cat/sh -O -)\"";
    int return_value = system(gef_install);
    if(return_value != 0)
    {
        printf("gef has failed to install");
    }
    return 1;

}

int main()
{
    char yayORnay = 'a';

    /*Introduction to the program*/
    printf("Wassup homie it's time to install Lubos's Favorite package");
    printf("\nThe x86 Toolchain Yippee\n");
    printf("brought to you by the Amazing Joshua Eames Fredrick Bowyer\n");
    printf("press r when ready or press quit quit: \n");
    /*gets the quit or continue button*/
    scanf(" %[^\n]c", &yayORnay);
    if (yayORnay == 'q' | yayORnay == 'Q')
    {/*if they press Q it quits*/
        exit(0);
    }
    else if (yayORnay == 'r' | yayORnay == 'R')
    {
        /*runs some basic update commands to get the process going*/
        if(updates() == 0)
        {/*if it works it moves on and if it doesn't it quits*/
            printf(" initial updates worked continuing");
            for(int i = 0; i < 6; i++)
            {
                printf("* ");
                sleep(1);
            }
        }
        else
        {
            exit(1);
        }
        /*runs a bunch o' commands to install visual studio code*/
        if(visualStudio_installer() == 0)
        {/*if it works it moves on and if it doesn't it quits*/
            printf(" visual studio code installation was successful continuing");
            for(int i = 0; i < 6; i++)
            {
                printf("* ");
                sleep(1);
            }
        }
        else
        {
            exit(1);
        }
        /*builds and runs the toolchain should also install gdb too*/      
        if(x86_toolchain_create_and_run() == 0)
        {/*if it works it moves on and if it doesn't it quits*/
            printf("successfully ran the x86 toolchain install continuing");
            for(int i = 0; i < 6; i++)
            {
                printf("* ");
                sleep(1);
            }
        }
        else
        {
            exit(1);
        }  
        /*it*/
        if(x86_toolchain_create_and_run() == 0)
        {/*if it works it moves on and if it doesn't it quits*/
            printf("successfully installed GEF finishing");
            for(int i = 0; i < 6; i++)
            {
                printf("* ");
                sleep(1);
            }
        }
        else
        {
            exit(1);
        } 
    }
    else
    {
        printf("wrong value entered\n please press enter or q");
    }
    exit(0);
}