extends Control

signal play_button_pressed
signal settings_button_pressed

@onready var play_button = %PlayButton
@onready var settings_button = %SettingsButton
@onready var exit_button = %ExitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

func _on_play_button_pressed() -> void:
	play_button_pressed.emit()

func _on_settings_button_pressed() -> void:
	settings_button_pressed.emit()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
