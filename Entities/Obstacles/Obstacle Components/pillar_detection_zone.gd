extends Area2D

@export var pull_strength := 2000.0  # Increased from 200 to 2000

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("blue projectile"):
        body.set_meta("in_pull_zone", true)
        
func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("blue projectile"):
        body.remove_meta("in_pull_zone")

func _physics_process(delta: float) -> void:
    var bodies = get_overlapping_bodies()
    for body in bodies:
        # Only process if it's a projectile AND not part of the cat tree
        if body.is_in_group("blue projectile") and body.has_meta("in_pull_zone") and not body.is_in_group("obstacles"):
            apply_pull_force(body, delta)

func apply_pull_force(body: Node2D, delta: float) -> void:
    # Only apply force if it's actually a physics body
    if not body is RigidBody2D:
        return
        
    var direction = (global_position - body.global_position).normalized()
    var pull_force = direction * pull_strength * delta * 50.0
    
    # Ensure we're only affecting the projectile physics, not other properties
    if body.is_in_group("blue projectile"):
        body.apply_central_force(pull_force)
