class_name AbilityHUD
extends TextureRect


var ability: BaseAbility setget set_ability
var action: String setget set_action

onready var _key_label: Label = $KeyLabel
onready var _cooldown_progress: TextureProgress = $CooldownProgress
onready var _cooldown_label: NumericLabel = $CooldownLabel
onready var _tween: Tween = $Tween


func set_action(new_action: String) -> void:
	action = new_action
	var event = InputMap.get_action_list(action).front()
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_LEFT:
				_key_label.text = "LMB"
			BUTTON_RIGHT:
				_key_label.text = "RMB"
	elif event is InputEventKey:
		_key_label.text = OS.get_scancode_string(event.scancode)
	else:
		assert("Unknown event type")


func set_ability(new_ability: BaseAbility) -> void:
	if ability:
		ability.get_cooldown().disconnect("started", self, "_display_cooldown")
	ability = new_ability

	if not ability:
		return

	texture = load(Utils.get_script_icon(ability.script))

	var cooldown: ExtendedTimer = ability.get_cooldown()
	if cooldown:
		# warning-ignore:return_value_discarded
		cooldown.connect("started", self, "_display_cooldown")


func _display_cooldown(time: float) -> void:
	_cooldown_progress.max_value = time

	# Animation
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(_cooldown_progress, "value", time, 0, time)
	# warning-ignore:return_value_discarded
	_tween.interpolate_method(_cooldown_label, "set_ceil", time, 0, time)

	# Reset cooldown text at end
	# warning-ignore:return_value_discarded
	_tween.interpolate_callback(_cooldown_label, time, "set_text", String())

	# warning-ignore:return_value_discarded
	_tween.start()
