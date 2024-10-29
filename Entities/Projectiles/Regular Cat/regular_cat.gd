extends BaseProjectile

var obstacles_hit = 0
var max_obstacles_before_bounce = 3

func set_properties():
	add_to_group("projectiles")  # Add this line
	mass = 6.0  # Increased from 5.0
	impact_modifier = 1.2  # Increased from 1.0
	max_velocity = 1600.0  # Increased from 1200.0 (about 33% increase)
	launch_force_multiplier = 5.3  # Increased from 4.0 (about 33% increase)

	base_damage = 10.0  # Standard base damage
	mass_factor = 1.0  # Standard mass factor
	velocity_factor = 0.02  # Slightly higher velocity factor for balanced impact

	# Adjust physics material for less bouncing
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.1
	physics_material.friction = 0.5
	set_physics_material_override(physics_material)

func _on_body_entered(body):
	super._on_body_entered(body)
	if body.is_in_group("obstacles"):
		# Enable bouncing behavior based on pillar's bounce value
		var physics_material = PhysicsMaterial.new()
		physics_material.bounce = body.get_bounce_value()
		physics_material.friction = 0.2
		set_physics_material_override(physics_material)

func _integrate_forces(state):
	super._integrate_forces(state)
	if obstacles_hit < max_obstacles_before_bounce:
		# Maintain forward momentum
		state.linear_velocity = state.linear_velocity.normalized() * state.linear_velocity.length()
