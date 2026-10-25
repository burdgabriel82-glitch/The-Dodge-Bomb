extends Node2D

const PLAYER_SCENE := preload("res://Player.tscn")

@onready var timer_label: Label = $HUD/TimerLabel
@onready var lobby_code_label: Label = $HUD/LobbyCodeLabel
@onready var final_time_label: Label = $HUD/GameOverPanel/FinalTimeLabel
@onready var winner_label: Label = $HUD/GameOverPanel/WinnerLabel
@onready var retry_button: Button = $HUD/GameOverPanel/RetryButton
@onready var main_menu_button: Button = $HUD/GameOverPanel/MainMenuButton
@onready var game_over_panel: Panel = $HUD/GameOverPanel
@onready var players_container: Node2D = $Players
@onready var bombs_container: Node2D = $Bombs
@onready var pickups_container: Node2D = $Pickups

var match_time: float = 0.0
var game_active: bool = true
var bomb_spawn_timer: float = 1.2
var pickup_spawn_timer: float = 3.5

func _ready() -> void:
	randomize()
	game_over_panel.visible = false
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	if Global.game_mode == "lobby":
		Global.generate_lobby_code()
		lobby_code_label.text = "Lobby Code: " + Global.current_lobby_code
	else:
		lobby_code_label.visible = false

	_spawn_players()
	_spawn_pickup()
	_spawn_bomb()

func _process(delta: float) -> void:
	if not game_active:
		return

	match_time += delta
	timer_label.text = _format_time(match_time)

	bomb_spawn_timer -= delta
	if bomb_spawn_timer <= 0.0:
		_spawn_bomb()
		bomb_spawn_timer = randf_range(1.0, 2.2)

	pickup_spawn_timer -= delta
	if pickup_spawn_timer <= 0.0:
		_spawn_pickup()
		pickup_spawn_timer = randf_range(5.0, 8.0)

	_update_bombs(delta)
	_update_pickups()
	_check_game_state()

func _spawn_players() -> void:
	for child in players_container.get_children():
		child.queue_free()

	if Global.game_mode == "solo":
		var player := PLAYER_SCENE.instantiate()
		player.name = "Player1"
		player.player_id = 1
		player.position = Vector2(220, 220)
		players_container.add_child(player)
		return

	var p1 := PLAYER_SCENE.instantiate()
	p1.name = "Player1"
	p1.player_id = 1
	p1.position = Vector2(220, 220)
	players_container.add_child(p1)

	var p2 := PLAYER_SCENE.instantiate()
	p2.name = "Player2"
	p2.player_id = 2
	p2.position = Vector2(920, 220)
	players_container.add_child(p2)

func _spawn_bomb() -> void:
	var arena_size := Vector2(1200, 720)
	var bomb := Node2D.new()
	bomb.name = "Bomb"
	bomb.position = Vector2(
		randi_range(80, int(arena_size.x) - 80),
		randi_range(80, int(arena_size.y) - 80)
	)

	var body := ColorRect.new()
	body.position = Vector2(-12, -12)
	body.size = Vector2(24, 24)
	body.color = Color("#FFB703")
	bomb.add_child(body)

	var warning := ColorRect.new()
	warning.position = Vector2(-16, -16)
	warning.size = Vector2(32, 32)
	warning.color = Color("#FF4D4D")
	warning.modulate = Color(1, 0.25, 0.25, 0.75)
	bomb.add_child(warning)

	bomb.set_meta("time_left", randf_range(1.8, 3.2))
	bomb.set_meta("radius", 95.0)
	bombs_container.add_child(bomb)

func _update_bombs(delta: float) -> void:
	for bomb in bombs_container.get_children():
		var time_left: float = bomb.get_meta("time_left", 0.0)
		time_left -= delta
		bomb.set_meta("time_left", time_left)

		var warning_node := bomb.get_child(1) if bomb.get_child_count() > 1 else null
		if warning_node != null and warning_node is ColorRect:
			var pulse = 1.0 - (time_left / 3.0)
			warning_node.modulate = Color(1.0, 0.2 + pulse, 0.2 + pulse, 0.7)

		if time_left <= 0.0:
			_explode_bomb(bomb)

