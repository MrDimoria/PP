class_name MoveToPatrolPoint
extends ActionLeaf

@export var patrol_points: Array[NodePath]
@export var move_speed: float = 50.0
@export var point_reach_distance: float = 10.0

var current_point_index: int = 0

func tick(actor: Node, blackboard: Blackboard) -> int:
	# Make sure we have patrol points
	if patrol_points.size() == 0:
		return FAILURE
		
	#Get the current patrol point
	var target_node = get_node(patrol_points[current_point_index])
	if not target_node:
		return FAILURE
	
	# Calculate direction to the point
	var target_pos = target_node.global_position
	var direction = (target_pos - actor.global_position.normalized())
	
	# Move toward the patrol point
	actor.global_position += direction * move_speed * get_physics_process_delta_time()
	
	# Rotate to face direction
	#TODO:
	actor.rotation = lerp_angle(actor.rotation, atan2(direction.x, direction.z), 0.1)
	
	#Check if we've reached the point
	var distance = actor.global_position.distance_to(target_pos)
	if distance <= point_reach_distance:
		#Move to the next patrol point
		current_point_index = (current_point_index +1) % patrol_points.size()
		blackboard.set_value("patrol_point_reached", true)
		return SUCCESS
	
	return RUNNING
