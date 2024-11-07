extends Node2D

@onready var score_label: Label = $Score
@onready var star: Area2D = %Star
@onready var blue_projectile: PackedScene = preload("res://Entities/Projectiles/Blue/blue.tscn")
@onready var projectile_component: Node2D = $ProjectileComponents

var total_score = 0

func _ready():
    score_label.text = 'Score: ' + str(GameState.get_total_score())
    star.score_updated.connect(_on_score_updated)
    star.star_hit.connect(_on_star_hit)
    for i in range(5):
        var projectile_instance = blue_projectile.instantiate()
        projectile_component.add_child(projectile_instance)
        projectile_component.add_projectile(projectile_instance)

func _on_score_updated(score: int):
    GameState.add_to_score(score)
    score_label.text = 'Score: ' + str(GameState.get_total_score())
    total_score = score

func _on_projectile_components_empty():
    get_tree().call_deferred("change_scene_to_file", "res://UI/Score Screen/score_screen.tscn")

func _on_star_hit():
    get_tree().call_deferred("change_scene_to_file", "res://UI/Score Screen/score_screen.tscn")
