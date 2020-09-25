# Exercise 01 - Q&A

## 1. What did you accomplish in this exercise?
The main task in this exercise was set-up Yocto environment. 


## 2. How does Yocto recognize that the target machine "pynq" is supported?
The yocto support these kinds of extensions called meta layers, which could add support for extra platforms and properties. These meta layers (and them locations) are told to Yocko in configuration file /build/conf/bblayers.conf .


## 3. Where do you find the device-tree source code for the PYNQ board?
From meta layer called meta-pynq. In the path meta-pynq/recipes-bsp/device-tree/files/devicetree.dts

## 4. What is the priority of the PYNQ support layer?
Using command bitbake-layers show layers shows that the priority of meta-pynq is 5.


## 5. What additional applications are installed to the `core-image-minimal` target in the PYNQ support layer?
The meta-pynq layer describes only the machine-specific packages to get the hardware boot, so it doesnt add any "application" to the image as users perspective. This can be examined looking at the meta-pynq config file /meta-pynq/conf/machines/pynq.conf which includes clobal variables like MACHINE_FEATURES, EXTRA_IMAGEDEPENDS, SERIAL_CONSOLE and MACHINE_ESSENTIAL_EXTRA_RDEPENDS. 

MACHINE_FEATURES describes what features the machine supports, but might not be included by default. The other listed variables describe the packages which are essential to machine boot up.
