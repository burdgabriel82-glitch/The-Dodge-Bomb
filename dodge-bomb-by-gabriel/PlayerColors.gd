extends Control

const PALETTE := [
	Color("#FF3B30"),
	Color("#FF9500"),
	Color("#FFD60A"),
	Color("#A8E600"),
	Color("#34C759"),
	Color("#20C997"),
	Color("#32D7F5"),
	Color("#40A9FF"),
	Color("#1677FF"),
	Color("#5856D6"),
	Color("#8B5CF6"),
	Color("#BF5AF2"),
	Color("#FF2D95"),
	Color("#FF6B9A"),
	Color("#FFFFFF")
]

@onready var p1_button: Button = $Panel/MarginContainer/VBoxContainer/P1Button
@onready var p2_button: Button = $Panel/MarginContainer/VBoxContainer/P2Button
@onready var p1_preview: ColorRect = $Panel/MarginContainer/VBoxContainer/P1Preview
@onready var p2_preview: ColorRect = $Panel/MarginContainer/VBoxContainer/P2Preview
@onready var selected_player_label: Label = $Panel/MarginContainer/VBoxContainer/SelectedPlayerLabel
@onready var palette_grid: GridContainer = $Panel/MarginContainer/VBoxContainer/PaletteGrid
@onready var back_button: Button = $Panel/MarginContainer/VBoxContainer/BackButton

var active_player: int = 1

func _ready() -> void:
	p1_button.pressed.connect(_on_p1_selected)
	p2_button.pressed.connect(_on_p2_selected)
	back_button.pressed.connect(_on_back_pressed)
	_build_palette()
	_update_selected_player_ui()
	_update_previews()

func _build_palette() -> void:
	for child in palette_grid.get_children():
		child.queue_free()

	for color in PALETTE:
		var button := Button.new()
		button.custom_minimum_size = Vector2(34, 34)
		button.focus_mode = Control.FOCUS_NONE
		button.modulate = color
		button.pressed.connect(_on_palette_color_pressed.bind(color))
		palette_grid.add_child(button)

func _on_p1_selected() -> void:
	active_player = 1
	_update_selected_player_ui()

func _on_p2_selected() -> void:
	active_player = 2
	_update_selected_player_ui()

func _update_selected_player_ui() -> void:
	selected_player_label.text = "Editing: Player %d" % active_player
	if active_player == 1:
		p1_button.text = "P1 Selected"
		p2_button.text = "P2"
	else:
		p1_button.text = "P1"
		p2_button.text = "P2 Selected"

func _update_previews() -> void:
	p1_preview.color = Global.p1_color
	p2_preview.color = Global.p2_color

func _on_palette_color_pressed(color: Color) -> void:
	if active_player == 1:
		Global.p1_color = color
	else:
		Global.p2_color = color

	Global.save_colors()
	_update_previews()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
