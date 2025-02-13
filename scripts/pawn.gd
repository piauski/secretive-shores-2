class_name Pawn extends Node3D

@onready var pawn_mesh = get_node("pawn/Sphere")

var resource: PawnResource:
	set(value):
		resource = value
		load_resource(resource)

var row: int
var col: int
var cell_pos: Vector2i:
	get:
		return Vector2i(row, col)
	set(value):
		row = value.x
		col = value.y
		
var tile: Tile:
	set(value):
		tile = value
		cell_pos = tile.cell_pos
		position = tile.position

var is_hovered := false

var clazz: Enum.Class
var special_action: Enum.ClassSpecialAction
var image: CompressedTexture2D
var pawn_color: Color


func _ready() -> void:
	pawn_mesh.material_override = preload("res://assets/models/m_pawn.tres").duplicate() as BaseMaterial3D
	pawn_mesh.material_override.emission_energy_multiplier = 0.2
	
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_hovered:
				GameManager.handle_click_event.rpc_id(1, Enum.ClickAction.PAWN, row, col)

func load_resource(res: PawnResource) -> void:
	set_name(res.name)
	clazz = res.clazz
	special_action = res.special_action
	image = res.image
	pawn_color = res.pawn_color
	pawn_mesh.material_override.albedo_color = res.pawn_color
	pawn_mesh.material_override.emission = res.pawn_color


func _on_area_3d_mouse_entered() -> void:
	is_hovered = true
	pawn_mesh.set_layer_mask_value(6, true)


func _on_area_3d_mouse_exited() -> void:
	is_hovered = false
	pawn_mesh.set_layer_mask_value(6, false)
