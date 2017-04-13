#!/usr/bin/env python

import fileinput
import re

def process(line):
    """for each line of input, split it into one word per line."""
    words=re.compile('\w+')
    line=words.findall(line)
    for word in line:
        if len(word)>=2:
           print (word)

for line in fileinput.input():
     process(line)
