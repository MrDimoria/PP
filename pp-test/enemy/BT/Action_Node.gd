extends BT_Node

var fn: Callable

func _init(func_ref: Callable):
	fn = func_ref

func tick(actor, blackboard) -> int:
	return fn.call(actor, blackboard)
