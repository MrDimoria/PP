extends CharacterBody3D

var bt

func _ready():
	bt = build_tree()
	
func _physics_process(delta: float) -> void:
	bt.tick(self)
	
func build_tree():
	var attack_seq = load("res://enemy/BT/Sequence.gd").new()
	attack_seq.children = [load("res://enemy/BT/Condition.gd").new(func_player_in_range),
	load("res://enemy/BT/Action_Node.gd").new(func_attack)
	]
	
	var chase_seq = load("res://enemy/BT/Sequence.gd").new()
	chase_seq.children = [
		load("res://enemy/BT/Condition.gd").new(func_can_see_player),
		load("res://enemy/BT/Action_Node.gd").new(func_chase)
	]
	
	var wander_action = load("res://enemy/BT/Action_Node.gd").new(func_wander)
	
	var selector = load("res://enemy/BT/Selector.gd").new()
	selector.children = [attack_seq, chase_seq, wander_action]
	
	return load("res://enemy/BT/Behavior_Tree.gd").new(selector)
	
func func_can_see_play(actor, bb):
	return actor.can_see_player()
	
func func_player_in_range(actor, bb):
	return actor.distance_to_player() < 2.0
	
func func_chase(actor, bb):
	actor.move_towards_player()
	return bt.Status.RUNNING
	
func func_attack(actor, bb):
	actor.perform_attack()
	return bt.Status.SUCCESS
	
func func_wander(actor, bb):
	actor.wander()
	return bt.Status.RUNNING
	
