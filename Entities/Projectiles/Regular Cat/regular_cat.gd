extends BaseProjectile

var obstacles_hit = 0
var max_obstacles_before_bounce = 3

func set_properties():
	mass = 5.0
	impact_modifier = 1.0
	max_velocity = 1200.0  # Higher max velocity than FatCat
	launch_force_multiplier = 4.0  # Less than FatCat, but still powerful

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
