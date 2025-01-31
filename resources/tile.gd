class_name TileResource extends Resource

enum Flags {
	FLOODED = 1 << 0,
	ALWAYS_SPAWN = 1 << 1,
	EXFIL = 1 << 2,
}

@export var name: String = ""
@export var image: CompressedTexture2D = load("res://assets/island/missing.png")
@export_flags("Flooded", "Always Spawn", "Exfil") var flags: int = 0
