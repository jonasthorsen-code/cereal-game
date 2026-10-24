class_name GridData extends RefCounted

signal cell_changed(cell: Vector2i)

enum Cell { SEA, LAND, TRAIL }

var width: int
var height: int
var _cells := PackedByteArray()

func _init(w: int, h: int) -> void:
	width = w
	height = h
	_cells.resize(w * h)

func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < height

func index_of(cell: Vector2i) -> int:
	return cell.y * width + cell.x

func get_cell(cell: Vector2i) -> Cell:
	if is_inside(cell):
		return _cells[index_of(cell)] as Cell
	return Cell.LAND

func set_cell(cell: Vector2i, type: Cell) -> void:
	if not is_inside(cell):
		return
	_cells[index_of(cell)] = type
	cell_changed.emit(cell)

func fill_unreachable(seeds: Array[Vector2i], through: Cell, with: Cell) -> int:
	var reached := _reachable_from(seeds, through)
	var count := 0
	for x in width:
		for y in height:
			var cell := Vector2i(x, y)
			if get_cell(cell) == through and reached[index_of(cell)] == 0:
				set_cell(cell, with)
				count += 1
	return count

func _reachable_from(seeds: Array[Vector2i], through: Cell) -> PackedByteArray:
	var visited := PackedByteArray()
	visited.resize(width * height)
	visited.fill(0)
	var waiting: Array[Vector2i] = seeds.duplicate()
	
	var cell: Vector2i
	while waiting.size() != 0:
		cell = waiting.pop_back()
		if not is_inside(cell):
			continue
		if visited[index_of(cell)] == 1:
			continue
		if get_cell(cell) != through:
			continue
		visited[index_of(cell)] = 1
		waiting.append(cell + Vector2i.UP)
		waiting.append(cell + Vector2i.RIGHT)
		waiting.append(cell + Vector2i.DOWN)
		waiting.append(cell + Vector2i.LEFT)
	
	return visited
