#!/usr/bin/python

import sys

mergedline = ""
list = []
for line in sys.stdin:
    list.append(line.strip())
print(' + '.join(list))
