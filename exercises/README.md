# Introduction

Throughout the exercise sessions of TIE-50307 *Real-Time Systems*, we designed, in collaboration with Wapice, a simulation of a typical industry workflow as a System Engineer.

The starting point of the simulation will be set at receiving a new sample board for a new embedded project.
We are initially tasked with getting the board to boot a custom GNU Linux distribution built with Yocto, and will then proceed to develop a kernel driver to support a custom IP required for the project, eventually improving and tweaking it for real-time applications.
We will also use Yocto to generate a dedicated SDK to develop and cross-compile userland applications for the project, and in the final stages we will go back to work on the bootloader to adapt to different usage requirements.

Rather than providing a step-by-step guide, in general the instructions for each exercise session will include an introduction detailing the specific goals of the exercise, links to related reading materials and resources, and a checklist to self-validate your progression towards the solution of the exercise.
Generally each exercise will include an instructions file and a questions file: completion of the exercise requires completing the tasks listed in the instructions and adding answers to the questions file.

In general, the completion of each exercise will be marked after submitting a properly tagged commit (`ex??`, where `??` is replaced by the exercise number) to the group repository and presenting a working demonstration to the TA during the exercise sessions.
The evaluation of the submitted commits is done manually and might require some time; unless otherwise stated, the deadline for submitting the solution to an exercise and to demonstrate it to the course staff is set to one week after the scheduled exercise session (i.e., the first exercise should be demonstrated either during the first or the second exercise session).

The exercise sessions are conducted in groups (exercises and seminar presentations will be organized using the same groups), using any of the PYNQ-Z1 boards installed in lab TC219 and a microSD card: each member of the group should make sure to have valid access rights to TC219 (or compile the required forms).

The course staff will provide a microSD card kit per group (which includes a 16GB microSD, a microSD to SD adapter and a USB microSD reader): it must be returned at the end of the course.

# Tools

Throughout the course we will use the following tools:
- Xilinx PYNQ-Z1 board (installed in TC219, must be set to boot from the microSD card)
- microSD card kit (including a 16GB microSD card, a microSD to SD adapter, and a USB microSD reader)
- Xilinx Vivado 2017 (installed in TC219 workstations)
- vmware Workstation/Player (installed in TC219 workstations)
- an Ubuntu virtual machine image:
  - the image comes preinstalled with all the requirements for Yocto development
  - located in `C:\Work\TIE-50307-course-vm` in TC219 workstations
  - it will be used for most of the development and compilation tasks
  - the image comes with vmware tools support: we will use `Shared Folders` to export the compiled artifacts to the host system and to write them to the microSD card
  - usr/pwd: student/student
  - **WARNING**: be aware that **files on the VM will be erased at each reboot**, commit and push your work to your remote repository (or save your important files to an external drive) before rebooting the VM.
