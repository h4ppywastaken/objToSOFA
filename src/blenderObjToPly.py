#--------------------------------------------------
# Blender Python API Script
# Converts and .obj file to a .ply file in Blender
# Usage: blender -b -P blenderToPly.py -- [inputfile]
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

#triangulate mesh
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
#bpy.ops.mesh.quads_convert_to_tris(quad_method='FIXED')
bpy.ops.object.mode_set(mode='OBJECT')

#export scene to .ply
bpy.ops.export_mesh.ply(filepath=argv[0]+'.ply', axis_forward='Z', axis_up='Y')