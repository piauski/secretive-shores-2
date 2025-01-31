class_name Game extends Node3D

signal player_added(Node3D)

@export var players: Node3D
@export var table: Table

@export var player_scene: PackedScene

var board = table.board

func _ready() -> void:
	# Preconfigure game.
	board.generate_tiles()
	
	Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.


# Called only on the server.
func start_game() -> void:
	var i = 1
	for peer_id in Lobby.players:
		var player = player_scene.instantiate()
		player.name = str(peer_id)
		add_child(player)
		var spawn = table.get_spawn(i)
		print("setting spawn peer ", peer_id, " to ", spawn.rotation.y)
		player.set_spawn.rpc(spawn.transform)
		player.set_board_rotation.rpc_id(peer_id, spawn.rotation)
		i += 1
	
