class_name GameSetup extends State

@export var players: Node3D
@export var table: Table
@export var board: Board

@export var player_scene: PackedScene


func enter() -> void:
	GameManager.click_event.connect(_on_click_event)


func exit() -> void:
	GameManager.click_event.connect(_on_click_event)


func _on_click_event(peer_id, action, row, col):
	print("game state machine: ", peer_id, " clicked ", action, " on ", row, " ", col)
