extends State
class_name EnemyChase

@onready var enemy: CharacterBody3D = get_parent().get_parent() 
@onready var animation_tree: AnimationTree = $"../../AnimationTree"
var player: CharacterBody3D = null
var animation_playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	animation_playback = animation_tree.get("parameters/playback")
	
func enter():
	animation_playback.travel("Walking")
	


func process(delta: float):
	
	if enemy.has_target:
		enemy.nav_agent.set_target_position(player.global_position)
	
	else:
		enemy.nav_agent.set_target_position(enemy.last_seen_pos)
		if enemy.nav_agent.is_navigation_finished():
			emit_signal("Transitioned", self, "EnemyWander")
			
	if enemy.global_position.distance_to(player.global_position) < enemy.ATTACK_RANGE:
		emit_signal("Transitioned", self, "EnemyAttack")
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_process(delta: float) -> void:
	
	if enemy.nav_agent.is_navigation_finished():
		return
		
	var next_position: Vector3 = enemy.nav_agent.get_next_path_position()
	enemy.velocity = enemy.global_position.direction_to(next_position) * enemy.SPEED
	
	
