extends BT_Node

func tick(actor, blackboard) -> int:
	for child in children:
		var result = child.tick(actor, blackboard)
		if result != Status.FAILURE:
			return result
	return Status.FAILURE
