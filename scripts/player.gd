class_name Player extends Node3D

@export var camera: Camera3D
@export var animation_player: AnimationPlayer

var turn := false

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	if is_multiplayer_authority():
		print("server ", get_multiplayer_authority())
		camera.current = true
	else:
		print("client", get_multiplayer_authority())
		get_node("/root/game/table").rotation = rotation
		
	

func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
		
		
func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		turn = not turn
		if turn:
			animation_player.play("start_turn")
		else:
			animation_player.play("end_turn")
		
		
@rpc("any_peer", "call_local", "reliable")
func set_spawn(spawn_pos: Transform3D):
	transform = spawn_pos
	
