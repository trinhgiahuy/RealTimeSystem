# TIE-50307 - Exercise 03 - Q&A

## 1. What is the goal of this exercise? What did you accomplish?

## 2. Where is the `evil-tests` script installed inside the image? Where is the accompanying data installed? Describe how this is set up in Yocto.

## 3. How are the LKM and `evil-tests` added to `core-image-minimal`? Briefly describe what sets apart the `evil-tests` recipe compared with most recipes included in `meta-groupXX`, `meta-pynq`, `meta-xilinx` and `poky`.

## 4. How many buffers does the `evil` LKM use? List their names, their size and their purpose. How is their memory allocated?

## 5. How are user-input strings stored inside the module? How does the module iterate over this list? What's the loop end condition?

## 6. What is the path for the `evil` LKM's sysfs entry? How is it determined? How is it mapped to the module functionality?

## 7. What bugs did you find/fix? Categorize them and briefly describe each matching *category* (what's the *impact* of each *category*? How common do you *think* it is?)

## 8. What are out-of-bounds accesses and stack overflows? Are they relevant for this exercise? What could be the consequences of such defects in a LKM?

## 9. Feedback (what was difficult? what was easy? how would you improve it?)
