extends BT_Node

var fn: Callable

func _init(func_ref: Callable):
	fn = func_ref
	
func tick(actor, blackboard) -> int:
	var result = fn.call(actor, blackboard)
	return Status.SUCCESS if result else Status.FAILURE
