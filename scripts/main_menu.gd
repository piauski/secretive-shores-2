extends Control

@export_category("Main")
@export var main_menu: Node3D
@export var camera: Camera3D
@export var main_container: MarginContainer
@export var click_sound: AudioStreamPlayer
@export var settings_popup: ColorRect
@export var about_popup: ColorRect

@export_category("New Game")
@export var new_game_popup: ColorRect
@export var new_game_name_line_edit: LineEdit
@export var new_game_address_line_edit: LineEdit

@export_category("Lobby")
@export var lobby_popup: ColorRect
@export var lobby_start_button: Button
@export var player_list: VBoxContainer
@export var player_label_scene: PackedScene



@export_category("Scenes")
@export var main_scene: PackedScene
@export var game_scene: PackedScene
@export var player_scene: PackedScene


# Constants
const PORT = 6969

# Local Variables
var enet_peer := ENetMultiplayerPeer.new()
var game: Game
var players: Array[Player]


func hide_all_except(variant: Node):
	for child in get_children():
		if child is Control:
			child.hide()
	variant.show()
	
	
func _enter_tree() -> void:
	camera.current = true
	
	
func _ready() -> void:
	hide_all_except(main_container)


func _on_new_game_button_pressed() -> void:
	hide_all_except(new_game_popup)
	click_sound.play()


func _on_settings_button_pressed() -> void:
	hide_all_except(settings_popup)
	click_sound.play()


func _on_about_button_pressed() -> void:
	hide_all_except(about_popup)
	click_sound.play()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_new_game_back_button_pressed() -> void:
	hide_all_except(main_container)
	click_sound.play()


func _on_settings_back_button_pressed() -> void:
	hide_all_except(main_container)
	click_sound.play()


func _on_about_back_button_pressed() -> void:
	hide_all_except(main_container)
	click_sound.play()

func switch_to_game_scene() -> void:
	camera.current = false
	game = game_scene.instantiate()
	get_node("/root/main").add_child(game)
	main_menu.hide()
	hide()
	
@rpc("any_peer", "call_local", "reliable", 2)
func switch_to_menu_scene() -> void:
	#game.queue_free()
	#game = null
	#for child in get_node("/root/main").get_children():
		#if child is Player:
			#child.queue_free()
	#main_menu.show()
	#show()
	#camera.current = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func add_player_list_entry(peer_id, player_info):
	var label = player_label_scene.instantiate()
	label.name = str(peer_id)
	label.text = player_info.get("name", "Player")
	player_list.add_child(label)
	
	
func remove_player_list_entry(peer_id):
	var label = player_list.get_node(str(peer_id))
	label.queue_free()
	

func clear_player_list():
	for c in player_list.get_children():
		c.queue_free()


func _on_new_game_host_button_pressed() -> void:
	click_sound.play()
	
	Lobby.player_connected.connect(func(peer_id, player_info):
		if peer_id == multiplayer.get_unique_id():
			hide_all_except(lobby_popup)
			lobby_start_button.show()
			clear_player_list()
		
		print("Player connecting ", peer_id, " ", Lobby.players.size())
		add_player_list_entry(peer_id, player_info)
		#if Lobby.players.size() == 2:
		#	Lobby.load_game.rpc("res://scenes/game.tscn")
		)
	Lobby.player_disconnected.connect(func(peer_id):
		print("Disconnecting: ",peer_id)
		remove_player_list_entry(peer_id)
		)
	
	Lobby.player_info = {"name": new_game_name_line_edit.text}
	Lobby.create_game()
	
	#click_sound.play()
	#switch_to_game_scene()
	#
	#enet_peer.create_server(PORT, 0)
	#multiplayer.multiplayer_peer = enet_peer
	#multiplayer.peer_connected.connect(add_player)
	#multiplayer.peer_disconnected.connect(remove_player)
	#
	#add_player(multiplayer.get_unique_id())


func _on_new_game_join_button_pressed() -> void:
	click_sound.play()

	Lobby.player_info = {"name": new_game_name_line_edit.text}

	Lobby.player_connected.connect(func(peer_id, player_info):
		if peer_id == multiplayer.get_unique_id():
			hide_all_except(lobby_popup)
			lobby_start_button.hide()
			clear_player_list()
		
		add_player_list_entry(peer_id, player_info)
	)
	Lobby.player_disconnected.connect(func(peer_id):
		print("Disconnecting: ",peer_id)
		remove_player_list_entry(peer_id)
		)
	Lobby.server_disconnected.connect(func():
		get_tree().change_scene_to_packed(main_scene)
		)

	Lobby.join_game(new_game_address_line_edit.text)

	#click_sound.play()
	#switch_to_game_scene()
	#
	#enet_peer.create_client("localhost", PORT)
	#multiplayer.multiplayer_peer = enet_peer


func add_player(peer_id):
	#if players.size() >= 1:
	#	switch_to_menu_scene.rpc_id(peer_id)
	#	multiplayer.multiplayer_peer.disconnect_peer(peer_id)
	#	return
	
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	get_node("/root/main").add_child(player)
	
	players.append(player)
	
	
	player.set_spawn.rpc(game.table.get_spawn(players.size()).transform)
	

func remove_player(peer_id):
	var player = get_node("/root/main").get_node_or_null(str(peer_id))
	if player:
		players.erase(player)
		player.queue_free()
	switch_to_menu_scene()


func _on_lobby_start_button_pressed() -> void:
	click_sound.play()
	if Lobby.players.size() >= 2:
		Lobby.load_game.rpc("res://scenes/game.tscn")
	else:
		print("Not enough players to start game")


func _on_lobby_disconnect_button_pressed() -> void:
	click_sound.play()
	Lobby.remove_multiplayer_peer()
	get_tree().change_scene_to_packed(main_scene)
	
