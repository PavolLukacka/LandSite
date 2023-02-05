tool
class_name TerrainPatch
extends MeshInstance
#Reprezentuje spracovanie terénu ako stromu

const Const := preload("../constants.gd")

#premmné
var data: PatchData
var quadnode: Reference
var vertices: PoolVector3Array
var triangles: PoolIntArray
var uvs: PoolVector2Array
var normals: PoolVector3Array


func _process(_delta):
	quadnode.visit()


# Vybuduje terén z mesh generátora
func build(var data: PatchData):
	self.data           = data
	self.quadnode       = data.quadnode
	var verts_per_edge  = data.verts_per_edge
	var border_offset  := 1.0 + Const.BORDER_SIZE * 2.0 / (data.settings.resolution - 1)
	var base_offset    := data.axis_up + data.offset_a + data.offset_b
	var axis_a_scaled  := data.axis_a * border_offset * 2.0
	var axis_b_scaled  := data.axis_b * border_offset * 2.0
	var tri_idx        := 0   # Mapovanie vrcholu k trojuholníku
	var min_max        := MinMax.new()   # Sluzi na uloženie lokalneho maxima a minima elevácie
	var shape_gen: ShapeGenerator = data.settings.shape_generator
	# počet trojuholnikov
	triangles.resize((verts_per_edge - 1) * (verts_per_edge - 1) * 3 * 2)
	vertices.resize(verts_per_edge * verts_per_edge)
	uvs.resize(verts_per_edge * verts_per_edge)
	normals.resize(verts_per_edge * verts_per_edge)
	set_visible(false)
	# Vybuduj tvar
	for vertex_idx in verts_per_edge * verts_per_edge:
		var x: int = vertex_idx / verts_per_edge
		var y: int = vertex_idx % verts_per_edge
		# Vypočítaj pozíciu
		var percent: Vector2 = Vector2(x, y) / (verts_per_edge - 1)
		var point_on_unit_cube := base_offset \
				 + (percent.x - 0.5) * axis_a_scaled \
				 + (percent.y - 0.5) * axis_b_scaled
		var point_on_unit_sphere: Vector3 = point_on_unit_cube.normalized()
		var elevation: float = shape_gen.get_unscaled_elevation(point_on_unit_sphere)
		vertices[vertex_idx] = point_on_unit_sphere \
				* shape_gen.get_scaled_elevation(elevation)
		uvs[vertex_idx].x = elevation
		min_max.add_value(elevation)
		# vybuduj dva trojuholníky
		if x < verts_per_edge - 1 and y < verts_per_edge - 1:
			triangles[tri_idx]     = vertex_idx
			triangles[tri_idx + 1] = vertex_idx + verts_per_edge + 1
			triangles[tri_idx + 2] = vertex_idx + verts_per_edge
			triangles[tri_idx + 3] = vertex_idx
			triangles[tri_idx + 4] = vertex_idx + 1
			triangles[tri_idx + 5] = vertex_idx + verts_per_edge + 1
			tri_idx += 6
	
	# Uprav Minimum a maximum
	shape_gen.min_max_mutex.lock()
	shape_gen.min_max.add_value(min_max.min_value)
	shape_gen.min_max.add_value(min_max.max_value)
	shape_gen.min_max_mutex.unlock()
	# Ďalšie prídavné kalkulácie
	calc_normals()
	calc_terrain_border()
	calc_uvs()
	# Príprava polí
	var mesh_arrays := []
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	mesh_arrays[Mesh.ARRAY_VERTEX] = vertices
	mesh_arrays[Mesh.ARRAY_NORMAL] = normals
	mesh_arrays[Mesh.ARRAY_TEX_UV] = uvs
	mesh_arrays[Mesh.ARRAY_INDEX]  = triangles
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)

	if not Engine.editor_hint \
			and PGGlobals.colored_patches \
			and data.material is SpatialMaterial:
		data.material = data.material.duplicate()
		data.material.albedo_color = Color(randi())
	# Vybuduj mesh z materiálu
	mesh.surface_set_material(0, data.material)


# odstranuje jagged šum 
func calc_terrain_border():
	var verts_per_edge = data.verts_per_edge
	var dip: float = pow(Const.BORDER_DIP, data.size)
	# Spodná a vrchná hranica.
	for i in range(0, verts_per_edge * verts_per_edge, verts_per_edge):
		var idx: = i
		vertices[idx] *= dip
		idx = i + verts_per_edge - 1
		vertices[idx] *= dip
	# Pravý a lavý okraj
	for i in range(1, verts_per_edge - 1):
		var idx: = i
		vertices[idx] *= dip
		idx = i + verts_per_edge * (verts_per_edge - 1)
		vertices[idx] *= dip


# Počíta normály
func calc_normals():
	for i in range(0, triangles.size(), 3):
		var vi_a := triangles[i]
		var vi_b := triangles[i+1]
		var vi_c := triangles[i+2]
		var a := vertices[vi_a]
		var b := vertices[vi_b]
		var c := vertices[vi_c]
		var norm: Vector3 = -(b - a).cross(c - a)
		normals[vi_a] += norm
		normals[vi_b] += norm
		normals[vi_c] += norm
	for i in normals.size():
		normals[i] = normals[i].normalized()


# Získa UV pozície
func calc_uvs():
	var min_max: MinMax = data.settings.shape_generator.min_max
	var min_value := min_max.min_value
	var max_value := min_max.max_value
	for i in uvs.size():
		uvs[i].x = range_lerp(uvs[i].x, min_value, max_value, 0.0, 1.0)
