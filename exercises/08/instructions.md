# Introduction

This is the last exercise of the course. Now that our driver is finished, we are ready to experiment with the RT_PREEMPT patchset, and compare the differences between the regular Linux environment and this Real-Time solution.

The development tasks are somewhat limited this week, but you will have to spend more time in measuring and analyzing.
Another difference in this exercise is that you are required to start answering to the exercise questions since the beginning.

We will use the same Ubuntu virtual machine (which already includes all the required prerequisites to successfully build the Yocto Project).
It's located in `C:\Work\TIE-50307-course-vm` in TC219 workstations.
The username and (very secure) password for the VM account are: `student`/`student`.

**WARNING**: be aware that **files on the VM will be erased at each reboot**, commit and push your work to your remote repository (or save your important files to an external drive) before rebooting the VM.

**REMINDER**: we strongly recommend you to add & commit your changes after each step (or even more frequently): saving your work and being able to revisit what you did and in what order is way more important than having a tidy git history. We are not going to evaluate your weekly exercises on the basis of the git history, but if we were to, several micro-commits would definitely look better than a single macro-commit pushing in one go all the changes and results of your task.

# Resources and reading material

- Resuming your work...
  - [course_upstream repo][course_upstream] *(instructions on how to clone your personal repository, new instructions and materials for the exercise of this week)*
  - [Git Submodules Manual][Git_Submodules]
  - [**Lectures on Moodle**][moodle.COMP.CE.460] *(check the presentations about Real-Time Linux and alternatives)*
  - [meta-pynq layer repository][meta-pynq]
- Yocto-related resources
  - [Yocto Development Manual][YoctoDEVMAN:cha4]
  - [BitBake User Manual][bitbakeUSRMAN]
  - [Yocto Reference Manual][YoctoREFMAN]
  - [*Embedded Linux Systems With the Yocto Project* (2016)][book:YOCTO:2016]

# Checklist

- [ ] preparations to resume your work
  - [ ] clone your repository, <u>with its submodules and LFS data!</u>
    - **Hint**: check the updated instructions in the main README of [course_upstream]
  - [ ] pull the changes published in [course_upstream] using the provided script
  - [ ] remember to specify the path for the proper `build` folder when sourcing the Yocto script for setting up the build environment
  - [ ] build `core-image-minimal` once again, to verify that everything works.
- **DO NOT USE `irqgen_dbg` for this exercise, stick to the non debug version for any measurement**
- Answer question 1
- Answer question 2 (use [this script](../07/statistics_app/measuring.sh) to collect the measurements, ignore the "buffer too small" warnings)
- [ ] In `meta-tie50307`, extend the `linux-xlnx` recipe with a `.bbappend` file
  - [ ] Append as a source the provided `rt.conf`
  - [ ] Append as a source, using an https link, the RT_PREEMPT patch archive
    - Pick the URL from [here](https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/), matching your kernel version
    - Prefer a .patch.xz file
  - [ ] Include the SHA256SUM for both files to ensure integrity check
  - [ ] Bitbake `core-image-minimal` as usual
- [ ] Answer questions 3, 4 and 5
- Enable local network [connection](lab_nic_setup.md)
- Familiarize with the contents of [scripts/](./scripts/)
- Run [scripts/testandplot.sh](scripts/testandplot.sh) in the following scenarios (for each save the csv, the metadata and the plot in the repository. You might want to reboot the PYNQ board in-between runs):
  - RT Linux, delay=0, no torture
  - RT Linux, delay=0, torture
  - no-RT Linux, delay=0, no torture
  - no-RT Linux, delay=0, torture
- Answer questions 6 & 7
- We will now flood the system with IRQs (e.g., commenting out the acknowledgment step in the interrupt handler):
  - try this both on the RT and non-RT image, then answer question 8 and 9
- Prepare a 2-slide presentation, including the 8 plots above: the demo will consist in a few questions about comparing the results (add this presentation as a PDF in this same folder)
- [ ] <u>**remember to push all your commits to your remote repository**</u>
- [ ] <u>remember to recover your microSD card before leaving and restoring the original network cable setup</u>


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
[yocto-sdk-manual]: https://www.yoctoproject.org/docs/2.4.3/sdk-manual/sdk-manual.html
[sdk-archive]: ../../build/tmp/deploy/sdk/poky-glibc-x86_64-core-image-minimal-cortexa9hf-neon-toolchain-2.4.3.sh
