class_name BaseGamemodeOption
extends HBoxContainer


var editable: bool setget set_editable


func set_editable(_editable: bool) -> void:
	pass


func sync_with_connected_peer(_id: int) -> void:
	pass


func confirm_settings() -> void:
	pass
