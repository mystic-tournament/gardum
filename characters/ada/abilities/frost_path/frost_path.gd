class_name FrostPath, "res://characters/ada/abilities/frost_path/frost_path.png"
extends BaseAbility


const FrostPathPlaneScene: PackedScene = preload("res://characters/ada/abilities/frost_path/frost_path_plane.tscn")

const IMPULSE_POWER: int = 23
const HEIGHT_GAP: float = 0.02 # To avoid colliding on spawn


func _init() -> void:
	cooldown = 4


func use(caster: BaseHero) -> void:
	.use(caster)
	var plane: FrostPathPlane = FrostPathPlaneScene.instance()
	var caster_mesh: MeshInstance = caster.get_mesh_instance()
	plane.global_transform = caster_mesh.global_transform
	plane.translation.y -= caster_mesh.translation.y # Set position to floor
	GameSession.map.add_child(plane)

	caster.translation.y += plane.height() + HEIGHT_GAP # Move caster above plane
	caster.velocity = -caster_mesh.global_transform.basis.z * IMPULSE_POWER
