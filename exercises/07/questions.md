# TIE-50307 - Exercise 07 - Q&A

## 1. What is the goal of this exercise? What did you accomplish?
To familiarize the terms of character device driver and character device file. Also take a small brief of yocto's cross compiling capabilities.

## 2. What is a Character Device? How is it different from a Block Device?
It's a device which is accessed as stream of bytes. The block systems can only be accessed as block(s), eg. 512 bytes of data at a time.

## 3. What design limits of the Ex6 version of `irqgen-mod` do we try to address adding a character device?
To add a proper way for user space application to communicate with the device.

## 4. What system calls are we implementing for the filesystem representation of our character device?
open, read and close

## 5. How does a device node differ from a regular file? What things are similar/identical?
"normal" files are real, thus they represent some data in some actual location. So eg. reading those files actually reads the data stored in them location. On the other hand the device node is a virtual, so it doesnt hold any static data in some static location (but its accessed using the same system calls, so it shows for user side pretty similar) but it (or the mechanics behind it) generates the needed information on the fly.

## 6. Which parts of our LKM code are potentially running in parallel? Which parts could interact in a conflicting way? Make a few concrete examples of conditions in which conflicts in concurrency may arise.
The shared data portition (irqen_data). There might happen some strange behauviour if irq_handler is updating the data values at the same time when the user application tries to read them via dev/irqgen.

## 7. In the proposed structure, we opted for a single lock for the whole `irqgen_data` structure. Could you describe advantages and disadvantages of a single lock vs several locks? What about the effects on the IRQ handling latency?
Locking the whole chunk might be the easiest way, but not the most optimal. As now there is some code running inside the chunk, which doesn't needed to be locked. The locking still takes some time, so using more locks in smaller portitions might increase the IRQ handling latency and so it wouldn't be any better solution.

## 8. To avoid concurrency issues among the different parts of `irqgen-mod` you had to choose a synchronization mechanisms. What kind did you choose? Why? Where? What alternatives did you consider? Why did you reject them?
Spinlocks. The others would have been mutexes and semaphores, but because the code runs in atomix contex, the spinlocks needs to be used. [1]

## 9. To optimize even more the IRQ handling latency we should abandon the monolithic handler function for a more efficient pattern: what's its name? Describe how the code currently handling the requests would be organized and describe a few reasons to choose the alternative over the monolithic style.
Bottom-halves.
The top-halve should include the time-sensiting and other critical parts of irqhandler, maybe get the timestamp (to precisely get the proper timemark) and irqgen physical registers read and write operations, and thus acknowledging the interrupt. All the other things, like irqgen data-field updates can be left to the bottom part, as they arent so time critical and can be interrupted by interrupts if needed.

## 10. What is an SDK?
Software Development Kit. It includes all the facilities (eg. compiler) to develop software to some specific target.

## 11. In the context of the Yocto Project, what are the differences between the Standard and the Extensible SDK?
eSDK has tools to easier integration for new sources and applications to the image. It also include facilities of "modify the source of an existing component, test changes on the target hardware, and easily integrate an application into the OpenEmbedded build system" [2].

## 12. Describe your workflow in developing and testing the `irqgen_statistics` app
I used basic gcc <filene.c> command to compile the source for development machine architecture and tested it on the develpoment machine using both manual inputs and the output generated from pynq. After getting it working properly the final cross compiled version could been compiled and copied to the pynq sdcard and verified that the program works in the pynq also.

## 13. Feedback (what was difficult? what was easy? how would you improve it?)
Writing the old C application all the way from the beginning was time consuming, as I hadn't much experience of C (versus C++) which has lack of string, map, vector etc. handy things. 


[1] Linux device drivers development (2017)
[2] Yocto Project Application Development and the Extensible Software Development Kit (eSDK)
    https://www.yoctoproject.org/docs/current/sdk-manual/sdk-manual.html
