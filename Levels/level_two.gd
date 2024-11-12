extends Node2D

@onready var score_label: Label = $Score
@onready var star: Area2D = %Star

var total_score = 0

func _ready():
    score_label.text = 'Score: ' + str(GameState.get_total_score())
    star.score_updated.connect(_on_score_updated)
    star.star_hit.connect(_on_star_hit)

func _on_score_updated(score: int):
    GameState.add_to_score(score)
    score_label.text = 'Score: ' + str(GameState.get_total_score())
    total_score = score

func _on_projectile_components_empty():
    if total_score >= 1:
        get_tree().call_deferred("change_scene_to_file", "res://Levels/level_three.tscn")
    else:
        get_tree().call_deferred("change_scene_to_file", "res://Levels/level_two.tscn")

func _on_star_hit():
    get_tree().call_deferred("change_scene_to_file", "res://Levels/level_three.tscn")
