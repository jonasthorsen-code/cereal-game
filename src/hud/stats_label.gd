class_name StatsLabel extends Label

var _lives := 0
var _progress: float = 0
var _target: float = 0

func set_lives(lives: int) -> void:
	_lives = lives
	_update_text()

func set_progress(progress: float) -> void:
	_progress = progress
	_update_text()

func set_target(target: float) -> void:
	_target = target
	_update_text()

func _update_text() -> void:
	text = "%d lives left\nClaimed %.1f%% / %.0f%%" % [_lives, _progress, _target]
	
