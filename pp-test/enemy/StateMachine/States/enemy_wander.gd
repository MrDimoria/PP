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
		wander_direction = Vector3(randf_range(-1.0,1.0), 0, randf_range(-1.0, 1.0))
		animation_playback.travel("Walking")
	else:
		wander_direction = Vector3.ZERO
		animation_playback.travel("Idle")

func enter():
	randomize_variables()
	
func exit():
	wander_time = 0
	wander_direction = Vector3.ZERO
	
func process(delta: float):
	if wander_time < 0.0:
		randomize_variables()
		pass
		
	wander_time -= delta
	
	if enemy.has_target:
		emit_signal("Transitioned", self, "EnemyChase")

func physics_process(delta: float) -> void:
	enemy.velocity = wander_direction * enemy.wander_speed
	
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity()
