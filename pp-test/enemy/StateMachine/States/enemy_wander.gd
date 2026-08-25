extends State
class_name EnemyWander

@onready var animation_tree: AnimationTree = $"../../AnimationTree"
@onready var enemy: CharacterBody3D = get_parent().get_parent()

var wander_direction: Vector3
var wander_time: float = 0
var animation_playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	animation_playback = animation_tree.get("parameters/playback")

func randomize_variables():
	
	wander_time = randf_range(enemy.min_wander_time, enemy.max_wander_time)
	if randi_range(0,3) != 1:
		
		_set_random_nav_target()
			
		animation_playback.travel("Walking")
	else:
		if enemy.nav_agent:
			
			enemy.nav_agent.set_target_position(enemy.global_position) 
			animation_playback.travel("Idle")

func enter():
	randomize_variables()
	
func exit():
	wander_time = 0
	if enemy.nav_agent:
		enemy.nav_agent.set_target_position(enemy.global_position)
	
func process(delta: float):
	if wander_time < 0.0:
		randomize_variables()
		pass
		
	wander_time -= delta
	
	if enemy.has_target:
		emit_signal("Transitioned", self, "EnemyChase")

func physics_process(delta: float) -> void:
	
	if not enemy.nav_agent:
		return
	
	var next_pos: Vector3 = enemy.nav_agent.get_next_path_position()
	var direction: Vector3 = enemy.global_position.direction_to(next_pos)
	direction.y = 0
	direction = direction.normalized()
	
	enemy.velocity = direction * enemy.wander_speed
	
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity()
		
func _set_random_nav_target() -> void:
	if not enemy.nav_agent:
		return
		
	await get_tree().physics_frame
	
	var map_rid: RID = enemy.nav_agent.get_navigation_map()
	if map_rid == RID():
		# Fallback if map isn't ready yet
		map_rid = enemy.get_world_3d().get_navigation_map()
		
	var random_point: Vector3 = NavigationServer3D.map_get_random_point(
		map_rid, 1, false
	)
	
	#Make sure the point is reachable / on the mesh
	random_point = NavigationServer3D.map_get_closest_point(map_rid, random_point)
	
	enemy.nav_agent.set_target_position(random_point)
		
# Add a debug sphere at global location.
func draw_debug_sphere(location, size):
	# Will usually work, but you might need to adjust this.
	var scene_root = get_tree().root.get_children()[0]
	# Create sphere with low detail of size.
	var sphere = SphereMesh.new()
	sphere.radial_segments = 4
	sphere.rings = 4
	sphere.radius = size
	sphere.height = size * 2
	# Bright red material (unshaded).
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0, 0)
	material.flags_unshaded = true
	sphere.surface_set_material(0, material)
	
	# Add to meshinstance in the right place.
	var node = MeshInstance3D.new()
	node.mesh = sphere
	node.global_transform.origin = location
	scene_root.add_child(node)
