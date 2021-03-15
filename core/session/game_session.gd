extends Node


signal started
signal about_to_start

const AdaScene: PackedScene = preload("res://characters/ada/ada.tscn")

var map: BaseMap
var gamemode: BaseGamemode

var _teams: Array
var _players: Array
var _current_player: Player


puppetsync func start_game() -> void:
	emit_signal("about_to_start")
	# warning-ignore:return_value_discarded
	get_tree().network_peer.connect("peer_disconnected", self, "_on_player_disconnected")
	for player in _players:
		var hero: Ada = AdaScene.instance()
		hero.set_name("Player" + str(player.get_network_master()))
		map.add_child(hero)
		player.get_controller().character = hero
		hero.translation.y = 2
	emit_signal("started")


func clear() -> void:
	# Remove all added controllers
	for child in get_children():
		child.free()

	gamemode = null
	_current_player = null
	_teams.clear()
	_players.clear()
	map.free()


func get_players_count() -> int:
	return _players.size()


func add_player(player: Player) -> void:
	assert(not player in _players, "GameSession already contains this player")
	_players.append(player)
	add_child(player.get_controller())
	if player.get_network_master() == get_tree().get_network_unique_id():
		_current_player = player

	var controller: BaseController = player.get_controller()
	# warning-ignore:return_value_discarded
	controller.connect("died", self, "_on_hero_died", [controller])
	# warning-ignore:return_value_discarded
	controller.connect("health_modified", self, "_on_health_modified")


func get_player(idx: int) -> Player:
	return _players[idx]


func get_current_player() -> Player:
	return _current_player


func get_teams_count() -> int:
	return _teams.size()


func add_team(team: Team) -> void:
	assert(not team in _teams, "GameSession already contains this team")
	_teams.append(team)


func get_team(idx: int) -> Team:
	return _teams[idx]


func _on_player_disconnected(id: int) -> void:
	for i in _players.size():
		var player: Player = _players[i]
		if player.get_network_master() == id:
			_players.remove(i)
			player.get_team().remove_player(player)

			var controller: BaseController = player.get_controller()
			controller.character.queue_free()
			controller.queue_free()
			return


func _on_hero_died(by: BaseController, dead_owner: BaseController) -> void:
	var player_by: Player = by.get_player()
	player_by.get_statistic().kills += 1
	player_by.get_team().get_statistic().kills += 1

	var player_who: Player = dead_owner.get_player()
	player_who.get_statistic().kills += 1
	player_who.get_team().get_statistic().kills += 1


func _on_health_modified(delta: int, by: BaseController) -> void:
	var player_by: Player = by.get_player()
	if delta < 0:
		player_by.get_statistic().damage -= delta
		player_by.get_team().get_statistic().damage -= delta
	else:
		player_by.get_statistic().healing += delta
		player_by.get_team().get_statistic().healing += delta
