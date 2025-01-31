class_name TileResource extends Resource


@export var name: String = ""
@export var image: CompressedTexture2D = load("res://assets/island/missing.png")
@export_flags("Flooded", "Always Spawn", "Exfil") var flags: int = 0


@export var spawned_totem: Enum.Totem
@export var spawned_class: Enum.Class
