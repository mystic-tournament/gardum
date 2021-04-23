class_name StatusEffectHUD
extends IconHUD


var status_effect: StatusEffect setget set_status_effect


func set_status_effect(effect: StatusEffect) -> void:
	if status_effect:
		effect.get_timer().disconnect("started", self, "_display_timer")
	status_effect = effect
	texture = load(Utils.get_script_icon(effect.script))
	_display_timer(effect.get_timer().get_time_left(), true)
	# warning-ignore:return_value_discarded
	effect.get_timer().connect("started", self, "_display_timer", [true])
