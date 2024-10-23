extends Area2D

func _ready():
	add_to_group("targets")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("projectiles"):
		print("Projectile hit Plushy")
		queue_free()
