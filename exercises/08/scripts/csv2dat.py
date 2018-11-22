#!/usr/bin/env python

import fileinput

for line in fileinput.input():
    if line.strip() != "":
        latency=line.split(",")[1]
        print latency,
    else:
        print "\n"
