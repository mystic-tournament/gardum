class_name Actor
extends KinematicBody


signal died(by)
signal health_modified(delta, by)
signal ability_changed(idx, ability)
signal health_changed(value)
signal status_effect_added(effect)
signal status_effect_removed(effect)

enum Abilities {
	BASE_ATTACK,
	ABILITY1,
	ABILITY2,
	ABILITY3,
	ULTIMATE,
}

const MOVE_SPEED = 10
const JUMP_IMPULSE = 4

var max_health: int = 20
var health: int = max_health setget set_health
var damage_multiplier: float = 1
var incoming_damage_multiplier: float = 1

var velocity: Vector3

var _projectile_spawn_pos: Position3D
var _mesh_instance: MeshInstance
var _motion: Vector3
var _abilities: Array
var _status_effects: Array
# TODO 4.0: Use Controller type (cyclic dependency)
var _controller

onready var _floating_text: FloatingText = $FloatingText
onready var _rotation_tween: Tween = $RotationTween
onready var _collision: CollisionShape = $Collision


func _init() -> void:
	_abilities.resize(Abilities.size())
	rset_config("global_transform", MultiplayerAPI.RPC_MODE_REMOTE)


func move(delta: float, direction: Vector3, jump: bool) -> void:
	_motion = _motion.linear_interpolate(direction * MOVE_SPEED, Parameters.get_motion_interpolate_speed() * delta)

	var new_velocity: Vector3
	if is_on_floor() and velocity.length() < MOVE_SPEED:
		new_velocity = _motion
		if jump:
			new_velocity.y = JUMP_IMPULSE
		else:
			new_velocity.y = -1 # Apply gravity just a little to make checks such as is_on_floor() work
	else:
		new_velocity = velocity.linear_interpolate(_motion, Parameters.get_velocity_interpolate_speed() * delta)
		new_velocity.y = velocity.y - Parameters.get_gravity() * delta

	velocity = move_and_slide(new_velocity, Vector3.UP, true)
	# TODO: Replace with https://github.com/godotengine/godot/pull/37200
	rset_unreliable("global_transform", global_transform)


puppetsync func rotate_smoothly_to(y_radians: float) -> void:
	# warning-ignore:return_value_discarded
	_rotation_tween.interpolate_property(_mesh_instance, "rotation:y", _mesh_instance.rotation.y,
			y_radians, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	# warning-ignore:return_value_discarded
	_rotation_tween.interpolate_property(_collision, "rotation:y", _collision.rotation.y,
			y_radians, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	# warning-ignore:return_value_discarded
	_rotation_tween.start()


# TODO 4.0: Use Ability type for ability (cyclic dependency)
func set_ability(idx: int, ability) -> void:
	assert(ability, "Ability cannot be null")
	assert(_abilities[idx] == null, "Ability cannot be set twice")
	_abilities[idx] = ability
	emit_signal("ability_changed", idx, ability)


# TODO 4.0: Use Ability type for return type (cyclic dependency)
func get_ability(idx: int):
	return _abilities[idx]


func can_use_ability(idx: int) -> bool:
	if _abilities[idx] == null:
		return false
	var cooldown: TimerRef = _abilities[idx].get_cooldown()
	return not cooldown or cooldown.is_stopped()


puppetsync func use_ability(idx: int) -> void:
	_abilities[idx].use(self)


func get_rotation_time() -> float:
	return _rotation_tween.get_runtime()


# Change the health of the actor to a certain amount
func modify_health(delta: int, by: Actor = null) -> void:
	if health <= 0:
		return
	delta = int(delta * incoming_damage_multiplier)
	if by:
		# Apply attacker modifiers
		if delta < 0:
			delta = int(delta * by.damage_multiplier)
	_floating_text.show_text(delta)
	# TODO 4.0: Remove extra self
	self.health = health + delta
	emit_signal("health_modified", delta, by)
	if health <= 0:
		visible = false
		emit_signal("died", by)


# Set the health of the actor to a specific value (will not emit health_modified)
func set_health(value: int) -> void:
	health = value
	emit_signal("health_changed", health)


func respawn(position: Vector3) -> void:
	translation = position
	visible = true
	# TODO 4.0: Remove extra self
	self.health = max_health
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func get_projectile_spawn_pos() -> Position3D:
	return _projectile_spawn_pos


func get_mesh_instance() -> MeshInstance:
	return _mesh_instance


# TODO 4.0: Use Controller return type (cyclic dependency)
func get_controller():
	return _controller


func apply_status_effect(script: GDScript, caster: Actor = null) -> void:
	# Check if effect is already exists
	for effect in _status_effects:
		if effect.caster == caster and effect is script:
			effect.get_timer().start() # Restart timer
			return

	# No such effect found, create a new one
	var new_effect: StatusEffect = script.new(caster)
	_status_effects.append(new_effect)
	# warning-ignore:return_value_discarded
	new_effect.get_timer().connect("timeout", self, "remove_status_effect", [new_effect])
	new_effect.apply(self)
	emit_signal("status_effect_added", new_effect)


func remove_status_effect(effect: StatusEffect) -> void:
	_status_effects.erase(effect)
	effect.get_timer().disconnect("timeout", self, "remove_status_effect")
	effect.clear(self)
	emit_signal("status_effect_removed", effect)
