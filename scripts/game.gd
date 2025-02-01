class_name Game extends Node3D

signal player_added(Node3D)

@export var players: Node3D
@export var table: Table
@export var board: Board


@export var player_scene: PackedScene

@export var stencil_viewport: SubViewport
@export var stencil_camera: Camera3D

func _ready() -> void:
	# Preconfigure game.
	if multiplayer.is_server():
		var seed_value = randi()
		board.generate_tiles(seed_value)
		board.generate_pawns()
	
	Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.
	

@rpc("any_peer", "call_local", "reliable")
func synchronize_board(tile_data: Array) -> void:
	# Clients generate the board using the synchronized data.
	board.generate_tiles_from_data(tile_data)
	
	
@rpc("any_peer", "call_local", "reliable")
func synchronize_pawns(pawn_data: Array) -> void:
	# Clients generate the board using the synchronized data.
	board.generate_pawns_from_data(pawn_data)


# Called only on the server.
func start_game() -> void:
	var i = 1
	for peer_id in Lobby.players:
		var player = player_scene.instantiate()
		player.name = str(peer_id)
		add_child(player)
		var spawn = table.get_spawn(i)
		player.set_spawn.rpc(spawn.transform)
		synchronize_board.rpc_id(peer_id, board.get_tile_data())
		synchronize_pawns.rpc_id(peer_id, board.get_pawn_data())
		player.set_board_rotation.rpc_id(peer_id, spawn.rotation.y + PI / 2)
		i += 1
		

func _process(_delta: float) -> void:
	var viewport := get_viewport()
	var current_camera := viewport.get_camera_3d()
	
	if stencil_viewport.size != viewport.size:
		stencil_viewport.size = viewport.size
		
	if current_camera:
		stencil_camera.fov = current_camera.fov
		stencil_camera.global_transform = current_camera.global_transform
