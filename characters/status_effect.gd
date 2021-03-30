class_name StatusEffect


var caster # TODO 4.0: Use BaseActor (cyclic dependency)

var _timer: ExtendedTimer
var _modifiers: Dictionary # Contains actor properties as a key and their delta

# TODO 4.0: Use BaseActor for actor (cyclic dependency)
func _init(duration: float, actor = null) -> void:
	_timer = ExtendedTimer.new(duration)
	caster = actor


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_timer.free()


# TODO 4.0: Use BaseActor for _actor (cyclic dependency)
func apply(actor) -> void:
	for property_name in _modifiers:
		actor.set(property_name, actor.get(property_name) + _modifiers[property_name])
	_timer.start()


# TODO 4.0: Use BaseActor for _actor (cyclic dependency)
func clear(actor) -> void:
	for property_name in _modifiers:
		actor.set(property_name, actor.get(property_name) - _modifiers[property_name])


func get_timer() -> ExtendedTimer:
	return _timer
