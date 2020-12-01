#!/usr/bin/env python

import math
import fileinput

bottom = None
top = 0
for line in fileinput.input():
    if line.strip() != "":
        latency=int(line.split(",")[1])

        if bottom is None:
            bottom = latency
        elif latency < bottom:
            bottom = latency
        if latency > top:
            top = latency

p10_b=math.pow(10, math.floor(math.log(bottom,10)))
p10_t=math.pow(10, math.ceil(math.log(top,10)))


print bottom, top, p10_b, p10_t
