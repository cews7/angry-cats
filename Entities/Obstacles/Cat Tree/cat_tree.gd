extends RigidBody2D

var initial_position: Vector2
var initial_rotation: float
var health: float = 100.0
var instance_id: int  # Add this to track unique instances

@export var topple_sensitivity: float = 0.2  # Reduced from 0.5
@export var min_impact_force: float = 15.0  # Increased from 10.0
var bounce_force: float = 0.0  # Changed from 800.0 to start at 0

@onready var bounce_area: Area2D = $BounceArea
@onready var pillar_control: Node2D = $PillarControl  # Make sure this matches your node name

func _ready():
    instance_id = get_instance_id()  # Get unique ID for this instance
    add_to_group("obstacles")
    body_entered.connect(_on_body_entered)
    bounce_area.body_entered.connect(_on_bounce_area_entered)
    
    if pillar_control:
        pillar_control.setup(instance_id)  # Pass the instance ID to PillarControl
        # Simple direct connection
        pillar_control.bounce_value_changed.connect(_on_bounce_value_changed)
    
    initial_position = global_position
    initial_rotation = rotation
    lock_rotation = true  # Prevent rotation while static
    freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC  # Allow collision detection while static
    freeze = true  # Start as static


# Match the signal parameters exactly
func _on_bounce_value_changed(value: float, id: int) -> void:
    if id == instance_id:
        bounce_force = value * 1000.0
        print("Bounce force changed for instance ", instance_id, " to ", bounce_force)  # Debug print

func _on_body_entered(body: Node2D):
    if body is BaseProjectile or body is RigidBody2D:
        call_deferred("activate_physics", body)

func _on_bounce_area_entered(body: Node2D) -> void:
    if body is BaseProjectile:
        var projectile = body as BaseProjectile
        # Calculate bounce direction (upward and slightly away from obstacle)
        var bounce_direction = Vector2.UP + (body.global_position - global_position).normalized()
        bounce_direction = bounce_direction.normalized()
        
        # Apply the bounce
        projectile.linear_velocity = bounce_direction * bounce_force
        
        # Optionally reset the obstacles_hit counter to allow for multiple bounces
        if projectile.has_method("reset_obstacles_hit"):
            projectile.reset_obstacles_hit()

func activate_physics(collider: Node2D):
    set_deferred("freeze", false)
    set_deferred("lock_rotation", false)  # Allow rotation
    
    call_deferred("apply_toppling_impulse", collider)

func apply_toppling_impulse(collider: Node2D):
    var impact_point = collider.global_position
    var impact_velocity = collider.linear_velocity if collider is RigidBody2D else Vector2.ZERO
    
    # Calculate the impact force
    var collider_mass = collider.mass if collider is RigidBody2D else 1.0
    var impact_force = impact_velocity.length() * collider_mass * topple_sensitivity
    
    # Only apply the impulse if the impact force is above the minimum threshold
    if impact_force > min_impact_force:
        # Calculate the impact direction from the collider to the obstacle
        var impact_direction = (global_position - impact_point).normalized()
        
        # Calculate the impact point relative to the obstacle's center
        var local_impact_point = impact_point - global_position
        
        # Calculate the torque based on the impact point and force
        var torque = local_impact_point.cross(impact_direction) * impact_force * 0.1
        
        # Apply the linear impulse
        apply_impulse(impact_direction * impact_force, local_impact_point)
        
        # Apply the angular impulse (torque)
        apply_torque_impulse(torque)
        
        # Add a bit more random rotation
        angular_velocity += randf_range(-1.0, 1.0) * impact_force * 0.05

    print("Impact force: ", impact_force, " Min impact force: ", min_impact_force)

func get_bounce_value() -> float:
    var bounce = bounce_force / 1000.0
    print("Cat Tree bounce value: ", bounce)  # Debug print
    return bounce
