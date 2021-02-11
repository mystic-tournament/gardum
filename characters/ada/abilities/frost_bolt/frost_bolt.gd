class_name FrostBolt, "res://characters/ada/abilities/frost_bolt/frost_bolt.png"
extends BaseAbility

const FrostBoltScene: PackedScene = preload("res://characters/ada/abilities/frost_bolt/frost_bolt_projectile.tscn")

func use(caster: BaseHero) -> void:
	.use(caster)
	var frost_bold: KinematicBody = FrostBoltScene.instance()
	frost_bold.global_transform = caster.get_projectile_spawn_pos().global_transform
	frost_bold.caster = caster
	GameSession.map.add_child(frost_bold)
