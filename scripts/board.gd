class_name Board extends Node3D

@onready var TILE_COUNT := count_island_tiles()

@export var tile_parent: Node3D
@export var tile_scene: PackedScene
@export var tile_resources_dir: String

@export var pawn_parent: Node3D
@export var pawn_scene: PackedScene
@export var pawn_resources_dir: String

const ISLAND_SHAPE: Array = [
	[0, 0, 1, 1, 0, 0],
	[0, 1, 1, 1, 1, 0],
	[1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1],
	[0, 1, 1, 1, 1, 0],
	[0, 0, 1, 1, 0, 0],
]

var tiles: Array[Tile]
var pawns: Array[Pawn]

func count_island_tiles() -> int:
	var count = 0
	for row in ISLAND_SHAPE:
		for cell in row:
			if cell == 1:
				count += 1
	return count

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func generate_tiles(seed_value):
	var tile_resources = Util.load_all_resources_in_dir(tile_resources_dir) as Array[TileResource]
	assert(tile_resources.size() >= TILE_COUNT, "%s must have at least %d resources!" % [tile_resources_dir, TILE_COUNT])
	
	seed(seed_value)
	
	var final_resources: Array[TileResource]
	var opt_resources: Array[TileResource]
	
	for resource in tile_resources:
		if resource.flags & Enum.TileFlags.ALWAYS_SPAWN:
			final_resources.append(resource)
		else:
			opt_resources.append(resource)
	
	# Fill in remaining tiles from opt_resources
	Util.seeded_shuffle(opt_resources)
	for i in range(TILE_COUNT - final_resources.size()):
		final_resources.append(opt_resources[i])
	Util.seeded_shuffle(final_resources)
	
	var t_scale = 0.013
	# Spawn tiles
	for resource in final_resources:
		var new_tile = tile_scene.instantiate() as Tile
		tile_parent.add_child(new_tile)
		new_tile.resource = resource
		new_tile.scale = Vector3(t_scale, t_scale, t_scale)
		tiles.append(new_tile)
		
	# Calculate the center offset
	var rows = ISLAND_SHAPE.size()
	var cols = ISLAND_SHAPE[0].size()
	var spacing = t_scale * 2.2
	var offset_x = (rows - 1) * t_scale * 2.2 / 2.0  # Center offset for X
	var offset_z = (cols - 1) * t_scale * 2.2 / 2.0  # Center offset for Z
		
	# Position tiles
	var tile_idx = 0
	for row_idx in range(ISLAND_SHAPE.size()):
		for col_idx in range(ISLAND_SHAPE[row_idx].size()):
			if ISLAND_SHAPE[row_idx][col_idx] <= 0:
				continue
			# Place island here
			var tile = tiles[tile_idx]
			tile.position = Vector3(row_idx * spacing - offset_x, 0.016, col_idx * spacing - offset_z)
			tile.row = row_idx
			tile.col = col_idx
			tile_idx += 1
	

	
func get_tile_data() -> Array:
	var tile_data: Array = []
	for tile in tiles:
		tile_data.append({
			"resource_path": tile.resource.resource_path,
			"position": tile.position,
			"scale": tile.scale.x,
			"row": tile.row,
			"col": tile.col
		})
	return tile_data
	

func generate_tiles_from_data(tile_data: Array) -> void:
	# Clear existing tiles
	for tile in tiles:
		tile.queue_free()
	tiles.clear()
	
	for data in tile_data:
		var resource = load(data["resource_path"])
		if !resource:
			printerr("Failed to load resource: ", data["resource_path"])
			continue
		print(multiplayer.get_unique_id(), " Loaded tile: ", data)
		var new_tile = tile_scene.instantiate() as Tile
		tile_parent.add_child(new_tile)
		new_tile.position = data["position"]
		var scale = data["scale"]
		new_tile.scale = Vector3(scale, scale, scale)
		new_tile.row = data["row"]
		new_tile.col = data["col"]
		new_tile.resource = resource
		print("Tile positioned: ", new_tile.position, " (expected: ", data["position"], ")")
		print("Tile name: ", new_tile.name)
		tiles.append(new_tile)


func get_tile_from_row_col(row: int, col: int) -> Tile:
	var tiles = tiles.filter(func(tile: Tile): return tile.row == row and tile.col == col)
	return tiles[0] if tiles else null

func get_spawn_tiles_for_class(clazz: Enum.Class) -> Array[Tile]:
	return tiles.filter(func(child): return child.spawned_class == clazz)


func generate_pawns() -> void:
	var pawn_resources = Util.load_all_resources_in_dir(pawn_resources_dir) as Array[PawnResource]
	Util.seeded_shuffle(pawn_resources)
	pawn_resources.resize(Lobby.players.size())
	for resource in pawn_resources:
		var new_pawn = pawn_scene.instantiate() as Pawn
		pawn_parent.add_child(new_pawn)
		pawns.append(new_pawn)
		new_pawn.resource = resource
		new_pawn.scale = Vector3(0.016, 0.016, 0.016)
		var spawn_tiles = get_spawn_tiles_for_class(new_pawn.clazz)
		new_pawn.tile = spawn_tiles.pick_random()


func get_pawn_data() -> Array:
	var pawn_data: Array = []
	for pawn in pawns:
		pawn_data.append({
			"resource_path": pawn.resource.resource_path,
			"position": pawn.position,
			"scale": pawn.scale.x,
			"row": pawn.row,
			"col": pawn.col
		})
	return pawn_data
		

func generate_pawns_from_data(pawn_data: Array) -> void:
	# Clear existing tiles
	for pawn in pawns:
		pawn.queue_free()
	pawns.clear()
	
	for data in pawn_data:
		var resource = load(data["resource_path"])
		if !resource:
			printerr("Failed to load resource: ", data["resource_path"])
			continue
		print(multiplayer.get_unique_id(), " Loaded pawn: ", data)
		var new_pawn = pawn_scene.instantiate() as Pawn
		pawn_parent.add_child(new_pawn)
		new_pawn.resource = resource
		new_pawn.position = data["position"]
		var scale = data["scale"]
		new_pawn.scale = Vector3(scale, scale, scale)
		var tile = get_tile_from_row_col(data["row"], data["col"])
		new_pawn.tile = tile
		print("Pawn positioned: ", new_pawn.position, " (expected: ", data["position"], ")")
		print("Pawn name: ", new_pawn.name)
		pawns.append(new_pawn)
