extends State
class_name EnemyAttack

var player: CharacterBody3D = null
@onready var enemy: CharacterBody3D = get_parent().get_parent() 


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta: float) -> void:
	
	if enemy.global_position.distance_to(player.global_position) > enemy.ATTACK_RANGE:
		emit_signal("Transitioned", self, "EnemyChase")
	
