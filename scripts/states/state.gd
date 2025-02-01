class_name State extends Node

signal _transition(State, String)

func transition(new_state_name: String):
	_transition.emit(self, new_state_name)

func enter():
	pass
	
func exit():
	pass
	
func update(_delta: float):
	pass
	
func physics_update(_delta: float):
	pass
