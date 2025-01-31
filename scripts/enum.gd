extends Node

# TODO: Make these into resources eventually
enum Class {
	NONE,
	DIVER,
	ENGINEER,
	NAVIGATOR,
	PILOT,
	EXPLORER,
	MESSENGER,
}

enum ClassSpecialAction {
	NONE,
	DIVE_HERE,
	SHORE_UP_TWICE,
	MOVE_ANOTHER_PLAYER_TWICE,
	FLY_HERE,
	MOVE_SHORE_UP_DIAG,
	SEND_CARD
}

# TODO: Make these into resources eventually
enum Totem {
	NONE,
	AIR,	# Gale's Guardian
	WATER,	# Tidal Grail
	EARTH,	# Heart of the Mountain
	FIRE,	# Inferno Shard
}


enum TileFlags {
	FLOODED = 1 << 0,
	ALWAYS_SPAWN = 1 << 1,
	EXFIL = 1 << 2,
}
