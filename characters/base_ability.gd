class_name BaseAbility


signal used

var _cooldown: ExtendedTimer


func use(_caster: BaseActor) -> void:
	if _cooldown:
		_cooldown.start()
	emit_signal("used")


func get_cooldown() -> ExtendedTimer:
	return _cooldown
