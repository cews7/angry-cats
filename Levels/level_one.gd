extends Node2D

@onready var reset_scene_button: Button = $Button
# Called when the node enters the scene tree for the first time.
func _ready():
    reset_scene_button.pressed.connect(reset_scene)

func reset_scene() -> void:
    get_tree().reload_current_scene()