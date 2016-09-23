#!/usr/bin/env python

import fileinput
import re


def process(line):
    """for each line of input, remove my stopwords."""
    line=re.findall(r'\w+',line)
    mystopwords=['a','an','and','about','all','as','at','any','also','are']
    
    for word in line:
        if word not in mystopwords:
           print(word.strip())

for line in fileinput.input():
     process(line)


