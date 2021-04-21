extends StatusEffect


func _init(caster: Actor = null).(15, caster) -> void:
	var timer := TimerRef.new(1, false)
	timer.start()
	var healing := StatusEffect.Connection.new()
	healing.sender = timer
	healing.signal = "timeout"
	healing.method = "modify_health"
	healing.binds = [2]
	_connections.append(healing)
