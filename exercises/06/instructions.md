# Introduction

In this exercise we will resume the driver development started in EX04, to support a custom device, in this case represented by an FPGA IP block that can be setup to generate interrupt requests (IRQs).

In our *The Life of a System Engineer* simulation, until now we got a first implementation that *Just Works* but is still a bit hackish: we hardcoded addresses and IRQ ids, we don't support the devicetree description and only support one IRQ line.
In this exercise we will work incrementally on the previous results, aiming at doing the *Right Thing*.
Our device is a non-hot-pluggable and non-discoverable device: this should immediately call for a **platform driver** and support for a description of the platform devices through a **devicetree**.
This is what we will do this week.

While we are at it, we will also learn about *Devres* or *Device-managed resources*, as they are a best practice, offloading the deallocation and intricacies of the error handling paths to the kernel device model: it's a great help also because many times subtle bugs can hide in these code sections when handled manually.

To speed up the process, rather than starting from scratch, you are going to work on a stub driver implementation that provides a structure but leaves to be implemented the core functionality, and you will copy-paste part of your solution to EX04 to fill the gaps.

Your task, in short, is to fill the stub with the right functionality by resolving every FIXME and TODO included in the source files.

The kernel module comes in a the `meta-tie50307` Yocto layer, under `recipes-kernel/irqgen-mod`.
- `meta-tie50307` will be part of each group repository (rather than being another submodule): we will be using this layer for future tasks, so we should avoid conflicting changes.
- **For this exercise you are supposed to alter only `irqgen.c` and `irqgen_addresses.h`, and the contents of `meta-tie50307/recipes-bsp/device-tree`. Do not modify any other file inside `meta-tie50307`.**

For this exercise the checklist will be somewhat short, as most of the actual technical requirements are detailed in the source code and in [a separate instruction file](platform_device_driver.md).

The spec document for the IRQ Generator module is included in the same folder where you found these instructions and contains important informations you will need to solve this exercise.

**NOTE:** you will be using the `bitstream` you generated in EX05, which should now be feature complete w.r.t. the IRQ Generator Spec.

**The guideline in *completing* the *stub* module source code is to limit yourself to fix only the items highlighted by FIXME and TODO comments. While you progress, you should remove the FIXME/TODO commets to keep track of your progress. Don't add new features and avoid any major redesign.**

As usual, rather than providing step-by-step instructions, we provide a list of reading materials and resources you should familiarize with in order to solve the task at hand.

We will use the same Ubuntu virtual machine (which already includes all the required prerequisites to successfully build the Yocto Project).
It's located in `C:\Work\TIE-50307-course-vm` in TC219 workstations.
The username and (very secure) password for the VM account are: `student`/`student`.

**WARNING**: be aware that **files on the VM will be erased at each reboot**, commit and push your work to your remote repository (or save your important files to an external drive) before rebooting the VM.

**REMINDER**: we strongly recommend you to add & commit your changes after each step (or even more frequently): saving your work and being able to revisit what you did and in what order is way more important than having a tidy git history. We are not going to evaluate your weekly exercises on the basis of the git history, but if we were to, several micro-commits would definitely look better than a single macro-commit pushing in one go all the changes and results of your task.


# Resources and reading material

- Resuming your work...
  - [course_upstream repo][course_upstream] *(instructions on how to clone your personal repository, new instructions and materials for the exercise of this week)*
  - [Git Submodules Manual][Git_Submodules]
  - [**Lectures on Moodle**][moodle.COMP.CE.460] *(check the presentations about device-tree and platform device drivers)*
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
  - Familiarize with `ioremap`, `ioread32`, `iowrite32`, and `linux/bitfield.h` to work with bitfields in HW device registers
  - *Platform device drivers*
    - [Kernel doc](https://github.com/Xilinx/linux-xlnx/blob/xlnx_rebase_v4.9/Documentation/driver-model/platform.txt)
    - **[Detailed instructions on the platform driver task](../06/platform_device_driver.md)**
  - *Device-managed resources*
    - [Kernel docs](https://github.com/Xilinx/linux-xlnx/blob/xlnx_rebase_v4.9/Documentation/driver-model/devres.txt)
    - [Interesting slides](http://haifux.org/hebrew/lectures/323/haifux-devres.pdf)
  - [ERRNO manpage, for selecting proper error codes][man:3:errno]
- Reference documents and manuals for the course project
  - [IRQ generator v1.1 FPGA core guide](../04/irq_generator_v1_1.pdf)
  - [Devicetree Specification v0.2][devtree-spec]

# Checklist

- [ ] preparations to resume your work
  - [ ] clone your repository, <u>with its submodules and LFS data!</u>
    - **Hint**: check the updated instructions in the main README of [course_upstream]
  - [ ] pull the changes published in [course_upstream] using the provided script
  - [ ] remember to specify the path for the proper `build` folder when sourcing the Yocto script for setting up the build environment
  - [ ] build `core-image-minimal` once again, to verify that everything works.
- [ ] remember to write the `bitstream` file from EX05 to the microSD root.
- [ ] find the `irqgen` module C source code and study it referring to the spec document for the IRQ Generator IP block.
- [ ] add yourselves as additional authors
- [ ] familiarize with:
  - *Platform device drivers*
    - [Kernel doc](https://github.com/Xilinx/linux-xlnx/blob/xlnx_rebase_v4.9/Documentation/driver-model/platform.txt)
  - *Device-managed resources*
    - [Kernel docs](https://github.com/Xilinx/linux-xlnx/blob/xlnx_rebase_v4.9/Documentation/driver-model/devres.txt)
    - [Interesting slides](http://haifux.org/hebrew/lectures/323/haifux-devres.pdf)
- [ ] follow the **[detailed instructions on the platform driver task](../06/platform_device_driver.md)**
- Reiterate the following **until all the required functionality has been implemented and tested**:
  - [ ] boot the PYNQ board, login to the console (usr:`root`, no passwd), load the `irqgen`/`irqgen_dbg` module and test its functionality (load, unload, error handling, check and experiment with `/sys/kernel/irqgen/*`)
  - [ ] edit (**only!!!**) `irqgen.c` and `irqgen_addresses.h`
  - [ ] rebuild `core-image-minimal` and deploy the updated images to the microSD card
- [ ] <u>**remember to push all your commits to your remote repository**</u>
- [ ] demonstrate to the TA
- [ ] <u>remember to recover your microSD card before leaving</u>
- [ ] edit `exercises/06/questions.md` to provide your answers


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
