extends BT_Node

var current_index := 0

func tick(actor, blackboard) -> int:
	while current_index < children.size():
		var result = children[current_index].tick(actor,blackboard)
		
		if result == Status.RUNNING:
			return Status.RUNNING
			
		if result == Status.FAILURE:
			current_index = 0
			return Status.FAILURE
		
		current_index += 1
		
	current_index = 0
	return Status.SUCCESS
