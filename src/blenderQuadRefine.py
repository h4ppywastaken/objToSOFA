#--------------------------------------------------
# Blender Python API Script
# Refines a mesh from an .obj file using Blender in quads mode
# Usage: blender -b -P blenderQuadRefine.py -- [inputfile] [refineCuts]
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

#edit mode
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')

#remove doubles and custom normal data
bpy.ops.mesh.customdata_custom_splitnormals_clear()
bpy.ops.mesh.remove_doubles()

#convert triangles to quads
bpy.ops.mesh.tris_convert_to_quads()

#subdivide
bpy.ops.mesh.subdivide(number_cuts=int(argv[1]))

#export scene to .ply
bpy.ops.export_scene.obj(filepath=argv[0]+'.obj', axis_forward='Z', axis_up='Y')