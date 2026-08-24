extends State
class_name EnemyAttack

var player: CharacterBody3D = null
var animation_playback: AnimationNodeStateMachinePlayback
@onready var enemy: CharacterBody3D = get_parent().get_parent()
@onready var animation_tree: AnimationTree = $"../../AnimationTree" 

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	animation_playback = animation_tree.get("parameters/playback")

func enter():
	animation_playback.travel("Attack")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta: float) -> void:
	
	enemy.velocity = Vector3.ZERO
	if enemy.global_position.distance_to(player.global_position) > enemy.ATTACK_RANGE:
		emit_signal("Transitioned", self, "EnemyChase")
	
func _attack_player():
	pass
	
