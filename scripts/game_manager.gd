extends Node3D

signal click_event(peer_id: int, click_action: Enum.ClickAction, row: int, col: int)

@rpc("any_peer", "call_local", "reliable")
func handle_click_event(action, row, col):
	var peer_id = multiplayer.get_remote_sender_id()
	print("Peer ", peer_id, " clicked on tile: ", row, " ", col)
	click_event.emit(peer_id, action, row, col)
