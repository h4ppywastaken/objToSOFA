#--------------------------------------------------
# Blender Python API Script
# Converts and .obj file to a .stl file in Blender
# Usage: blender -b -P blenderObjToStl.py -- [inputfile]
#--------------------------------------------------

import bpy
import sys
import time

argv = sys.argv
argv = argv[argv.index("--") + 1:]

#Delete all objects in the scene
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

#import .obj file
bpy.ops.import_scene.obj(filepath=argv[0]+'.obj', axis_forward='Z', axis_up='Y')

#make imported object active
bpy.context.scene.objects.active = bpy.data.objects[0]
bpy.ops.object.select_all(action='SELECT')

#export scene to .stl
bpy.ops.export_mesh.stl(filepath=argv[0]+'.stl', axis_forward='Z', axis_up='Y')