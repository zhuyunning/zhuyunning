#!/usr/bin/env python

"""
A filter that convert input to lower case.
"""
import fileinput

def process(line):
    """for each line of input, lower case it."""
    print (line.lower())
    
for line in fileinput.input():
    process(line)
    
    
