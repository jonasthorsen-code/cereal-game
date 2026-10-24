class_name Hud extends CanvasLayer

signal restart_requested()

@onready var stats_label: StatsLabel = $StatsLabel
@onready var message_label: Label = $MessageLabel

func set_palette(p: Palette) -> void:
	for label in [stats_label, message_label]:
		label.add_theme_color_override("font_color", p.text)
		label.add_theme_color_override("font_outline_color", p.text_outline)

func set_lives(lives: int) -> void:
	stats_label.set_lives(lives)

func set_progress(progress: float) -> void:
	stats_label.set_progress(progress)

func set_target(target: float) -> void:
	stats_label.set_target(target)

func show_message(text: String) -> void:
	message_label.text = text + "\nPress Enter to restart"
	message_label.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if message_label.visible and event.is_action_pressed("restart"):
		restart_requested.emit()
