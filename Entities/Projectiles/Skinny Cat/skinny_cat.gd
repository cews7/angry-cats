extends BaseProjectile

var obstacles_hit = 0
var max_obstacles_before_bounce = 3

func set_properties():
    add_to_group("projectiles")  # Add this line
    mass = 1.0
    impact_modifier = 0.5
    max_velocity = 1800.0
    launch_force_multiplier = 7.5
    
    base_damage = 1.0
    mass_factor = 0.8
    velocity_factor = 0.025

    # Adjust initial physics material for less bouncing
    var physics_material = PhysicsMaterial.new()
    physics_material.bounce = 0.1
    physics_material.friction = 0.5
    set_physics_material_override(physics_material)

    # Enable contact monitoring for collision detection
    contact_monitor = true
    max_contacts_reported = 1

func _on_body_entered(body):
    super._on_body_entered(body)
    if body.is_in_group("obstacles"):
        obstacles_hit += 1
        if obstacles_hit >= max_obstacles_before_bounce:
            # Enable normal bouncing behavior
            var physics_material = PhysicsMaterial.new()
            physics_material.bounce = 0.5
            physics_material.friction = 0.2
            set_physics_material_override(physics_material)
        else:
            # Slow down the projectile
            linear_velocity *= 0.8

func _integrate_forces(state):
    super._integrate_forces(state)
    if obstacles_hit < max_obstacles_before_bounce:
        # Maintain forward momentum
        state.linear_velocity = state.linear_velocity.normalized() * state.linear_velocity.length()
