extends CharacterBody3D
@onready var raycast = $Armature/RayCast3D
@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var collisionshape = $CollisionShape3D
@onready var sphere_check = $Armature/Area3D

var player = null
var hp = 100
var state_machine 
var has_target: bool = false
var exited_sense: bool = false
var is_wandering = false
var last_seen_pos:= Vector3.ZERO


@export var GRAVITY = 20
@export var player_path : NodePath
@export var SPEED = 0.9
@export var JUMP_VELOCITY = 4.5
@export var ATTACK_RANGE: float = 2.0
@export var DAMAGE = 2.0
@export var reach_dist: float = 0.2
@export var sweep_speed = 1.8
@export var wander_radius = 5
@export var min_wander_time = 3
@export var max_wander_time = 8
@export var wander_speed = 0.9
@export var min_stop_time = 3
@export var max_stop_time = 8

var sweep_time = 0
var half_sweep = 0
var sweep_degrees = 130
var wander_timer = 0
var stop_timer = 10



func _ready() -> void:
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	raycast.add_exception(self)
	half_sweep = deg_to_rad(sweep_degrees * 0.5)
	nav_agent.avoidance_enabled = true
	

func _physics_process(delta: float) -> void:
	
	sweep_sight(delta)
	
	if raycast.is_colliding():
		if raycast.get_collider() is Player:
			has_target = true
			last_seen_pos = player.global_position
			#draw_debug_sphere(raycast.get_collision_point(), 0.1)
		
	match state_machine.get_current_node():
		"Idle":
			
			if has_target:
				anim_tree.set("parameters/conditions/Run", true)
				#anim_tree.set("parameters/conditions/Stopped", false)
			
			if not is_wandering:
				nav_agent.set_target_position(pick_random_wander_point())
				is_wandering = true
				wander_timer = randf_range(min_wander_time, max_wander_time)
				anim_tree.set("parameters/conditions/Run", false)
			else:
				if nav_agent.is_navigation_finished() or wander_timer <= 0:
					is_wandering = false
					velocity = Vector3.ZERO
					
					stop_timer -= delta
					if stop_timer <= 0:
						anim_tree.set("parameters/conditions/Wander", false)
						wander_timer = randf_range(min_wander_time, max_wander_time)
						stop_timer = randf_range(min_stop_time, max_stop_time)
				else:
					wander_timer -= delta
					var next_nav_point = nav_agent.get_next_path_position()
					var dir = (next_nav_point - global_position).normalized()
					velocity.x = dir.x * wander_speed
					velocity.z = dir.z * wander_speed
					look_at(Vector3(next_nav_point.x, global_position.y, next_nav_point.z), Vector3.UP)
					
					
					
				
		"Wander":
			pass
			
		"Walking":
			if has_target:
				if exited_sense:
					nav_agent.set_target_position(last_seen_pos)
				else:
					nav_agent.set_target_position(player.global_position)
				if nav_agent.is_navigation_finished() or global_position.distance_to(last_seen_pos) < reach_dist:
					has_target = false
					anim_tree.set("parameters/conditions/Run", false)
					
					velocity = Vector3.ZERO
				else:	
					anim_tree.set("parameters/conditions/Run", true)
					anim_tree.set("parameters/conditions/Stopped", false)
					var next_nav_point = nav_agent.get_next_path_position()
					var dir = (next_nav_point - global_position).normalized()
					
					velocity = dir * SPEED
					
					look_at(Vector3(next_nav_point.x, global_position.y, next_nav_point.z), Vector3.UP)
					anim_tree.set("parameters/conditions/Attack", target_in_range())
			else:
				anim_tree.set("parameters/conditions/Stopped", !target_in_range() and !has_target)
	
		"Attack":
			if has_target:
				var next_nav_point = nav_agent.get_next_path_position()
				var dir = (next_nav_point - global_position).normalized()
				velocity = dir * SPEED
				anim_tree.set("parameters/conditions/Run", !target_in_range())
				look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		"Death":
			pass
	#print(state_machine.get_current_node())
	#print(has_target)
	move_and_slide()
func target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

	




func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		raycast.enabled = true
		exited_sense = false
		
	
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


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		last_seen_pos = player.global_position
		exited_sense = true
		#draw_debug_sphere(last_seen_pos, 0.1)
		
func pick_random_wander_point() -> Vector3:
	var rand_offset = Vector3(randf_range(-wander_radius, wander_radius), 0.0, randf_range(-wander_radius, wander_radius))
	var target = global_position + rand_offset
	var map = get_world_3d().navigation_map
	return NavigationServer3D.map_get_closest_point(map, target)
	
func sweep_sight(delta: float) -> void:
	sweep_time += delta * sweep_speed
	var angle = sin(sweep_time) * half_sweep
	raycast.rotation.z = angle 
