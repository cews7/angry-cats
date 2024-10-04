extends Control

signal play_button_pressed

@onready var play_button = %PlayButton

func _ready() -> void:
	play_button.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	play_button_pressed.emit()