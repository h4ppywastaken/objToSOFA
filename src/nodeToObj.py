#!/usr/bin/python

#--------------------------------------------------
# Python Converter Script
# Converts a .node file to an .obj file
# Usage: python nodeToObj.py -- [inputfile]
#--------------------------------------------------

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("inputfile", type=str, help='.obj input file')

args = parser.parse_args()

inputfile = args.inputfile

if ".node" not in inputfile:
	inputfile += ".node"

outputfile = inputfile.strip(".node") + ".obj"

ifile = open(inputfile, "r")
ofile = open(outputfile, "w")
objlines = ifile.readlines()

count = 0

outlines=""

nodesfound = 0

for line in objlines: 
	line = line.strip()
	if line.startswith("1 "):
		nodesfound = 1
	if nodesfound:
		count += 1
		line = "v " + " ".join(line.split()[1:])
		outlines += line + "\n"

ifile.close()

ofile.seek(0, 0)
ofile.writelines(outlines)

ofile.close()