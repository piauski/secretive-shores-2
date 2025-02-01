class_name StateMachine extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child._transition.connect(_on_child_transition)
	
	if initial_state:
		current_state = initial_state
		initial_state.enter()
		
			
func _process(delta:float):
	if current_state:
		current_state.update(delta)
	
func _physics_process(delta:float):
	if current_state:
		current_state.physics_update(delta)

func _on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())

	if !new_state:
		return

	if current_state:
		current_state.exit()
		
	current_state = new_state
	new_state.enter()
