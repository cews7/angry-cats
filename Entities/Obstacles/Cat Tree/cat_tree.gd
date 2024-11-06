extends StaticBody2D

var initial_position: Vector2
var initial_rotation: float
var health: float = 100.0
var instance_id: int  # Add this to track unique instances

var bounce_force: float = 0.0  # Changed from 800.0 to start at 0

@onready var bounce_area: Area2D = $BounceArea
@onready var pillar_control: Node2D = $PillarControl  # Make sure this matches your node name

func _ready():
    instance_id = get_instance_id()  # Get unique ID for this instance
    add_to_group("obstacles")
    bounce_area.body_entered.connect(_on_bounce_area_entered)
    
    if pillar_control:
        pillar_control.setup(instance_id)  # Pass the instance ID to PillarControl
        # Simple direct connection
        pillar_control.bounce_value_changed.connect(_on_bounce_value_changed)
    
    initial_position = global_position
    initial_rotation = rotation


# Match the signal parameters exactly
func _on_bounce_value_changed(value: float, id: int) -> void:
    if id == instance_id:
        bounce_force = value * 1000.0

func _on_bounce_area_entered(body: Node2D) -> void:
    if body is BaseProjectile:
        var projectile = body as BaseProjectile
        # Calculate bounce direction (upward and slightly away from obstacle)
        var bounce_direction = Vector2.UP + (body.global_position - global_position).normalized()
        bounce_direction = bounce_direction.normalized()
        
        # Apply the bounce
        projectile.linear_velocity = bounce_direction * bounce_force
        
func get_bounce_value() -> float:
    var bounce = bounce_force / 1000.0
    return bounce
