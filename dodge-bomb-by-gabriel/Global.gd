extends Node

const DEFAULT_P1_COLOR := Color("#1677FF")
const DEFAULT_P2_COLOR := Color("#FF3B30")

var p1_color: Color = DEFAULT_P1_COLOR
var p2_color: Color = DEFAULT_P2_COLOR
var game_mode: String = "solo"
var current_lobby_code: String = ""

func _ready() -> void:
	randomize()
	configure_default_input_map()
	load_colors()

func configure_default_input_map() -> void:
	var actions := [
		"move_left_p1", "move_right_p1", "move_up_p1", "move_down_p1",
		"move_left_p2", "move_right_p2", "move_up_p2", "move_down_p2"
	]

	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)

	var key_map := {
		"move_left_p1": KEY_A,
		"move_right_p1": KEY_D,
		"move_up_p1": KEY_W,
		"move_down_p1": KEY_S,
		"move_left_p2": KEY_LEFT,
		"move_right_p2": KEY_RIGHT,
		"move_up_p2": KEY_UP,
		"move_down_p2": KEY_DOWN
	}

	for action_name in key_map:
		var event := InputEventKey.new()
		event.physical_keycode = key_map[action_name]
		if InputMap.action_has_event(action_name, event):
			continue
		InputMap.action_add_event(action_name, event)

func generate_lobby_code() -> String:
	var chars := "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	var code := ""
	for i in range(4):
		code += chars[randi() % chars.length()]
	current_lobby_code = code
	return code

func save_colors() -> void:
	var config := ConfigFile.new()
	config.set_value("player_colors", "p1", p1_color.to_html())
	config.set_value("player_colors", "p2", p2_color.to_html())
	config.save("user://player_colors.cfg")

func load_colors() -> void:
	var config := ConfigFile.new()
	var err := config.load("user://player_colors.cfg")
	if err != OK:
		p1_color = DEFAULT_P1_COLOR
		p2_color = DEFAULT_P2_COLOR
		return

	if config.has_section_key("player_colors", "p1"):
		p1_color = Color(config.get_value("player_colors", "p1"))
	if config.has_section_key("player_colors", "p2"):
		p2_color = Color(config.get_value("player_colors", "p2"))
