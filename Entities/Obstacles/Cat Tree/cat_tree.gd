extends RigidBody2D

var initial_position: Vector2
var initial_rotation: float

@export var topple_sensitivity: float = 0.5  # Adjust this to control how easily the obstacle topples

func _ready():
    body_entered.connect(_on_body_entered)
    initial_position = global_position
    initial_rotation = rotation
    lock_rotation = true  # Prevent rotation while static
    freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC  # Allow collision detection while static
    freeze = true  # Start as static

func _on_body_entered(body: Node2D):
    print("Obstacle hit by: ", body.name)
    if body is BaseProjectile:
        call_deferred("activate_physics", body)
    elif body is RigidBody2D:  # Check if the colliding body is another RigidBody2D (e.g., another cat tree)
        call_deferred("activate_physics", body)
        if body.has_method("activate_physics"):  # Check if the other body has the activate_physics method
            body.call_deferred("activate_physics", self)

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
    
    # Calculate the vector from the obstacle's center to the impact point
    var impact_vector = impact_point - global_position
    
    # Calculate the impulse direction (perpendicular to the impact vector)
    var impulse_direction = Vector2(impact_vector.y, -impact_vector.x).normalized()
    
    # Apply the impulse at the impact point
    apply_impulse(impulse_direction * impact_force, impact_vector)
    
    # Add a bit of random rotation to make it more dynamic
    angular_velocity = randf_range(-1, 1) * impact_force * 0.01

func reset_obstacle():
    set_deferred("freeze", true)
    set_deferred("lock_rotation", true)
    global_position = initial_position
    rotation = initial_rotation
    linear_velocity = Vector2.ZERO
    angular_velocity = 0.0

func is_active() -> bool:
    return not freeze
