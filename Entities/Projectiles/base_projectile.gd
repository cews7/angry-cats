class_name BaseProjectile
extends RigidBody2D

@export var base_damage: float = 10.0
@export var mass_factor: float = 1.0
@export var velocity_factor: float = 0.01

var impact_modifier: float = 1.0
var max_velocity: float = 200.0
var launch_force_multiplier: float = 1.0

func _ready():
    set_properties()
    body_entered.connect(_on_body_entered)

func set_properties():
    # Override in child scripts
    pass

func _integrate_forces(state):
    var current_velocity = state.linear_velocity
    if current_velocity.length() > max_velocity:
        state.linear_velocity = current_velocity.normalized() * max_velocity

func _on_body_entered(body):
    var impact_force = calculate_impact_force()
    apply_impact(body, impact_force)

func calculate_impact_force() -> float:
    var velocity_magnitude = linear_velocity.length()
    var mass_impact = mass * mass_factor
    var velocity_impact = velocity_magnitude * velocity_factor
    var base_impact = base_damage * impact_modifier
    return base_impact + mass_impact + velocity_impact

func apply_impact(body: Node, force: float):
    if body.has_method("take_damage"):
        body.take_damage(force)
    
    if body is RigidBody2D:
        var impact_direction = linear_velocity.normalized()
        var impulse = impact_direction * force
        body.apply_central_impulse(impulse)
	
    spawn_impact_effect(force)

func spawn_impact_effect(_force: float):
    # Implement visual feedback
    pass
func launch(direction: Vector2, power: float):
    var adjusted_power = power * launch_force_multiplier
    var launch_velocity = direction * adjusted_power
    if launch_velocity.length() > max_velocity:
        launch_velocity = launch_velocity.normalized() * max_velocity
    linear_velocity = launch_velocity
