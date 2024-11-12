class_name BaseProjectile
extends RigidBody2D

signal projectile_hit_ground

@export var base_damage: float = 10.0
@export var mass_factor: float = 1.0
@export var velocity_factor: float = 0.01

var obstacles_hit = 0
var max_obstacles_before_bounce = 3
var has_hit_obstacle = false
var impact_modifier: float = 1.0
var max_velocity: float = 200.0
var launch_force_multiplier: float = 1.0
var is_active = false

func _ready():
    set_properties()
    add_to_group("blue projectile")
    add_to_group("projectiles")  # Add this line
    set_properties()
    body_entered.connect(_on_body_entered)

func set_properties():
    mass = 6.0  
    impact_modifier = 1.2  
    max_velocity = 1600.0 
    launch_force_multiplier = 5.3 

    base_damage = 10.0 
    mass_factor = 1.0 
    velocity_factor = 0.02 

    # Adjust physics material for less bouncing
    var physics_material = PhysicsMaterial.new()
    physics_material.bounce = 0.1
    physics_material.friction = 0.5
    set_physics_material_override(physics_material)

func _on_body_entered(body):
    var impact_force = calculate_impact_force()
    apply_impact(body, impact_force)
    if body.is_in_group("obstacles"):
        has_hit_obstacle = true
        # Enable bouncing behavior based on pillar's bounce value
        var physics_material = PhysicsMaterial.new()
        physics_material.bounce = body.get_bounce_value()
        physics_material.friction = 0.2
        set_physics_material_override(physics_material)
    elif body.is_in_group("ground"):
        projectile_hit_ground.emit(self)

func can_score() -> bool:
    return has_hit_obstacle

func _integrate_forces(state):
    var current_velocity = state.linear_velocity
    if current_velocity.length() > max_velocity:
        state.linear_velocity = current_velocity.normalized() * max_velocity
    # Maintain forward momentum
    state.linear_velocity = state.linear_velocity.normalized() * state.linear_velocity.length()

func calculate_impact_force() -> float:
    var velocity_magnitude = linear_velocity.length()
    var mass_impact = mass * mass_factor
    var velocity_impact = velocity_magnitude * velocity_factor
    var base_impact = base_damage * impact_modifier
    return base_impact + mass_impact + velocity_impact

func apply_impact(body: Node, force: float):
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

