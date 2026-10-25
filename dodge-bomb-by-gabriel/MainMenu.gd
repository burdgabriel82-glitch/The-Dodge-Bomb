extends Control

@onready var solo_button: Button = $Panel/MarginContainer/VBoxContainer/SoloButton
@onready var local_2p_button: Button = $Panel/MarginContainer/VBoxContainer/Local2PButton
@onready var lobby_button: Button = $Panel/MarginContainer/VBoxContainer/LobbyButton
@onready var colors_button: Button = $Panel/MarginContainer/VBoxContainer/PlayerColorsButton
@onready var exit_button: Button = $Panel/MarginContainer/VBoxContainer/ExitButton
@onready var lobby_code_label: Label = $Panel/MarginContainer/VBoxContainer/LobbyCodeLabel

func _ready() -> void:
	solo_button.pressed.connect(_on_solo_pressed)
	local_2p_button.pressed.connect(_on_local_2p_pressed)
	lobby_button.pressed.connect(_on_lobby_pressed)
	colors_button.pressed.connect(_on_colors_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	_refresh_lobby_code()

func _refresh_lobby_code() -> void:
	if Global.current_lobby_code == "":
		lobby_code_label.text = "Lobby Code: --"
	else:
		lobby_code_label.text = "Lobby Code: " + Global.current_lobby_code

func _on_solo_pressed() -> void:
	Global.game_mode = "solo"
	get_tree().change_scene_to_file("res://Arena.tscn")

func _on_local_2p_pressed() -> void:
	Global.game_mode = "local_2p"
	get_tree().change_scene_to_file("res://Arena.tscn")

func _on_lobby_pressed() -> void:
	Global.game_mode = "lobby"
	Global.generate_lobby_code()
	_refresh_lobby_code()
	get_tree().change_scene_to_file("res://Arena.tscn")

func _on_colors_pressed() -> void:
	get_tree().change_scene_to_file("res://PlayerColors.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
