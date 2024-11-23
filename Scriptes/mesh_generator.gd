class_name MeshGenerator extends Node

@export var size_depth : int = 100
@export var size_width : int = 100
@export var mesh_resolution : int = 2

@export var noise : FastNoiseLite

@export var spawnable_objects : Array[SpawnableObject]

var mesh : MeshInstance3D 
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	generate()

func generate():
	
	noise.seed = randi()
	rng.seed = noise.seed
	
	var plane_mesh : PlaneMesh = PlaneMesh.new()
	plane_mesh.size = Vector2(size_depth, size_width)
	plane_mesh.subdivide_depth = size_depth * mesh_resolution
	plane_mesh.subdivide_width = size_width * mesh_resolution
	plane_mesh.material = preload("res://Models/TerrainMaterial.tres")
	
	var surface = SurfaceTool.new()
	var data : MeshDataTool = MeshDataTool.new()
	surface.create_from(plane_mesh, 0)
	var array_plane = surface.commit()
	data.create_from_surface(array_plane, 0)
	
	for i in range(data.get_vertex_count()):
		var vertex = data.get_vertex(i)
		vertex.y = get_noise_y(vertex.x, vertex.z)
		data.set_vertex(i, vertex)
	
	array_plane.clear_surfaces()
	
	data.commit_to_surface(array_plane)
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.create_from(array_plane, 0)
	surface.generate_normals()
	
	mesh = MeshInstance3D.new()
	mesh.mesh = surface.commit()
	mesh.create_trimesh_collision()
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh)
	
	for object in spawnable_objects:
		for i in object.count:
			object.scene = load(object.scene_path)
			var scene : Node3D = object.scene.instantiate()
			scene.scale *= rng.randf_range(object.scale_min, object.scale_max)
			add_child(scene)
			scene.global_position = get_rand_coordinates()
			

func get_noise_y(x, z) -> float:
	return noise.get_noise_2d(x, z) * 25

func get_rand_coordinates() -> Vector3:
	var x = rng.randf_range(-size_width / 2, size_width / 2)
	var z = rng.randf_range(-size_depth / 2, size_depth / 2)
	var y = get_noise_y(x, z)
	return Vector3(x, y, z)
