class_name Trail extends RefCounted

var cells: Array[Vector2i] = []

var _back := -1
var _forward := 0
var _burning := false

func add(cell: Vector2i) -> void:
	cells.append(cell)

func clear() -> void:
	cells.clear()
	_burning = false

func start_burn(hit_cell: Vector2i) -> void:
	if _burning:
		return
	var i := cells.find(hit_cell)
	if i == -1:
		return
	_back = i
	_forward = i + 1
	_burning = true

func tick_burn() -> Array[Vector2i]:
	var destroyed: Array[Vector2i] = []
	if _back >= 0:
		destroyed.append(cells[_back])
		_back -= 1
	if _forward < cells.size():
		destroyed.append(cells[_forward])
		_forward += 1
	return destroyed

func is_burning() -> bool:
	return _burning

func head_reached() -> bool:
	return _burning and _forward >= cells.size()
