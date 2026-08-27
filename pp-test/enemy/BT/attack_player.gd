class_name AttackPlayer
extends ActionLeaf

@export var attack_cooldown: float = 1.0
var time_since_last_attack: float = 0.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	#Check if cooldown has elapsed
	if time_since_last_attack < attack_cooldown:
		time_since_last_attack += get_physics_process_delta_time()
		return RUNNING
	
	#Reset cooldown
	time_since_last_attack = 0.0
	
	#Perform attack
	print("enemy attacks player")
	#Trigger animation HERE
	
	return SUCCESS
