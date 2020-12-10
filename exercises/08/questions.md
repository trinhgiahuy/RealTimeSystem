# TIE-50307 - Exercise 08 - Q&A

## 1. What is `uname -a` output on the PYNQ board before starting Ex 8?
Linux pynq 4.9.0-xilinx-v2017.3 #1 SMP PREEMPT Thu Oct 1 04:56:32 UTC 2020 armv7l GNU/Linux

## 2. What is the average latency and worst case latency you measure after Ex 7 using the application you developed?
avg: 254,284, worst:4005

## 3. What is `uname -a` output on the PYNQ board after rebooting with the new kernel image?
Linux pynq 4.9.0-rt1-xilinx-v2017.3 #4 SMP PREEMPT RT Thu Dec 3 09:08:20 UTC 2020 armv7l GNU/Linux

## 4. What is the average latency and worst case latency you measure in the new kernel image (same procedure as question 2)?
avg: 925,913, worst:7083

## 5. Compare the results of questions 2 and 4; do they differ significantly? why?
Yes, the RT-batched version has higher delays. The RT-path probably doesn't promise any lower delays, but it makes the variance (jitter) lower for exection times.

## 6. Compare the plots for the 4 different profiles. Describe each of them and compare them?
no RT, no torture: Lowest overall latencies, but there are some very high peaks
no RT, with torture: Compared to above one, the jitter is increased dramatically. Otherwise similar.
RT, no torture: Poorer lowest delay and average delay, but the most dramatic peaks are emitted.
RT, with torture: Similar behauviour than "no RT, with torture", much inreased jitter.


## 7. Document the RT performance differences and their reasons
RT has higher average latency. Thats because RT_PREEMPT runs every interrupt handler in a kernel thread, and thus increases scheduling overhead. The worst latencies are however a bit better.

## 8. Is there any noticeable difference between the two images when saturating the system with IRQ?
No big. In both situations the system keeps up, but in RT the cpu usage is higher.

## 9. Using the information in [scripts/README.txt](scripts/README.txt), try to tune the RT-system to overcome the limits described in the previous question
There is a possibility to change the threads priority between 1-99, but I see no big difference in the behaviour.

## 10. What is the goal of this exercise? What did you accomplish?
To take a look for the RT_PREEMPT patch and a brief instruction how it affecs interrupts.

## 11. Feedback (what was difficult? what was easy? how would you improve it?)

