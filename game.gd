extends Node2D

var level_one_scene = preload("res://Levels/level_one.tscn")
var level_two_scene = preload("res://Levels/level_two.tscn")
var level_three_scene = preload("res://Levels/level_three.tscn")

@onready var menu_manager = %MenuManager

func _ready():
	menu_manager.level_one_button_pressed.connect(_on_level_one_button_pressed)
	menu_manager.level_two_button_pressed.connect(_on_level_two_button_pressed)
	menu_manager.level_three_button_pressed.connect(_on_level_three_button_pressed)

func _on_level_one_button_pressed() -> void:
	var level_one_instance = level_one_scene.instantiate()
	add_child(level_one_instance)

func _on_level_two_button_pressed() -> void:
	var level_two_instance = level_two_scene.instantiate()
	add_child(level_two_instance)

func _on_level_three_button_pressed() -> void:
	var level_three_instance = level_three_scene.instantiate()
	add_child(level_three_instance)