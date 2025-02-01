class_name Tile extends Node3D

@onready var tile_mesh: MeshInstance3D = get_node("tile/Cube") as MeshInstance3D
@export var tile_image: Sprite3D
@export var player_icon: Sprite3D
@export var totem_icon: Sprite3D
@export var name_label: Label3D
@export var animation_player: AnimationPlayer

var resource: TileResource:
	set(value):
		resource = value
		load_resource(resource)

var flags := 0
var flooded := false:
	set(value):
		flooded = value
		if flooded:
			animation_player.play("flood")
		else:
			animation_player.play("shore_up")
var is_hovered := false

var spawned_class: Enum.Class
var spawned_totem: Enum.Totem

var row: int
var col: int
var cell_pos: Vector2i:
	get:
		return Vector2i(row, col)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_hovered:
				GameManager.handle_click_event.rpc_id(1, Enum.ClickAction.TILE, row, col)


func load_resource(res: TileResource) -> void:
	print(multiplayer.get_unique_id(), " Loading tile position: ", position, ", row: ", row, ", col: ", col, ", name: ", res.name)
	set_name(res.name)
	name_label.text = res.name
	
	tile_image.texture = res.image
	
	var mult = 24.0 / float(tile_image.texture.get_height())
	print("HEIGHT ", tile_image.texture.get_height(), " mult ", mult)
	tile_image.scale *= mult
	
	flags = res.flags
	flooded = res.flags & Enum.TileFlags.FLOODED
	
	spawned_class = res.spawned_class
	spawned_totem = res.spawned_totem
	
	if res.spawned_class != Enum.Class.NONE:
		player_icon.show()
		player_icon.texture = load("res://assets/sprites/player/%s.png" % Enum.Class.keys()[spawned_class].to_lower())
	else:
		player_icon.hide()


func _on_area_3d_mouse_entered() -> void:
	is_hovered = true
	tile_mesh.set_layer_mask_value(6, true)


func _on_area_3d_mouse_exited() -> void:
	is_hovered = false
	tile_mesh.set_layer_mask_value(6, false)
