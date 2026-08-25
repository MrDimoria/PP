extends Node

var root
var blackboard := {}

func _init(root_node):
	root = root_node
	
func tick(actor):
	return root.tick(actor,blackboard)
