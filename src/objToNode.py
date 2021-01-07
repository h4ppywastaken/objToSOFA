#!/usr/bin/python

#--------------------------------------------------
# Python Converter Script
# Converts a .obj file to a .node file only exporting vertices (nodes)
# Usage: python objToNode.py -- [inputfile]
#--------------------------------------------------

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("inputfile", type=str, help='.obj input file')

args = parser.parse_args()

inputfile = args.inputfile

if ".obj" not in inputfile:
	inputfile += ".obj"

outputfile = inputfile.strip(".obj") + ".node"

ifile = open(inputfile, "r")
ofile = open(outputfile, "w")
objlines = ifile.readlines()

count = 0

outlines=""

for line in objlines: 
	line = line.strip()
	if line.startswith("v "):
		count += 1
		line = str(count) + line[1:]
		outlines += line + "\n"

ifile.close()

ofile.seek(0, 0)
ofile.write("# Node count, 3 dim, no attribute, no boundary marker\n")
ofile.write(str(count) + " 3 0 0"  + "\n")
ofile.write("# Node index, node coordinates\n")
ofile.writelines(outlines)

ofile.close()