func _explode_bomb(bomb: Node2D) -> void:
	var radius: float = bomb.get_meta("radius", 90.0)
	var explosion_center := bomb.global_position

	var effect := Node2D.new()
	effect.position = explosion_center
	var blast := ColorRect.new()
	blast.position = Vector2(-radius * 0.5, -radius * 0.5)
	blast.size = Vector2(radius, radius)
	blast.color = Color("#FFD166")
	blast.modulate = Color(1, 0.7, 0.2, 0.8)
	effect.add_child(blast)
	add_child(effect)

	for player in get_tree().get_nodes_in_group("players"):
		if not player.has_method("is_alive"):
			continue

		var player_node = player as Node2D
		if player_node.is_alive() and player_node.global_position.distance_to(explosion_center) <= radius:
			player.eliminate()

	var timer := get_tree().create_timer(0.18)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(effect):
			effect.queue_free()
	)

	bomb.queue_free()

func _spawn_pickup() -> void:
	if pickups_container.get_child_count() > 0:
		return

	var valid_positions := [
		Vector2(200, 200),
		Vector2(1000, 160),
		Vector2(300, 520),
		Vector2(850, 500),
		Vector2(620, 360)
	]

	var spawn_pos := valid_positions[randi() % valid_positions.size()]
	var pickup := Node2D.new()
	pickup.name = "Pickup"
	pickup.position = spawn_pos

	var rect := ColorRect.new()
	rect.position = Vector2(-12, -12)
	rect.size = Vector2(24, 24)
	rect.color = Color("#00E5FF")
	pickup.add_child(rect)

	var type_roll := randi() % 2
	if type_roll == 0:
		pickup.set_meta("pickup_type", "shield")
		rect.color = Color("#7BDFF2")
	else:
		pickup.set_meta("pickup_type", "speed")
		rect.color = Color("#A8E600")

	pickups_container.add_child(pickup)

func _update_pickups() -> void:
	for pickup in pickups_container.get_children():
		for player in get_tree().get_nodes_in_group("players"):
			if not player.has_method("is_alive"):
				continue

			var player_node = player as Node2D
			if player_node.is_alive() and player_node.global_position.distance_to(pickup.global_position) < 30.0:
				var kind := pickup.get_meta("pickup_type", "speed")
				if kind == "shield":
					player.apply_shield()
				else:
					player.apply_speed_boost()
				pickup.queue_free()
				return

func _format_time(seconds: float) -> String:
	var total_minutes := int(seconds) / 60
	var total_seconds := int(seconds) % 60
	var milliseconds := int((seconds - int(seconds)) * 10)
	return "%02d:%02d.%01d" % [total_minutes, total_seconds, milliseconds]

func _check_game_state() -> void:
	if not game_active:
		return

	var alive_players := []
	for player in get_tree().get_nodes_in_group("players"):
		if player.has_method("is_alive") and player.is_alive():
			alive_players.append(player)

	if Global.game_mode == "solo":
		if alive_players.size() == 0:
			_end_game("Final Survival Time: " + _format_time(match_time))
		return

	if alive_players.size() <= 1:
		if alive_players.size() == 1:
			var winner_id := alive_players[0].player_id
			_end_game("Player %d Wins!" % winner_id)
		else:
			_end_game("Draw!")
		return

func _end_game(message: String) -> void:
	game_active = false
	game_over_panel.visible = true

	if Global.game_mode == "solo":
		final_time_label.text = "Final Survival Time: " + _format_time(match_time)
		winner_label.text = "Game Over"
	else:
		final_time_label.text = "Match Result"
		winner_label.text = message

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
