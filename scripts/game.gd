class_name Game extends Node3D

signal player_added(Node3D)

@export var players: Node3D
@export var table: Table

@export var player_scene: PackedScene

func _ready() -> void:
	# Preconfigure game.

	Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.


# Called only on the server.
func start_game() -> void:
	var i = 1
	for peer_id in Lobby.players:
		var player = player_scene.instantiate()
		player.name = str(peer_id)
		add_child(player)
		player.set_spawn.rpc(table.get_spawn(i).transform)
		i += 1
	
