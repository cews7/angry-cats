extends RigidBody2D

var initial_position: Vector2
var initial_rotation: float
var health: float = 100.0

@export var topple_sensitivity: float = 0.2  # Reduced from 0.5
@export var min_impact_force: float = 15.0  # Increased from 10.0

func _ready():
    add_to_group("obstacles")
    body_entered.connect(_on_body_entered)
    initial_position = global_position
    initial_rotation = rotation
    lock_rotation = true  # Prevent rotation while static
    freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC  # Allow collision detection while static
    freeze = true  # Start as static

func _on_body_entered(body: Node2D):
    if body is BaseProjectile or body is RigidBody2D:
        call_deferred("activate_physics", body)

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
        
        # Apply the impulse in the direction of the impact
        apply_impulse(impact_direction * impact_force, impact_point - global_position)
        
        # Add a bit of random rotation
        angular_velocity = randf_range(-0.5, 0.5) * impact_force * 0.01  # Reduced random rotation


