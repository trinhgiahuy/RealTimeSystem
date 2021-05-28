# Introduction

In this exercise the work continues on the kernel module.

The kernel module comes in a the `meta-tie50307` Yocto layer, under `recipes-kernel/irqgen-ex4-mod`.
- `meta-tie50307` will be part of each group repository (rather than being another submodule): we will be using this layer for future tasks, so we should avoid conflicting changes.
- **For this exercise you are supposed to alter only `irqgen.c`, `irqgen_addresses.h` and (optionally) `irqgen_sysfs.c`. Do not modify any other file inside `meta-tie50307`.**

In this exercise as BONUS task you can finalize the IP block design adding the latency counter register and its logic with verilog and Vivado.
Alternatively you can use the provided bitstream and just update the KLM developed in the previous exercise to support the latency counter.

The BONUS Vivado development will happen on the Windows Host. (TC219 or https://www.xilinx.com/products/design-tools/vivado/vivado-webpack.html)

For the Yocto development, we will use the same Ubuntu virtual machine (which already includes all the required prerequisites to successfully build the Yocto Project).
It's located in `C:\Work\TIE-50307-course-vm` in TC219 workstations.
The username and (very secure) password for the VM account are: `student`/`student`.


**WARNING**: be aware that **files on the VM will be erased at each reboot**, commit and push your work to your remote repository (or save your important files to an external drive) before rebooting the VM.

**REMINDER**: we strongly recommend you to add & commit your changes after each step (or even more frequently): saving your work and being able to revisit what you did and in what order is way more important than having a tidy git history. We are not going to evaluate your weekly exercises on the basis of the git history, but if we were to, several micro-commits would definitely look better than a single macro-commit pushing in one go all the changes and results of your task.


# Resources and reading material

- Resuming your work...
  - [course_upstream repo][course_upstream] *(instructions on how to clone your personal repository, new instructions and materials for the exercise of this week)*
  - [Git Submodules Manual][Git_Submodules]
  - [**Lectures on Moodle**][moodle.COMP.CE.460] *(the 2nd guest lecture is particularly relevant)*
  - [meta-pynq layer repository][meta-pynq]
- Yocto-related resources *(just for reference, they are not particularly relevant this week)*
  - [Yocto Development Manual][YoctoDEVMAN:cha4]
  - [BitBake User Manual][bitbakeUSRMAN]
  - [Yocto Reference Manual][YoctoREFMAN]
  - [*Embedded Linux Systems With the Yocto Project* (2016)][book:YOCTO:2016]
  - [Yocto Project Linux Kernel Dev Manual (C#2.10: *Working with Out-of-Tree Modules*)][YoctoKDEVMAN:sec2.10]
- Developing Kernel Drivers & Linux Internals
  - [***linux-insides***][book:linux-insides] *(A book-in-progress about the linux kernel and its insides.)*
  - [***Linux device drivers development*** (2017)][book:LDDD:2017]
  - [***Linux Device Drivers (3rd ed.)*** (2005)][book:LDD3:2005]
  - [*Linux Kernel Development (3rd ed.)* (2010)][book:LKD:2010]
  - *seminar presentations from the last weeks*
  - Familiarize with `ioremap`, `ioread32`, `iowrite32`, and `linux/bitfield.h` to work with bitfields in HW device registers
  - [About Linux IRQ numbers and HW IRQ numbers](../04/finding_the_Linux_IRQ_number.md)
  - [ERRNO manpage, for selecting proper error codes][man:3:errno]
- Reference documents and manuals for the course project
  - [IRQ generator v1.1 FPGA core guide](../04/irq_generator_v1_1.pdf)
  - [Devicetree Specification v0.2][devtree-spec]

# Checklist

- **BEFORE STARTING**:
  - We are going to work partially on the Windows Host (Vivado development) and partly on the Linux VM (Yocto development): you will clone the repository inside the VM as usual, but, **BEFORE BUILDING ANYTHING**, you will have to copy the repository from the VM to `C:\Temp` in the Windows Host.

- [ ] preparations to resume your work (inside the VM)
  - [ ] clone your repository, <u>with its submodules and LFS data!</u>
    - **Hint**: check the updated instructions in the main README of [course_upstream]
  - [ ] pull the changes published in [course_upstream]
  - [ ] <u>**IMPORTANT**</u>: use VMWare Shared Folders or an external drive to copy the repository **AT THIS POINT** from inside the VM to `C:\Temp` in the Windows Host
  - [ ] remember to specify the path for the proper `build` folder when sourcing the Yocto script for setting up the build environment
  - [ ] build `core-image-minimal` once again, to verify that everything works.

*BONUS*
- [ ] set up new project in Vivado (on the Windows Host)
  - **WARNING**: Create and save your project in your `P:` drive, **NOT** in the repository
  - [ ] Copy the board definition files to the Vivado project folder and select PYNQ as a target.
  - [ ] Import the IP block sources
    - **WARNING**: DO **NOT** COPY THE SOURCE FILES INSIDE THE VIVADO PROJECT.
  - [ ] Add the design testbench to Vivado
  - [ ] Add the IRQ latency counter register and the logic in the Verilog code
  - [ ] Validate your design with given testbench
  - [ ] Generate bitstream of your project (see [this file](vivado_irq_project.md))
  - [ ] Locate and copy the newly created .bit file to SD card as "Bitstream"
  - [ ] Commit and push your changes from the clone in `C:\Temp` to your repository on `course_gitlab`
*BONUS*

- Update Yocto project (inside the Linux VM)
  - [ ] **Pull the new commits from your repository on `course_gitlab`**
  - [ ] Edit the driver from the previous exercise to read the newly implemented latency counter
  - [ ] BitBake your image
  - [ ] Test your new driver functionality
    - [ ] Check your latency when unloading the module
    - [ ] Check the difference in latency in normal module and debug module
  - [ ] Commit and push your changes from the VM clone to your repository on `course_gitlab`.

- [ ] <u>**remeber to push all your commits to your remote repository from your clone in the Windows Host**</u>
- [ ] <u>**remeber to push all your commits to your remote repository from your clone in the Linux VM**</u>
- [ ] demonstrate to the TA
- [ ] <u>remember to remove your repository clone form `C:\Temp`</u>
- [ ] <u>remember to recover your microSD card before leaving</u>
- [ ] edit `exercises/05/questions.md` to provide your answers


[course_upstream]: https://course-gitlab.tuni.fi/comp.ce.460-real-time-systems_2020-2021/course_upstream
[Git_Submodules]: https://git-scm.com/book/en/v2/Git-Tools-Submodules
[YoctoQS]: https://www.yoctoproject.org/docs/2.4.3/yocto-project-qs/yocto-project-qs.html
[moodle.COMP.CE.460]: https://moodle.tuni.fi/course/view.php?id=9860
[YoctoDEVMAN:cha4]: https://www.yoctoproject.org/docs/2.4.3/dev-manual/dev-manual.html#extendpoky
[YoctoREFMAN]: https://www.yoctoproject.org/docs/2.4.3/ref-manual/ref-manual.html
[YoctoKDEVMAN:sec2.10]: https://www.yoctoproject.org/docs/2.4.3/kernel-dev/kernel-dev.html#working-with-out-of-tree-modules
[bitbakeUSRMAN]: https://www.yoctoproject.org/docs/2.4.3/bitbake-user-manual/bitbake-user-manual.html
[PYNQ-Z1-REFMAN]: https://reference.digilentinc.com/_media/reference/programmable-logic/pynq-z1/pynq-rm.pdf
[meta-pynq]: https://course-gitlab.tuni.fi/comp.ce.460-real-time-systems_2020-2021/meta-pynq
[devtree-spec]: https://github.com/devicetree-org/devicetree-specification/releases/tag/v0.2
[man:3:errno]: http://man7.org/linux/man-pages/man3/errno.3.html
[book:LDDD:2017]: https://andor.tuni.fi/permalink/358FIN_TAMPO/1j3mh4m/alma9911130510505
[book:LDD3:2005]: https://andor.tuni.fi/permalink/358FIN_TAMPO/1kfmqvo/alma991068843520
[book:LKD:2010]: https://andor.tuni.fi/permalink/358FIN_TAMPO/1kfmqvo/alma9910687662305
[book:YOCTO:2016]: https://andor.tuni.fi/permalink/358FIN_TAMPO/1kfmqvo/alma9925685753059
[book:linux-insides]: https://0xax.gitbooks.io/linux-insides/content/index.html
