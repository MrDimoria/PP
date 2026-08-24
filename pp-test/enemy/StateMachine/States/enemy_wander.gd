extends State
class_name EnemyWander

var wander_direction: Vector3
var wander_time: float = 0

@onready var enemy: CharacterBody3D = get_parent().get_parent()

func randomize_variables():
	wander_direction = Vector3(randf_range(-1.0,1.0), 0, randf_range(-1.0, 1.0))
	wander_time = randf_range(enemy.min_wander_time, enemy.max_wander_time)

func enter():
	randomize_variables()
	
func exit():
	wander_time = 0
	wander_direction = Vector3.ZERO
	
func process(delta: float):
	if wander_time < 0.0:
		randomize_variables()
		
	wander_time -= delta
	
	if enemy.has_target:
		emit_signal("Transitioned", self, "EnemyChase")

func physics_process(delta: float) -> void:
	enemy.velocity = wander_direction * enemy.wander_speed
	enemy.rotation.y = lerp(enemy.rotation.y, atan2(-enemy.velocity.x, -enemy.velocity.z), delta * 10)
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity()
