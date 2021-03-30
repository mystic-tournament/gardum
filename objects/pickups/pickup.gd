extends Area


export(GDScript) var status_effect: GDScript


func _on_body_entered(node: Node) -> void:
	var actor := node as BaseActor
	if actor:
		queue_free()
		if status_effect:
			actor.apply_status_effect(status_effect)
