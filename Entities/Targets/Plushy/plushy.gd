extends Area2D

signal score_updated(score: int)
signal plushy_hit
var plushy_score = 1000
var rotation_speed = PI / 2.5  # Rotate 180 degrees in 5.5 seconds
@onready var scoring_rings: Node2D = $ScoringRings
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	add_to_group("targets")
	body_entered.connect(_on_body_entered)
	$ScoringRings.score_updated.connect(_on_score_updated)

func _on_body_entered(body):
	if body.is_in_group("projectiles"):
		if body.can_score():
			emit_signal("plushy_hit")
			emit_signal("score_updated", scoring_rings.current_score + plushy_score)
			queue_free()

func _on_score_updated(score: int):
	emit_signal("score_updated", score)

func _process(delta):
	sprite.rotate(rotation_speed * delta)

