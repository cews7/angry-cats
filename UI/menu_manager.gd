extends Node

signal level_one_button_pressed
signal level_two_button_pressed
signal level_three_button_pressed

var title_menu_scene: PackedScene = preload("res://UI/Title Menu/title_menu.tscn")
var select_level_menu_scene: PackedScene = preload("res://UI/Select Level Menu/select_level_menu.tscn")
var settings_scene: PackedScene = preload("res://UI/Settings/settings.tscn")
var select_level_menu_instance: Node = null
var settings_instance: Node = null

@onready var title_menu_instance = title_menu_scene.instantiate()

func _ready() -> void:
    add_child(title_menu_instance)
    title_menu_instance.play_button_pressed.connect(_on_play_button_pressed)
    title_menu_instance.settings_button_pressed.connect(_on_settings_button_pressed)

func _on_play_button_pressed() -> void:
    title_menu_instance.queue_free()
    select_level_menu_instance = select_level_menu_scene.instantiate()
    add_child(select_level_menu_instance)
    select_level_menu_instance.level_one_button_pressed.connect(_on_level_one_button_pressed)
    select_level_menu_instance.level_two_button_pressed.connect(_on_level_two_button_pressed)
    select_level_menu_instance.level_three_button_pressed.connect(_on_level_three_button_pressed)

func _on_level_one_button_pressed() -> void:
    level_one_button_pressed.emit()

func _on_level_two_button_pressed() -> void:
    level_two_button_pressed.emit()

func _on_level_three_button_pressed() -> void:
    level_three_button_pressed.emit()

func _on_settings_button_pressed() -> void:
    title_menu_instance.queue_free()
    settings_instance = settings_scene.instantiate()
    add_child(settings_instance)
    settings_instance.back_button.pressed.connect(_on_settings_back_pressed)

func _on_settings_back_pressed() -> void:
    settings_instance.queue_free()
    title_menu_instance = title_menu_scene.instantiate()
    add_child(title_menu_instance)
    title_menu_instance.play_button_pressed.connect(_on_play_button_pressed)
    title_menu_instance.settings_button_pressed.connect(_on_settings_button_pressed)
