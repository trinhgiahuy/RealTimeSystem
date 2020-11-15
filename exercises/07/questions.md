# TIE-50307 - Exercise 07 - Q&A

## 1. What is the goal of this exercise? What did you accomplish?

## 2. What is a Character Device? How is it different from a Block Device?

## 3. What design limits of the Ex6 version of `irqgen-mod` do we try to address adding a character device?

## 4. What system calls are we implementing for the filesystem representation of our character device?

## 5. How does a device node differ from a regular file? What things are similar/identical?

## 6. Which parts of our LKM code are potentially running in parallel? Which parts could interact in a conflicting way? Make a few concrete examples of conditions in which conflicts in concurrency may arise.

## 7. In the proposed structure, we opted for a single lock for the whole `irqgen_data` structure. Could you describe advantages and disadvantages of a single lock vs several locks? What about the effects on the IRQ handling latency?

## 8. To avoid concurrency issues among the different parts of `irqgen-mod` you had to choose a synchronization mechanisms. What kind did you choose? Why? Where? What alternatives did you consider? Why did you reject them?

## 9. To optimize even more the IRQ handling latency we should abandon the monolithic handler function for a more efficient pattern: what's its name? Describe how the code currently handling the requests would be organized and describe a few reasons to choose the alternative over the monolithic style.

## 10. What is an SDK?

## 11. In the context of the Yocto Project, what are the differences between the Standard and the Extensible SDK?

## 12. Describe your workflow in developing and testing the `irqgen_statistics` app

## 13. Feedback (what was difficult? what was easy? how would you improve it?)

