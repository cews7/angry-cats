extends Node2D

@onready var score_label: Label = $Score
@onready var plushy: Area2D = %Plushy
@onready var regular_projectile: PackedScene = preload("res://Entities/Projectiles/Regular Cat/regular_cat.tscn")
@onready var reset_scene_button: Button = $Button
@onready var projectile_component: Node2D = $ProjectileComponents

var total_score = 0

func _ready():
    score_label.text = 'Score: ' + str(GameState.get_total_score())
    plushy.score_updated.connect(_on_score_updated)
    plushy.plushy_hit.connect(_on_plushy_hit)
    for i in range(5):
        var projectile_instance = regular_projectile.instantiate()
        projectile_component.add_child(projectile_instance)
        projectile_component.add_projectile(projectile_instance)
    reset_scene_button.pressed.connect(reset_scene)

func reset_scene() -> void:
    get_tree().reload_current_scene()

func _on_score_updated(score: int):
    GameState.add_to_score(score)
    score_label.text = 'Score: ' + str(GameState.get_total_score())
    total_score = score

func _on_projectile_components_empty():
    if total_score >= 1:
        get_tree().call_deferred("change_scene_to_file", "res://UI/Overlay/score_screen.tscn")
    else:
        get_tree().call_deferred("change_scene_to_file", "res://Levels/level_three.tscn")

func _on_plushy_hit():
    get_tree().call_deferred("change_scene_to_file", "res://UI/Overlay/score_screen.tscn")
