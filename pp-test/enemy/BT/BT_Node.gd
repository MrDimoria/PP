extends Resource
class_name BT_Node

enum Status { SUCCESS, FAILURE, RUNNING }

var children: Array = []

func tick(actor, blackboard) -> int:
	return Status.SUCCESS
