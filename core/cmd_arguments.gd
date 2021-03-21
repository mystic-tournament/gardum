extends Node
# Parses command line arguments
# Currently very robust until https://github.com/godotengine/godot/pull/44594


var server: bool
var direct_connect: bool
var single_game: bool


func _init() -> void:
	var args: PoolStringArray = OS.get_cmdline_args()
	if "--server" in args:
		server = true
	elif "--connect" in args:
		direct_connect = true
	elif "--single-game" in args:
		single_game = true
