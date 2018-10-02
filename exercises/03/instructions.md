# Introduction

The goal of this third exercise session is to start honing your skills in developing and debugging Linux kernel code.

In our *The Life of a System Engineer* simulation, after creating our first Yocto layer and a fresh HelloWorld Out-of-Tree Loadable Kernel Module (LKM), we start looking at more complex modules.

The colleague that is supervising our training just gave us the sources of a kernel driver to study and review.
It's October already, and the Halloween frenzy has taken hold of the office: of course she gave us a spooky evil module filled with intentionally nasty bugs.

The kernel module comes in a new dedicated Yocto layer `meta-tie50307`, which includes recipes for the `evil` LKM, for ad-hoc tests and to alter the `core-image-minimal` target to include these two packages in the image.
- `meta-tie50307` will be part of each group repository (rather than being another submodule): we will be using this layer for future tasks, so we should avoid conflicting changes. **For this exercise you are supposed to alter only the C source code for the `evil` LKM, do not modify any other file inside `meta-tie50307`.**

For this exercise the checklist will be somewhat short, as most of the actual technical requirements are detailed by the `evil-tests` script included in `meta-tie50307`: it contains both the tests and contextual comments to explain what each step tries to verify.

There isn't a spec document for what the `evil` module is supposed to do, nor for its design.
This is intentional, to simulate what often happens with poorly documented real-world drivers and to stimulate you to understand what the actual implementation does, as often there will be a gap between outdated specs and documentation and the actual implementation.
As a System Engineer, when porting an existing driver to a newer kernel version, fixing poorly maintained vendor-provided modules, or writing your own kernel module using an existing one as a starting point, being familiar with typical LKM designs and with kernel debugging and troubleshooting will be among your core skills.

**The guideline in *fixing* the `evil` module source code is to limit yourself to fixing bugs, don't add new features and avoid any major redesign.
You're not allowed to change `evil-tests`, so the expected behavior of `evil` cannot be changed, even if you may feel the urge to improve it.**

**Comments in both `evil.c` and `evil-tests` constitute the primary source of documentation for the driver.**

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


# Checklist

- [ ] preparations to resume your work
  - [ ] clone your repository, <u>with its submodules and LFS data!</u>
    - **Hint**: check the updated instructions in the main README of [course_upstream]
  - [ ] pull the changes published in [course_upstream]
  - [ ] remember to specify the path for the proper `build` folder when sourcing the Yocto script for setting up the build environment
  - [ ] add the `meta-tie50307` layer to your build configuration
  - [ ] build `core-image-minimal` once again, to verify that the `SSTATE_MIRRORS` and `DL_DIR` are correctly accelerating the build process
- [ ] find the `evil` module C source code and the associated testing script: study them to understand what the `evil` module does
- [ ] add yourselves as additional authors in `evil.c`
- Reiterate the following **until passing all the steps in `evil-tests`**:
  - [ ] boot the PYNQ board, login to the console (usr:`root`, no passwd), load the `evil` module and run the `evil-tests` script
  - [ ] edit (**only!!!**) `evil.c`
  - [ ] rebuild `core-image-minimal` and deploy the updated images to the microSD card
- [ ] <u>**remeber to push all your commits to your remote repository**</u>
- [ ] demonstrate to the TA
- [ ] <u>remember to recover your microSD card before leaving</u>
- [ ] edit `exercises/03/questions.md` to provide your answers



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
[book:linux-insides]: https://0xax.gitbooks.io/linux-insides/content/index.html
