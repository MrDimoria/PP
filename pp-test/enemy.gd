class_name Enemy
extends CharacterBody3D
@onready var raycast = $Armature/RayCast3D
@onready var nav_agent = $NavigationAgent3D
@onready var collisionshape = $CollisionShape3D
@onready var sphere_check = $Armature/Area3D
@onready var animation_tree: AnimationTree = $AnimationTree
var animation_playback: AnimationNodeStateMachinePlayback

var player = null
var hp = 100
@onready var state_machine = $StateMachine
var has_target: bool = false
var exited_sense: bool = false
var is_wandering = false
var last_seen_pos:= Vector3.ZERO


@export var GRAVITY = 20
@export var player_path : NodePath
@export var SPEED = 0.9
@export var wander_speed = 0.9
@export var JUMP_VELOCITY = 4.5
@export var ATTACK_RANGE: float = 2.0
@export var DAMAGE = 2.0
@export var reach_dist: float = 0.2
@export var sweep_speed = 1.8
@export var wander_radius = 5
@export var min_wander_time = 3
@export var max_wander_time = 8

@export var min_stop_time = 3
@export var max_stop_time = 8

var sweep_time = 0
var half_sweep = 0
var sweep_degrees = 20
var wander_timer = 0
var stop_timer = 10



func _ready() -> void:
	player = get_node(player_path)
	animation_playback = animation_tree.get("parameters/playback")
	raycast.add_exception(self)
	half_sweep = deg_to_rad(sweep_degrees * 0.5)
	nav_agent.set_avoidance_enabled(true)
	nav_agent.set_avoidance_priority(randf_range(0.1,1))
	

func _physics_process(delta: float) -> void:
	var state = animation_playback.get_current_node()

	#if !nav_agent.is_target_reachable():
		#emit_signal("Transitioned", self , "EnemyWander")
		
	if state == "Attack":
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
	else:
		var new_velocity = velocity
		new_velocity.y = 0
		
		if new_velocity != Vector3.ZERO:
			rotation.y = lerp(rotation.y, atan2(-velocity.x, -velocity.z), delta * 2)
	sweep_sight(delta)
	
	if raycast.is_colliding():
		if raycast.get_collider() is Player:
			has_target = true
			last_seen_pos = player.global_position
			#draw_debug_sphere(raycast.get_collision_point(), 0.1)
	
	
		
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
		has_target = false
		#draw_debug_sphere(last_seen_pos, 0.1)
		
func pick_random_wander_point() -> Vector3:
	var rand_offset = Vector3(randf_range(-wander_radius, wander_radius), 0.0, randf_range(-wander_radius, wander_radius))
	var target = global_position + rand_offset
	var map = get_world_3d().navigation_map
	return NavigationServer3D.map_get_closest_point(map, target)
	
func sweep_sight(delta: float) -> void:
	sweep_time += delta * sweep_speed
	var angle = sin(sweep_time) * half_sweep
	var angle2 = cos(sweep_time) * half_sweep
	raycast.rotation.z = angle 
	raycast.rotation.x = angle2
