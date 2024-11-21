extends Control

signal play_button_pressed
signal settings_button_pressed

@onready var play_button = %PlayButton
@onready var settings_button = %SettingsButton
@onready var game_name = %GameName

func _ready() -> void:
    game_name.text = "stella[color=#87CEEB]bounce[/color]"
    play_button.pressed.connect(_on_play_button_pressed)
    settings_button.pressed.connect(_on_settings_button_pressed)

func _on_play_button_pressed() -> void:
    play_button_pressed.emit()

func _on_settings_button_pressed() -> void:
    settings_button_pressed.emit()

