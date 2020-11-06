# TIE-50307 - Exercise 05 - Q&A

## 1. What is the goal of this exercise? What did you accomplish?
Maybe the original idea was use vivado and add logic to the fpga IP using vivado, but because of reasons this was a bonus task now. 

## 2. Describe your verilog coding process in 2 paragraphs
-

## 3. How much difference there is in latency between the regular driver build and the debug driver build? Why?

Runnin module with interrupt delay of 125 and amount of 5, we get following handling latencies:
normal: 215 ns
debug: 268957 ns

So debug is about 1251 times slower.

The main reason why debug mode is much, much slower is that it includes kernel message prints. Writing things to the serial buffer and to the serial itself is very slow operation as computers perspective.

## 4. How can you find the base address for the IP block register space in Vivado? Does it match the contents of the devicetree?
-

## 5. Feedback (what was difficult? what was easy? how would you improve it?)
As well known, easy week if bonus task is omitted.