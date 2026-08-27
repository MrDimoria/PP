class_name IsPlayerVisible
extends ConditionLeaf

@export var player_detection_range: float = 200.0
@export var vision_cone_angle: float = 45.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	# Get player reference (could be cached in blackboard)
	var player = get_tree().get_first_node_in_group("Player")
	if not player: 
		return FAILURE
	
	# Calculate distance and direction to player
	var to_player = player.global_position - actor.global_position
	var distance = to_player.length()
	
	# Check if player is within detection range
	if distance > player_detection_range:
		return FAILURE
	
	# Check if player is within vision cone
	var forward_dir = actor.global_basis.z.normalized()
	var angle_to_player = forward_dir.angle_to(to_player.normalized())
	if abs(angle_to_player) > deg_to_rad(vision_cone_angle):
		actor.velocity = Vector3.ZERO
		return FAILURE
	
	# Player is visible, save position in blackboard
	blackboard.set_value("player_position", player.global_position)
	blackboard.set_value("player_detected", true)
	return SUCCESS
	
