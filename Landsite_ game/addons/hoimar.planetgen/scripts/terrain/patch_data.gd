class_name PatchData

# class ktorá drzí informácie o jednej časti rerénu

const Const := preload("../constants.gd")

var parent_patch: MeshInstance    # rodič
var quadnode: Reference
var settings: PlanetSettings
var axis_up: Vector3      
var axis_a: Vector3       
var axis_b: Vector3       
var verts_per_edge: int   
var offset_a: Vector3    
var offset_b: Vector3     
var size: float         
var center: Vector3
var material: Material


func _init(
			manager: Spatial, \
			quadnode: Reference, \
			axis_up: Vector3, \
			offset: Vector2):
	self.quadnode  = quadnode
	settings       = manager.planet_settings
	material       = manager.planet_material
	size           = quadnode._size
	axis_up        = axis_up.normalized()
	self.axis_up   = axis_up
	axis_a         = Vector3(axis_up.y, axis_up.z, axis_up.x) * size
	axis_b         = axis_up.cross(axis_a).normalized() * size
	offset_a       = Vector3(axis_a * offset.x)
	offset_b       = Vector3(axis_b * offset.y)
	if quadnode.parent:
		parent_patch = quadnode.parent.terrain
	if parent_patch:
		offset_a += parent_patch.data.offset_a
		offset_b += parent_patch.data.offset_b
	verts_per_edge = settings.resolution + Const.BORDER_SIZE * 2
	center         = settings.radius * (axis_up + offset_a + offset_b).normalized()
