# Introduction

The goal of this second exercise session is to start building on top of the bare infrastructure we setup last time.

In our *The Life of a System Engineer* simulation, after finally managing to actually get the board booting Linux, we want to start adding support for ad-hoc peripherals and/or IP blocks that are required for our project.

It's still one of our first days at work, and we never wrote a kernel driver before: we will *build on the shoulders of giants* and like many others before us, we start with an *Hello World* version of a kernel module.

While describing the details of our task, our more senior colleagues mentioned, among other things, **Out-of-Tree Modules** and **Loadable Kernel Modules (LKM)**, and recommended reading about it before starting: knowledge about these terms and their meaning will help navigate through Google results, as they report that there are basically two ways of writing the kernel module among the most popular results, both are supposed to work, but one is considered *legacy* (> 10 years ago) and almost *deprecated*, while the other is more modern and tidy and abides to the current code style and guidelines for kernel (driver) development.
*(they sent you an email with some specific links, collected in the section below)*

On top of developing the `hello` LKM, you will have to create your personal Yocto layer to apply your changes on top of the upstream PYNQ BSP layer (i.e., `meta-pynq`).

As usual, rather than providing step-by-step instructions, we provide a list of reading materials and resources you should familiarize with in order to solve the task at hand.

We will use the same Ubuntu virtual machine (which already includes all the required prerequisites to successfully build the Yocto Project).
The username and (very secure) password for the VM account are: `student`/`student`.

**WARNING**: be aware that **files on the VM will be erased at each reboot**, commit and push your work to your remote repository (or save your important files to an external drive) before rebooting the VM.

**REMINDER**: we strongly recommend you to add commit your changes after each step (or even more frequently): saving your work and being able to revisit what you did and in what order is way more important than having a tidy git history. We are not going to evaluate your weekly exercises on the basis of the git history, but if we were, several micro-commits would definitely look better than a single macro-commit pushing in one go all the changes and results of your task.


# Resources and reading material

- Resuming your work...
  - [course_upstream repo][course_upstream] *(updated instructions on how to clone your personal repository and these instructions)*
  - [Git Submodules Manual][Git_Submodules]
  - [Lectures on Moodle][moodle.COMP.CE.460]
  - [meta-pynq layer repository][meta-pynq]
- Creating a Yocto Layer
  - [Yocto Development Manual (C#4: *Common Tasks*)][YoctoDEVMAN:cha4] *(especially sections from 4.1 to 4.3 on how to create layers, recipes and customizing images)*
  - [BitBake User Manual][bitbakeUSRMAN]
  - [Yocto Reference Manual][YoctoREFMAN]
  - [*Embedded Linux Systems With the Yocto Project* (2016)][book:YOCTO:2016]
- Developing Kernel Drivers
  - **rembember what your colleagues said about finding the proper modern way of preparing the LKM**
  - [Yocto Project Linux Kernel Dev Manual (C#2.10: *Working with Out-of-Tree Modules*)][YoctoKDEVMAN:sec2.10]
  - [*Writing a Linux Kernel Module — Part 1: Introduction* (very nice blog post from the author of the book "*Exploring BeagleBone*")](http://derekmolloy.ie/writing-a-linux-kernel-module-part-1-introduction/)
  - [*Writing a Linux Kernel Module* (a tutorial from the SIGOPS group at ACM@UIUC)](https://www-s.acm.illinois.edu/sigops/pages/tutorials/lkm.html)
  - [***Linux device drivers development*** (2017)][book:LDDD:2017]
  - [***Linux Device Drivers (3rd ed.)*** (2005)][book:LDD3:2005]
  - [*Linux Kernel Development (3rd ed.)* (2010)][book:LKD:2010]


# Checklist

- [ ] preparations to resume your work
  - [ ] clone your repository, <u>with its submodules and LFS data!</u>
    - **Hint**: check the updated instructions in the main README of [course_upstream]
  - [ ] pull the changes published in [course_upstream]
  - [ ] update the `meta-pynq` submodule to its latest revision (check the [Git Submodule Manual][Git_Submodules] )
  - [ ] consult the *Yocto Reference Manual* about the `DL_DIR` variable, check once more the contents of `/opt/poky_cache/`, and enable this option
  - [ ] try to build `core-image-minimal` again and verify that the `SSTATE_MIRRORS` and `DL_DIR` are correctly accelerating the build process
  - [ ] *(optional, but recommended)* prepare a script (e.g., `<STUDENT_REPO_ROOT>/scripts/deploy_images`) to deploy the files needed to boot the PYNQ board on the memory card
  - [ ] verify the board still boots to the console
- [ ] read in advance the questions for this exercise and familiarize with the linked resources
- [ ] create a new Yocto layer `meta-group??` (replacing `??` with your group number)
  - it should be created at `<STUDENT_REPO_ROOT>/`
  - it must be part of the student group repository, **not a separate submodule**
  - add it to the build env configuration
- [ ] create a new recipe in the new layer for a simple *Hello World* module (you can use the Yocto template) and configure the layer to append it to the target image
  - [ ] build, deploy and boot to the console to verify that the new recipe and the new layer are working correctly
- [ ] improve the kernel module from the template
  - it must follow current code style and guidelines
  - it must include metadata for version, authors (<u>both members of the group should be separately reported</u>), license, and description
  - it must greet when loading and when unloading
  - it must support a load-time parameter to personalize the default greetings
- [ ] <u>**remeber to push all your commits to your remote repository**</u>
- [ ] build, deploy and boot to the console
- [ ] prepare for TA demonstration
  - [ ] module load/unload
  - [ ] module metadata
  - [ ] load-time parameter
  - [ ] find the entry for the module in `sysfs`: familiarize with the meaning of the exposed hierarchy pf files in the `sysfs` subdirectory for the module
- [ ] demonstrate to the TA
- [ ] <u>remember to recover your microSD card before leaving</u>



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
[book:LDDD:2017]: https://andor.tuni.fi/permalink/358FIN_TAMPO/1j3mh4m/alma9911130510505
[book:LDD3:2005]: https://andor.tuni.fi/permalink/358FIN_TAMPO/1kfmqvo/alma991068843520
[book:LKD:2010]: https://andor.tuni.fi/permalink/358FIN_TAMPO/1kfmqvo/alma9910687662305
[book:YOCTO:2016]: https://andor.tuni.fi/permalink/358FIN_TAMPO/1kfmqvo/alma9925685753059
