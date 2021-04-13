extends Area


export(GDScript) var status_effect: GDScript

onready var _respawn_timer: Timer = $RespawnTimer
onready var _position: Position3D = $Position


func _respawn() -> void:
	_position.visible = true
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(node: Node) -> void:
	var actor := node as Actor
	if actor:
		disconnect("body_entered", self, "_on_body_entered")
		_position.visible = false
		_respawn_timer.start()
		if status_effect:
			actor.apply_status_effect(status_effect)
