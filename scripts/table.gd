class_name Table extends Node3D

@export var player1_spawn: Node3D
@export var player2_spawn: Node3D
@export var player3_spawn: Node3D
@export var player4_spawn: Node3D


func get_spawn(i: int):
	match i:
		1:
			return player1_spawn
		2:
			return player2_spawn
		3:
			return player3_spawn
		4:
			return player4_spawn
		_:
			return null
