extends Area2D

signal score_updated(score: int)
signal star_hit
var star_value = 10
var rotation_speed = PI / 2.5  # Rotate 180 degrees in 5.5 seconds

@onready var scoring_rings: Node2D = $ScoringRings
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
    add_to_group("targets")
    body_entered.connect(_on_body_entered)
    scoring_rings.score_updated.connect(_on_score_updated)

func _on_body_entered(body):
    if body.is_in_group("projectiles"):
        if body.can_score():
            star_hit.emit()
            score_updated.emit(star_value)
            queue_free()

func _on_score_updated(score: int):
    score_updated.emit(score)

func _process(delta):
    sprite.rotate(rotation_speed * delta)

