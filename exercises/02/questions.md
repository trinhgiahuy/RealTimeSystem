# TIE-50307 - Exercise 02 - Q&A

## 1. What is the goal of this exercise? What did you accomplish?
To learn how to create own kernel module and include it to linux image using Yocto.


## 2. What is a Yocto layer? What are the essential requirements to correctly define a new one?
Yocto provides image customization with layers. Keeping addidions in different layers, allows keeping them isolated from each others. Att minimum, a layer consists of meta-folder, conf-folder inside it and layer.conf-file inside the conf-folder. There are also other guidelines which should be officially followed, like layer meta-folder should include README-file.

## 3. What priority did you assign to your layer? How and why?
I used 'bitbake-layers create-layer' script to create the base layer, which sets the layer priority to 6 by default. Thinking about it, the priority might be lower, as our layer (at least in this case) isn't very critical for the system.

## 4. What does LKM stand for (in the context of this exercise)? What does it mean and what are the characteristics of a LKM? What's the alternative?
LKM (Loadable Kernel Module) is an "extension" to kernel, which can be (as the name tells) loaded and undloaded in/from the kernel on-the-go. LKM:s are often device drivers. LKM:s are handy, because them can be loaded when needed and undloaded when worthwhile to free up system resourses. The older "legacy" approach is called static module. Static modules are added inside the kernel image during build process, so the whole kernel needs to be recompiled (and system rebooted) if changes are made to the static kernel module.

## 5. What does Out-of-Tree Module mean? What's the alternative and what are the differences?
Out-of-Tree module means, that the module's source code is not inside the kernel source tree. Therefore the module needs to be build "against" the specific kernel source, which the target device is using. The alternative is in-tree module, on which the module's source code lies inside the kernel source tree.

## 6. How did you define the module metadata? How does it work?
Using MODULE_VERSION, MODULE_AUTHOR, MODULE_LICENSE etc. macros in module source code. These macros are used via #include <linux/module.h header> in top of the source.

## 7. How is the module built? How does it get installed inside `core-image-minimal`?
Build using 'bitbake kernel-module-hello'. To include the module to the core-image-minimal, I added the string 'kernel-module-hello' to variable MACHINE_ESSENTIAL_EXTRA_RDEPENDS inside meta-pynq pynq.conf file.

## 8. What is the path for the `sysfs` entry for the module? List and explain its contents.
/sys/modules/hello, which contain folders: corensize, holders, initsize, initstate, notes, parameters, refcnt, sections, srcversion, taint, uevent and version. The sysfs is a virtual file system, which includes files for each devices and running modules. The files works like bridge between user space and kernel space, where both kernel-space and user-space programs can exchange small amount of data like attributes, hardware device parameters and status information.

## 9. Feedback (what was difficult? what was easy? how would you improve it?)
As mentioned on the course materials, these exercises are made to mimic real world situation. That shows thus that it takes hours and hours to just read the material and consepts behind the exercise task and progression of the exercise was very slow. Maybe there could be some information/hints of what the final "thing" (config file, source code etc..) should look. As now it creates a lot uncertainty when you cant be sure are you even reading right topics, and maybe using a lot of time reading even wrong topics.
