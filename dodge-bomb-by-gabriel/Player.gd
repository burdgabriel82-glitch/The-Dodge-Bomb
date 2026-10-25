extends CharacterBody2D

@export var player_id: int = 1
@export var speed: float = 300.0

@onready var body_rect: ColorRect = $Body
@onready var shield_visual: ColorRect = $ShieldVisual

var is_shielded: bool = false
var is_speed_boosted: bool = false
var alive: bool = true

func _ready() -> void:
	add_to_group("players")
	_apply_color()
	_update_visuals()

func _apply_color() -> void:
	if player_id == 1:
		body_rect.color = Global.p1_color
	else:
		body_rect.color = Global.p2_color

func _update_visuals() -> void:
	shield_visual.visible = false

func _physics_process(_delta: float) -> void:
	if not alive:
		return

	var direction := get_input_vector()
	var current_speed := speed
	if is_speed_boosted:
		current_speed *= 1.5

	if direction.length() > 0.1:
		velocity = direction.normalized() * current_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func get_input_vector() -> Vector2:
	var input_vector := Vector2.ZERO
	if player_id == 1:
		input_vector.x = Input.get_axis("move_left_p1", "move_right_p1")
		input_vector.y = Input.get_axis("move_up_p1", "move_down_p1")
	else:
		input_vector.x = Input.get_axis("move_left_p2", "move_right_p2")
		input_vector.y = Input.get_axis("move_up_p2", "move_down_p2")

	return input_vector

func apply_shield() -> void:
	is_shielded = true
	shield_visual.visible = true
	shield_visual.color = Color("#7BDFF2")
	shield_visual.size = Vector2(42, 42)

func apply_speed_boost() -> void:
	if is_speed_boosted:
		return

	is_speed_boosted = true
	await get_tree().create_timer(5.0).timeout
	if is_inside_tree():
		is_speed_boosted = false

func eliminate() -> void:
	if not alive:
		return

	if is_shielded:
		is_shielded = false
		shield_visual.visible = false
		return

	alive = false
	visible = false
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0

func is_alive() -> bool:
	return alive
