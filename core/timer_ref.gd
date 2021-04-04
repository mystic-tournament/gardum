class_name TimerRef
# Timer that can be used with objects that do not inherit from Node.
# Encapsulates a Timer that automatically have GameSession as a parent.
# The Timer will be deleted automatically on unreferencing.
# Also have additional convenient signals.


var _timer := Timer.new()

# warning-ignore:unused_signal: called by _timer timeout
signal timeout
signal stopped
signal started(time)


func _init(time_sec: float, one_shot: bool = true) -> void:
	_timer.wait_time = time_sec
	_timer.one_shot = one_shot
	GameSession.add_child(_timer)
	# warning-ignore:return_value_discarded
	_timer.connect("timeout", self, "emit_signal", ["timeout"])


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_timer.queue_free()


func start(time_sec: float = -1) -> void:
	_timer.start(time_sec)
	emit_signal("started", _timer.wait_time)


func stop() -> void:
	_timer.stop()
	emit_signal("stopped")


func is_stopped() -> bool:
	return _timer.is_stopped()
