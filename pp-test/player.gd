class_name Player
extends CharacterBody3D

@onready var camera = $Head/Camera3D
@onready var head =$Head
@onready var rightarm =$Arms/RightArm
@onready var state_label1 =$"CanvasLayer/Control/Enemy1 Label/Enemy 1 State Label"
@onready var state_label2 =$"CanvasLayer/Control/Enemy2 Label/Enemy 2 State Label"
@onready var target_status_label1 =$"CanvasLayer/Control/Enemy1 Label/Enemy 1 State Label/HasTargetLabel1/TargetStatusLabel1"
@onready var target_status_label2 =$"CanvasLayer/Control/Enemy2 Label/Enemy 2 State Label/HasTargetLabel2/TargetStatusLabel2"
@onready var enemy_label1 = $"CanvasLayer/Control/Enemy1 Label"
@onready var enemy_label2 = $"CanvasLayer/Control/Enemy2 Label"

const MOUSE_SENSITIVITY = 0.2
@export var GRAVITY = 9.82 
const JUMP_STRENGTH = 10
const SPEED = 5.5
const ACCELERATION = 8.0
var SPRINT_MULT = 1.0
var enemies: Array[Enemy] = []
var health: int = 100

var currentvel = Vector3.ZERO
var velocity_y = 0

@export var HBOB_FREQ = 1.0
@export var HBOB_AMP = 0.05
var hbob_speed = 0.0
var debug_on: bool = false
var debug_time: bool = false

func _ready()->void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	enemies.clear()
	for node in get_tree().get_nodes_in_group("enemies"):
		if node is Enemy:
			enemies.push_back(node)
	
func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Debug"):
		debug_on = !debug_on
		
	debug_visibility(debug_on)
	
	if debug_on:
		if Input.is_action_just_pressed("Debug_time"):
			if !debug_time:
				Engine.time_scale = 0.5
				debug_time = true
			else:
				Engine.time_scale = 1
				debug_time = false
				
	
	if enemies[0].state_machine:	
		state_label1.text = str(enemies[0].state_machine.current_state)
		target_status_label1.text = str(enemies[0].has_target)
		
	if enemies[1].state_machine:	
		state_label2.text = str(enemies[1].state_machine.current_state)
		target_status_label2.text = str(enemies[1].has_target)
	
		
	var dir_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var dir_z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	var input_dir = Vector2(dir_x, dir_z).normalized()
	
		
	var target_velocity = (global_transform.basis.x * input_dir.x + global_transform.basis.z * input_dir.y) * SPEED * SPRINT_MULT
	currentvel = currentvel.lerp(target_velocity, ACCELERATION * delta)
	velocity.x = currentvel.x
	velocity.z = currentvel.z
	
	if is_on_floor():
		if Input.is_action_pressed("sprint"):
			SPRINT_MULT = 2
		else:
			SPRINT_MULT = 1
		if Input.is_action_just_pressed("jump"):
			velocity_y += JUMP_STRENGTH
		else:
			velocity_y = 0
		
	else:
		velocity_y -= GRAVITY * delta
		
	velocity.y = velocity_y
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_x(deg_to_rad(event.relative.y * - MOUSE_SENSITIVITY))
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -90, 60)
		self.rotate_y(deg_to_rad(event.relative.x * -MOUSE_SENSITIVITY))
		
func _process(delta: float) -> void:
	hbob_speed += delta * velocity.length() * float(is_on_floor())
	camera.position = headbob(hbob_speed)
	
func headbob(speed) -> Vector3:
		var pos = Vector3.ZERO
		pos.y = sin(speed * HBOB_FREQ) * HBOB_AMP
		pos.x = cos(speed * HBOB_FREQ / 2) * HBOB_AMP
		return pos
		
func debug_visibility(debug) -> void:
	enemy_label1.visible = debug
	enemy_label2.visible = debug
	state_label1.visible = debug
	state_label2.visible = debug
	target_status_label1.visible = debug
	target_status_label2.visible = debug
	
	
