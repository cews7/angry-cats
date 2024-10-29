extends Node2D

@onready var regular_projectile: PackedScene = preload("res://Entities/Projectiles/Regular Cat/regular_cat.tscn")
@onready var reset_scene_button: Button = $Button
@onready var projectile_component: Node2D = $ProjectileComponents
# Called when the node enters the scene tree for the first time.
func _ready():
    for i in range(4):
        var projectile_instance = regular_projectile.instantiate()
        projectile_component.add_child(projectile_instance)
        projectile_component.add_projectile(projectile_instance)
    reset_scene_button.pressed.connect(reset_scene)

func reset_scene() -> void:
    get_tree().reload_current_scene()
