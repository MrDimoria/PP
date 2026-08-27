class_name WaitAtPatrolPoint
extends ActionLeaf

@export var wait_time: float = 2.0
var current_wait_time: float = 0.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	#Check if we just reached the patrol point
	if blackboard.get_value("patrol_point_reached", false):
		blackboard.set_value("patrol_point_reached", false)
		current_wait_time = 0.0
	
	# Increment wait time
	current_wait_time += get_physics_process_delta_time()
	
	#Check if we've waited long enough
	if current_wait_time >= wait_time:
		return SUCCESS
	
	return RUNNING
