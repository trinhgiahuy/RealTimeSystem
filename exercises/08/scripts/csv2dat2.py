#!/usr/bin/env python

import fileinput

base_ts=None

for line in fileinput.input():
    if line.strip() != "":
        lirq,latency,ts=line.split(",")
        latency=int(latency); ts=int(ts)

        if base_ts is None: base_ts=ts
        ts=ts-base_ts

        print ts, latency
    else:
        base_ts=None
        print "\n"
