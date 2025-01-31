class_name Player extends Node3D

@export var camera: Camera3D
@export var animation_player: AnimationPlayer

@onready var board: Node3D = get_node("/root/game/table/board")
@onready var tiles: Node3D = board.get_node("tiles")

var turn := false

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	if !is_multiplayer_authority():
		return
	camera.current = true
	

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
	
	
@rpc("any_peer", "call_local", "reliable")
func set_board_rotation(rotation: Vector3):
	print("Setting board rotation peer ", multiplayer.get_unique_id()," to ", rotation.y)
	for tile in tiles.get_children():
		tile.rotation.y = rotation.y
	
