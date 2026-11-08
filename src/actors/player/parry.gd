class_name Parry extends RefCounted

var window_msec := 250
var charges_per_trip := 1
var _charges := 0
var _open_until := -1

func new_trip() -> void:
	_charges = charges_per_trip
	_open_until = -1

func press(now_msec: int) -> bool:
	if _charges <= 0:
		return false
	_charges -= 1
	_open_until = now_msec + window_msec
	return true

func consume(now_msec: int) -> bool:
	if is_open(now_msec):
		_open_until = -1
		return true
	return false

func is_open(now_msec: int) -> bool:
	return now_msec <= _open_until
