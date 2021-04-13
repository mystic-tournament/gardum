class_name Controller
extends Node
# TODO: Extend from https://github.com/godotengine/godot/pull/37200


# Signals connected to assigned actor
signal died(by)
signal health_modified(delta, by)
signal ability_changed(idx, ability)
signal health_changed(value)

var input_enabled: bool = true
var actor: Actor setget set_actor

# TODO 4.0: Use Player type (cyclic dependency)
var _player


# TODO 4.0: Use Player type for player (cyclic dependency)
func _init(player) -> void:
	_player = player


func set_actor(new_actor: Actor) -> void:
	actor = new_actor
	actor.set_network_master(get_network_master(), true)
	actor._controller = self
	# warning-ignore:return_value_discarded
	actor.connect("died", self, "_emit_died_signal")
	# warning-ignore:return_value_discarded
	actor.connect("health_modified", self, "_emit_health_modified_signal")
	# warning-ignore:return_value_discarded
	actor.connect("ability_changed", self, "_emit_ability_changed_signal")
	# warning-ignore:return_value_discarded
	actor.connect("health_changed", self, "_emit_health_changed_signal")


# TODO 4.0: Use Player return type (cyclic dependency)
func get_player():
	return _player


func get_look_rotation() -> Vector3:
	return Vector3.ZERO


func _emit_died_signal(by: Actor) -> void:
	emit_signal("died", by.get_controller())


func _emit_health_modified_signal(delta: int, by: Actor) -> void:
	emit_signal("health_modified", delta, by.get_controller() if by else null)


func _emit_ability_changed_signal(idx: int, ability: Ability) -> void:
	emit_signal("ability_changed", idx, ability)


func _emit_health_changed_signal(value: int) -> void:
	emit_signal("health_changed", value)
