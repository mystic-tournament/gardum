class_name ServerSettings
extends PanelContainer


signal teams_count_changed(count)
signal slots_count_changed(count)

var editable: bool setget set_editable

onready var _vbox = $VBox
onready var _map_edit: LineEdit = $VBox/Map/LineEdit
onready var _teams_enabled: CheckBox = $VBox/TeamsEnabled
onready var _teams_count: SpinBox = $VBox/TeamsCount/SpinBox
onready var _slots_count: SpinBox = $VBox/SlotsCount/SpinBox
onready var _teams_count_box: HBoxContainer = $VBox/TeamsCount
onready var _mode_button: OptionButton = $VBox/Mode/OptionButton
onready var _additional_settings_idx: int = _vbox.get_child_count()

var _map: PackedScene


func _ready() -> void:
	# TODO: Allow to select map
	_map_edit.text = "res://maps/sky_roof/sky_roof.tscn"
	_on_map_changed(_map_edit.text)

	# TODO 4.0: Remove extra self
	self.editable = false
	_on_teams_toggled(_teams_enabled.pressed)

	# Allow to sync server configuration over network
	_teams_enabled.rset_config("pressed", MultiplayerAPI.RPC_MODE_PUPPET)
	_slots_count.rset_config("value", MultiplayerAPI.RPC_MODE_PUPPET)
	_teams_count.rset_config("value", MultiplayerAPI.RPC_MODE_PUPPET)
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_sync_with_connected_peer")

	# warning-ignore:return_value_discarded
	GameSession.connect("about_to_start", self, "_confirm_settings")


func set_editable(value: bool) -> void:
	_teams_enabled.disabled = !value
	_slots_count.editable = value
	_teams_count.editable = value
	_mode_button.disabled = !value
	for i in range(_additional_settings_idx, _vbox.get_child_count()):
		_vbox.get_child(i).editable = value


func get_teams_count() -> int:
	if _teams_enabled.pressed:
		return int(_teams_count.value)
	return 1


func get_slots_count() -> int:
	return int(_slots_count.value)


func _on_map_changed(path: String) -> void:
	_map = load(path)
	_mode_button.clear()

	var modes: Array = Utils.get_scene_property(_map.get_state(), 0, "script").get_supported_modes()
	for i in modes.size():
		_mode_button.add_item(modes[i].name())
		_mode_button.set_item_metadata(i, modes[i])
	_on_gamemode_changed(0)


func _on_teams_toggled(toggled: bool) -> void:
	_teams_count_box.visible = toggled
	_on_teams_count_changed(int(_teams_count.value) if toggled else 1)
	if get_tree().has_network_peer() and get_tree().is_network_server():
		_teams_enabled.rset("pressed", _teams_enabled.pressed)


func _on_teams_count_changed(count: int) -> void:
	emit_signal("teams_count_changed", count)
	if get_tree().has_network_peer() and get_tree().is_network_server():
		_teams_count.rset("value", _teams_count.value)


func _on_slots_count_changed(count: int) -> void:
	emit_signal("slots_count_changed", count)
	if get_tree().has_network_peer() and get_tree().is_network_server():
		_slots_count.rset("value", _slots_count.value)


func _sync_with_connected_peer(id: int) -> void:
	if !get_tree().is_network_server():
		return
	_teams_enabled.rset_id(id, "pressed", _teams_enabled.pressed)
	_slots_count.rset_id(id, "value", _slots_count.value)
	_teams_count.rset_id(id, "value", _teams_count.value)
	for i in range(_additional_settings_idx, _vbox.get_child_count()):
		_vbox.get_child(i).sync_with_connected_peer(id)


func _on_gamemode_changed(idx: int) -> void:
	# Remove previous gamemode settings
	for i in range(_additional_settings_idx, _vbox.get_child_count()):
		_vbox.get_child(i).queue_free()

	# Load additional gamemode settings
	var additional_settings: Array = _mode_button.get_item_metadata(idx).additional_settings()
	for scene in additional_settings:
		_vbox.add_child(scene.instance())


func _confirm_settings() -> void:
	GameSession.gamemode = _mode_button.get_selected_metadata().new()
	GameSession.map = _map.instance()
	for i in range(_additional_settings_idx, _vbox.get_child_count()):
		_vbox.get_child(i).confirm_settings()
