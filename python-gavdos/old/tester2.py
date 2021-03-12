import os

filename = '/GAVDOS1.txt'
filepath = '~/Desktop/python-gavdos'
infile = os.path.join("~/Desktop/python-gavdos", "GAVDOS1.txt")

with open(infile) as fin:
    for line in fin:
        parts = line.split('\t')
        # do something with the list "parts"
        print(parts)
