# Introduction

The goal of this first exercise session is to familiarize with the tools used throughout the exercises for TIE-50307.

Throughout the exercise sessions of TIE-50307 *Real-Time Systems*, we designed, in collaboration with Wapice, a simulation of a typical industry workflow as a System Engineer. We are initially tasked with getting the board to boot a custom GNU Linux distribution built with Yocto.

The starting point of the simulation will be set at receiving a new sample board for a new embedded project.

Rather than providing step-by-step instructions, we provide a list of reading materials and resources you should familiarize with in order to solve the task at hand.

We will use a Ubuntu virtual machine (which already includes all the required prerequisites to successfully build the Yocto Project).
The username and (very secure) password for the VM account are: `student`/`student`.

**WARNING**: be aware that **files on the VM will be erased at each reboot**, commit and push your work to your remote repository (or save your important files to an external drive) before rebooting the VM.



# Resources and reading material

- [Lecture #1 and #2 on Moodle][moodle.COMP.CE.460]
- [Yocto Project Quick Start][YoctoQS]
- [Yocto Reference Manual (C#7: *Source Directory Structure*)][YoctoREFMAN:sec7.1]
- [PYNQ-Z1 Board Reference Manual][PYNQ-Z1-REFMAN]
- [Git Submodules][Git Submodules]
- [meta-pynq layer repository][meta-pynq]

# Checklist

- [ ] get a microSD kit for your group from the TA
- [ ] clone Yocto `poky` and add support for the PYNQ board <u>**as submodules**</u>.
  - **Hint**: check documentation of the PYNQ support layer to determine the proper version of `poky` and other requirements
  - add each of these repositories as [Git Submodules] in the root of the student group repository
- [ ] initialize the Build Environment, **making sure the *Build Directory* is created as `<STUDENT_REPO_ROOT>/build`**
  - notice that we require the *Build Directory* to be in a non-default location, requiring knowledge from the [linked section of the *Yocto Reference Manual*][YoctoREFMAN:sec7.1]
  - <u>DO NOT COMMIT THE WHOLE BUILD DIRECTORY</u>: only the configuration files should be committed.
- [ ] setup your local configuration file
- [ ] build `core-image-minimal`
  - **Hint**: building from scratch could require hours. Read on the *Yocto Reference Manual* about the `SSTATE_MIRRORS` variable and check the contents of `/opt/poky_cache` to speed up this step
- [ ] verify that the build was successful and copy the *required* files to the microSD
- [ ] turn off the PYNQ board and set it to boot from the microSD
- [ ] turn on and connect via serial to verify successful boot
  - the USB connection provides power to the board and provides a USB serial port on the host workstation: by default the bootloader and the kernel expose a virtual console on this serial interface.
  - use PuTTY on the host to connect to the console
- [ ] commit Yocto build configuration files to the student repository
- [ ] commit the changes to the question file for this exercise to include your answers
- [ ] <u>**push to your remote repository**</u>
- [ ] demonstrate to the TA
- [ ] <u>remember to recover your microSD card before leaving</u>










[Git Submodules]: https://git-scm.com/book/en/v2/Git-Tools-Submodules
[YoctoQS]: https://www.yoctoproject.org/docs/2.4.3/yocto-project-qs/yocto-project-qs.html
[moodle.COMP.CE.460]: https://moodle.tuni.fi/course/view.php?id=9860
[YoctoREFMAN:sec7.1]: https://www.yoctoproject.org/docs/2.4.3/ref-manual/ref-manual.html#structure-core
[PYNQ-Z1-REFMAN]: https://reference.digilentinc.com/_media/reference/programmable-logic/pynq-z1/pynq-rm.pdf
[meta-pynq]: https://course-gitlab.tuni.fi/comp.ce.460-real-time-systems_2020-2021/meta-pynq
