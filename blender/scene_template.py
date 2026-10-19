"""Starter Blender 3D pour Blind Spot. Exécuter avec blender -b -P blender/scene_template.py."""
import bpy
import math
from mathutils import Vector

bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
scene = bpy.context.scene
scene.render.engine = 'BLENDER_EEVEE_NEXT'
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.render.resolution_percentage = 50
scene.render.fps = 30
scene.frame_start, scene.frame_end = 1, 300
scene.render.image_settings.file_format = 'PNG'
scene.render.filepath = '//out/blindspot_frame_'
scene.world.color = (0.008, 0.008, 0.008)

# Objet parent servant de null/contrôleur de caméra.
bpy.ops.object.empty_add(type='PLAIN_AXES', location=(0, 0, 0))
rig = bpy.context.object
rig.name = 'CAMERA_NULL_RIG'
rig.empty_display_size = 1.0
bpy.ops.object.camera_add(location=(0, -12, 1.2))
camera = bpy.context.object
camera.name = 'CAMERA_MAIN'
camera.data.lens = 52
camera.parent = rig
camera.rotation_euler = (math.radians(82), 0, 0)
scene.camera = camera
rig.location = (0, 0, 0)
rig.keyframe_insert(data_path='location', frame=1)
rig.location = (0, 0, 0.45)
rig.keyframe_insert(data_path='location', frame=300)
for fc in rig.animation_data.action.fcurves:
    for key in fc.keyframe_points:
        key.interpolation = 'BEZIER'

# Sujet de démonstration, éclairage volontairement sobre.
bpy.ops.mesh.primitive_cube_add(size=2, location=(0, 0, 0))
subject = bpy.context.object
subject.name = 'SUBJECT_REPLACE_ME'
subject.scale = (1.8, 0.25, 1.05)
subject.rotation_euler[2] = math.radians(7)
mat = bpy.data.materials.new('BlindSpot graphite')
mat.diffuse_color = (0.08, 0.08, 0.08, 1)
subject.data.materials.append(mat)

bpy.ops.object.light_add(type='AREA', location=(0, -5, 5))
key = bpy.context.object
key.name = 'KEY_LIGHT'
key.data.energy = 900
key.data.shape = 'DISK'
key.data.size = 5
key.rotation_euler = (math.radians(25), 0, 0)

scene.frame_set(1)
