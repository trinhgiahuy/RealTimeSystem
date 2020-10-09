# TIE-50307 - Exercise 03 - Q&A

## 1. What is the goal of this exercise? What did you accomplish?
The goal was to get in to linux kernel development, basic memory management which needs more attention than in user space etc..

## 2. Where is the `evil-tests` script installed inside the image? Where is the accompanying data installed? Describe how this is set up in Yocto.
script: /opt/evil-tests/sbin/evil-tests.sh
data: /opt/evil-tests/share/data.txt
The behauvior of installing these extra files are descriped in evil-tests.bb file, which has yocto's variable do_install. 

## 3. How are the LKM and `evil-tests` added to `core-image-minimal`? Briefly describe what sets apart the `evil-tests` recipe compared with most recipes included in `meta-groupXX`, `meta-pynq`, `meta-xilinx` and `poky`.
The evil-tests is not inherit module (shows in file evil-tests.bb), which shows that it doesn't need to be compiled, only installed.

## 4. How many buffers does the `evil` LKM use? List their names, their size and their purpose. How is their memory allocated?
data storage, page size (4kB), place to store inputs, Dynamic allocation using kmalloc

input buffer, 999 bytes, user input is written here before writing to data storage, allocated statically using "input_buf[INPUT_BUFSIZE]". 

## 5. How are user-input strings stored inside the module? How does the module iterate over this list? What's the loop end condition?

The writing to input buffer is done in store_evil() function using sprintf() function. After that, it triggers do_taskelt, which writes the data from input buffer to data storage. The data is stored in string basis, ending to null character. At reading data phase (show_evil), the iteration is ended when all bytes are read based on 'bytes_stored' value.

## 6. What is the path for the `evil` LKM's sysfs entry? How is it determined? How is it mapped to the module functionality?
/sys/kernel/evil_module
The entry is determined using kobject_create_and_add(), which takes a 'kernel_kobj' as parent kobject, so the evil goes under kernel. The sysfs (permissions) shows that the evil can be written and read.

## 7. What bugs did you find/fix? Categorize them and briefly describe each matching *category* (what's the *impact* of each *category*? How common do you *think* it is?)

Tasklet memory allocation. The taskelt struct was pointed, to NULL, so there was no allocated memory for it. Makes the module crash at startup, not so common, as the results are so visble.

Module write permissions. The kobject mode was set to S_IRUGO, which allows only read access. Prevent users write to it. For safety reasons, I think that read-only modules are more coomon, so it might be some way common bug to set write acces, when kreating that kind of module.


Show evil, end reading. There was no proper examination when the data_storage reading should stop (where the data ends). Caused segmentation faul. Can be common, but easily found in tests.

Store evil, check input size. When storing input, there was no check for too big input. Input larger than specified INPUT_BUFSIZE causes buffer overflow, which can be security risk. That kind of bugs can be common, because behaviour might not be easily find in tests.

## 8. What are out-of-bounds accesses and stack overflows? Are they relevant for this exercise? What could be the consequences of such defects in a LKM?
Out-of-bound acces: accessing (eg. arrays) index, which is over the used arrays address space. Is relevant in this exercise, the buffer overflows are that type.

Stack overflow: The address space allocated for stack runs out, so stack pointer runs out of stack bound. I dont think this relevant in this exercise.

Because LKM:s runs in kernel space, which has less supervison than user space, the overflows could have critical consequences. From memory corruption and system crashes to security holes.

## 9. Feedback (what was difficult? what was easy? how would you improve it?)
As previous one, very time consuming. But thats proportional to programming experience. I'm not very experienced programmer (programming 1 and 2 passed) and I calculated about 20-24 hours used in this exercise including these questions.

The perspective, where course gives full code which has bugs, was something different and interesting.
