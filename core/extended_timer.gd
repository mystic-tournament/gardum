class_name ExtendedTimer
extends Timer
# Expands the basic timer by adding additional signals to it.
# Automatically have GameSession as a parent.


signal stopped
signal started(time)


func _init(time_sec: float) -> void:
	wait_time = time_sec
	one_shot = true
	GameSession.add_child(self)


func start(time_sec: float = -1) -> void:
	.start(time_sec)
	emit_signal("started", wait_time)


func stop() -> void:
	.stop()
	emit_signal("stopped")
