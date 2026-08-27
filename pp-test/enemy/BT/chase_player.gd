class_name ChasePlayer
extends ActionLeaf

@export var move_speed: float = 100.0
@export var attack_range: float = 30.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	# Get the player position from the blackboard
	var player_pos = blackboard.get_value("player_position")
	if not player_pos:
		return FAILURE
	
	#Calculate direction to player
	var direction = (player_pos - actor.global_position).normalized()
	
	#Move towards player
	actor.velocity += direction * move_speed * get_physics_process_delta_time()
	
	# Store attack range in blackboard
	blackboard.set_value("attack_range", attack_range)
	
	#Check if within attack range
	var distance = actor.global_position.distance_to(player_pos)
	if distance <= attack_range:
		return SUCCESS
		
	# Still chasing
	return RUNNING
