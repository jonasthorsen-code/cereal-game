class_name MapView extends Node2D

@export var cell_size := 8

var _grid: GridData
var _palette: Palette
var _parry_highlight := false

func bind(grid: GridData) -> void:
	_grid = grid
	grid.cell_changed.connect(_on_cell_changed)
	queue_redraw()

func set_palette(p: Palette) -> void:
	_palette = p
	queue_redraw()

func cell_to_world(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2(0.5, 0.5)) * cell_size

func get_pixel_size() -> Vector2:
	return Vector2(_grid.width, _grid.height) * cell_size

func set_parry_highlight(on: bool) -> void:
	if on == _parry_highlight:
		return
	_parry_highlight = on
	queue_redraw()

func _draw() -> void:
	if _grid == null or _palette == null:
		return
	draw_rect(Rect2(Vector2.ZERO, get_pixel_size()), _palette.sea)
	var square := Vector2(cell_size, cell_size)
	for x in _grid.width:
		for y in _grid.height:
			var cell := Vector2i(x, y)
			var type := _grid.get_cell(cell)
			if type != GridData.Cell.SEA:
				draw_rect(Rect2(Vector2(cell) * cell_size, square), _color_of(type))

func _on_cell_changed(_cell: Vector2i) -> void:
	queue_redraw()

func _color_of(type: GridData.Cell) -> Color:
	match type:
		GridData.Cell.LAND:
			return _palette.land
		GridData.Cell.TRAIL:
			return _palette.parry if _parry_highlight else _palette.trail
	return _palette.sea
