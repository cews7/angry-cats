extends BaseProjectile

var obstacles_hit = 0
var max_obstacles_before_bounce = 3

func set_properties():
	add_to_group("projectiles")  # Add this line
	mass = 10.0
	impact_modifier = 2.0
	max_velocity = 960.0  # Increased from 800.0 (20% increase)
	launch_force_multiplier = 6.6  # Increased from 5.5 (20% increase)

	base_damage = 15.0
	mass_factor = 1.2
	velocity_factor = 0.015

	# Adjust physics material for less bouncing
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.1
	physics_material.friction = 0.5
	set_physics_material_override(physics_material)

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
