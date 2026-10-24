class_name Main extends Node2D

@export var camera: Camera2D
@export var hud: Hud
@export var map: Map
@export var palettes: Array[Palette]
@export var player: Player
@export var enemies: Node2D
@export var lives: int = 3
@export var win_percent: float = 75.0

var game_over := false
var _palette_index := 0

func _ready() -> void:
	camera.position = map.get_pixel_size() / 2
	player.trail_completed.connect(_on_trail_completed)
	player.died.connect(_lose_life)
	map.area_claimed.connect(_on_area_claimed)
	map.burn_reached_head.connect(_lose_life)
	for enemy: Enemy in enemies.get_children():
		enemy.hit_trail.connect(_on_enemy_hit_trail)
	hud.restart_requested.connect(_on_restart_requested)
	hud.set_lives(lives)
	hud.set_progress(0.0)
	hud.set_target(win_percent)
	_apply_palette()

func _on_trail_completed() -> void:
	if map.is_burning():
		map.clear_trail()
	else:
		map.close_trail(_get_enemy_cells())

func _get_enemy_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for enemy: Enemy in enemies.get_children():
		cells.append(enemy.cell)
	return cells

func _lose_life() -> void:
	if game_over: return
	lives -= 1
	hud.set_lives(lives)
	map.clear_trail()
	player.reset()
	if lives <= 0:
		_end_game("You lost")

func _on_area_claimed(percent: float) -> void:
	hud.set_progress(percent)
	if percent >= win_percent:
		_end_game("You win!")

func _on_enemy_hit_trail(_cell: Vector2i) -> void:
	map.burn_trail(_cell)

func _end_game(text: String) -> void:
	if game_over: return
	game_over = true
	hud.show_message(text)
	get_tree().paused = true

func _on_restart_requested() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _apply_palette() -> void:
	var p := palettes[_palette_index]
	map.set_palette(p)
	hud.set_palette(p)
	player.modulate = p.player
	for enemy in enemies.get_children():
		enemy.modulate = p.enemy
	RenderingServer.set_default_clear_color(p.background)
