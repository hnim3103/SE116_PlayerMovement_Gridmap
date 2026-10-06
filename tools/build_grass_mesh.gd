@tool
extends EditorScript

## Atlas: [top | side | bottom], three square tiles in one horizontal row.
## Run in the Script Editor with File > Run to rebuild the saved mesh/library.
const SCENE_PATH := "res://assets/meshes/block_library.tscn"
const MESH_PATH := "res://assets/meshes/grass_block_mesh.tres"
const LIBRARY_PATH := "res://assets/meshes/block_library.meshlib"


func _run() -> void:
	if rebuild() == OK:
		EditorInterface.get_resource_filesystem().scan()


static func rebuild() -> Error:
	var scene := load(SCENE_PATH) as PackedScene
	var library := load(LIBRARY_PATH) as MeshLibrary
	if scene == null or library == null:
		return ERR_CANT_OPEN
	var root := scene.instantiate()
	var block := root.get_node("GrassBlock") as MeshInstance3D
	var material := StandardMaterial3D.new()
	material.albedo_texture = load("res://assets/meshes/textures/pixil-frame-1.png") as Texture2D
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	var size := Vector3(2, 2, 2)
	if block.mesh != null and block.mesh.get_surface_count() > 0:
		var existing_material := block.mesh.surface_get_material(0) as StandardMaterial3D
		if existing_material != null:
			material = existing_material.duplicate() as StandardMaterial3D
		size = block.mesh.get_aabb().size
	else:
		# A newly-created ArrayMesh has no geometry yet; use the existing box collision.
		var collision := block.get_node_or_null("StaticBody3D/CollisionShape3D") as CollisionShape3D
		if collision != null and collision.shape is BoxShape3D:
			size = (collision.shape as BoxShape3D).size
	root.free()
	var texture := material.albedo_texture
	if texture == null or texture.get_width() != texture.get_height() * 3:
		push_error("Grass atlas must contain three square tiles: [top | side | bottom].")
		return ERR_INVALID_DATA
	var item_id := library.find_item_by_name("GrassBlock")
	if item_id < 0:
		push_error("GrassBlock was not found in the MeshLibrary.")
		return ERR_DOES_NOT_EXIST

	material.uv1_scale = Vector3.ONE
	material.uv1_offset = Vector3.ZERO
	material.texture_repeat = false
	var mesh := create_mesh(size, material)
	var error := ResourceSaver.save(mesh, MESH_PATH)
	if error != OK:
		push_error("Could not save grass mesh: %s" % error_string(error))
		return error
	# Reference the saved resource, shared by the scene and MeshLibrary.
	var saved_mesh := ResourceLoader.load(MESH_PATH, "ArrayMesh", ResourceLoader.CACHE_MODE_REPLACE) as ArrayMesh
	library.set_item_mesh(item_id, saved_mesh)
	error = ResourceSaver.save(library, LIBRARY_PATH)
	if error != OK:
		push_error("Could not save MeshLibrary: %s" % error_string(error))
		return error
	print("Grass UV rebuilt: top=left tile, four sides=middle tile, bottom=right tile.")
	return OK


static func create_mesh(size: Vector3, material: Material) -> ArrayMesh:
	var box := BoxMesh.new()
	box.size = size
	var arrays := box.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	for i in range(vertices.size()):
		# Normalize the box position to -1..1, independently of its dimensions.
		var p := vertices[i] * 2.0 / size
		var normal := normals[i]
		var tile := 1
		var u := 0.0
		var v := (1.0 - p.y) * 0.5  # Every side's grass border stays at the top.
		if normal.y > 0.5:
			tile = 0
			u = (p.x + 1.0) * 0.5
			v = (p.z + 1.0) * 0.5
		elif normal.y < -0.5:
			tile = 2
			u = (p.x + 1.0) * 0.5
			v = (1.0 - p.z) * 0.5
		elif absf(normal.x) > 0.5:
			u = (1.0 - p.z * normal.x) * 0.5
		else:
			u = (1.0 + p.x * normal.z) * 0.5
		uvs[i] = Vector2((float(tile) + u) / 3.0, v)
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	# Tangents must follow the new UVs if a normal map is added later.
	var surface := SurfaceTool.new()
	surface.create_from(mesh, 0)
	surface.generate_tangents()
	var result := surface.commit()
	result.resource_name = "GrassBlock (top, side, bottom atlas)"
	result.surface_set_material(0, material)
	return result
