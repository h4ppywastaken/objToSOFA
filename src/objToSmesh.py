#!/usr/bin/python

#--------------------------------------------------
# Python Converter Script
# Converts a .obj file to a .smesh file
# Usage: python objToSmesh.py -- [inputfile]
#--------------------------------------------------

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("inputfile", type=str, help='.obj input file')

args = parser.parse_args()

inputfile = args.inputfile

if ".obj" not in inputfile:
	inputfile += ".obj"

outputfile = inputfile.strip(".obj") + ".smesh"

ifile = open(inputfile, "r")
ofile = open(outputfile, "w")
objlines = ifile.readlines()

nodescount = 0
facetscount = 0

nodes=""
facets=""

for line in objlines: 
	line = line.strip()
	if line.startswith("v "):
		nodescount += 1
		line = str(nodescount) + line[1:]
		nodes += line + "\n"
	if line.startswith("f "):
		facetscount += 1
		linefacets = line.split(' ')
		facets += '3 ' + linefacets[1].split('/')[0] + ' ' + linefacets[2].split('/')[0] + ' ' + linefacets[3].split('/')[0] + '\n'

ifile.close()

ofile.seek(0, 0)
ofile.write("# TetGen .smesh input file\n")
ofile.write("#\n")
ofile.write("# " + outputfile + "\n")
ofile.write("\n")

ofile.write("# Nodes Description\n")
ofile.write("# <#nodes> <#dimensions> <#attributes> <#boundaryMarkers>\n")
ofile.write(str(nodescount) + " 3 0 0\n")
ofile.write("\n")

ofile.write("# Node Coordinates List\n")
ofile.write("# <node> <x> <y> <z>\n")
ofile.writelines(nodes)
ofile.write("\n")

ofile.write("# Facets Description\n")
ofile.write("# <#facets> <#boundaryMarkers>\n")
ofile.write(str(facetscount) + " 0\n")
ofile.write("\n")

ofile.write("# Facet List\n")
ofile.write("# <#nodes> <node1> <node2> <node3> ...\n")
ofile.writelines(facets)
ofile.write("\n")

ofile.write("# Hole List\n")
ofile.write("0\n")

ofile.write("# Region List\n")
ofile.write("0\n")

ofile.close()