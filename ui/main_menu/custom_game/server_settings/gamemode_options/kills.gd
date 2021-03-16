extends BaseGamemodeOption


onready var _kills_count: SpinBox = $SpinBox


func _ready() -> void:
	_kills_count.rset_config("value", MultiplayerAPI.RPC_MODE_PUPPET)


func set_editable(value: bool) -> void:
	_kills_count.editable = value


func sync_with_connected_peer(id: int) -> void:
	_kills_count.rset_id(id, "value", _kills_count.value)


func confirm_settings() -> void:
	GameSession.gamemode.kills_to_win = _kills_count.value


func _on_kills_count_changed(count: int) -> void:
	if get_tree().has_network_peer() and get_tree().is_network_server():
		_kills_count.rset("value", count)
