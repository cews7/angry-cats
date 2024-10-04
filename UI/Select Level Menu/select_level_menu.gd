extends Control

signal level_one_button_pressed
signal level_two_button_pressed
signal level_three_button_pressed

@onready var level_one_button = %LevelOneButton
@onready var level_two_button = %LevelTwoButton 
@onready var level_three_button = %LevelThreeButton  

func _ready() -> void:
	level_one_button.pressed.connect(_on_level_one_pressed)
	level_two_button.pressed.connect(_on_level_two_pressed)
	level_three_button.pressed.connect(_on_level_three_pressed)

func _on_level_one_pressed() -> void:
	level_one_button_pressed.emit()
	queue_free()

func _on_level_two_pressed() -> void:
	level_two_button_pressed.emit()
	queue_free()

func _on_level_three_pressed() -> void:
	level_three_button_pressed.emit()
	queue_free()

