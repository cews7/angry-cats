extends StaticBody2D

var initial_position: Vector2
var initial_rotation: float
var health: float = 100.0
var instance_id: int  # Add this to track unique instances
var emit_timer: Timer

var bounce_force: float = 0.0  # Changed from 800.0 to start at 0

@onready var bounce_indicator_scene = preload("res://Entities/Obstacles/Obstacle Components/bounce_indicator.tscn")
@onready var bounce_area: Area2D = $BounceArea
@onready var pillar_control: Node2D = $PillarControl  # Make sure this matches your node name
@onready var tween: Tween

func _ready():
    instance_id = get_instance_id()  # Get unique ID for this instance
    add_to_group("obstacles")
    bounce_area.body_entered.connect(_on_bounce_area_entered)
    emit_timer = Timer.new()
    add_child(emit_timer)
    emit_timer.wait_time = 1.0 
    emit_timer.timeout.connect(_on_emit_timer_timeout)
    emit_timer.start()
    
    if pillar_control:
        pillar_control.setup(instance_id)  # Pass the instance ID to PillarControl
        # Simple direct connection
        pillar_control.bounce_value_changed.connect(_on_bounce_value_changed)
    
    initial_position = global_position
    initial_rotation = rotation


func _on_emit_timer_timeout() -> void:
    _emit_bounce_indicator()

func _emit_bounce_indicator() -> void:
    if bounce_force > 0:  # Only emit if pillar has some bounce force
        var bounce_indicator = bounce_indicator_scene.instantiate()
        get_tree().get_root().add_child(bounce_indicator)
        
        # Position above pillar
        bounce_indicator.global_position = global_position + Vector2.UP.rotated(rotation) * 50
        
        # Match pillar's rotation
        bounce_indicator.rotation = rotation
        
        # Calculate intensity for animation speed
        var intensity = bounce_force / 2000.0  # Convert to 0-1 range
        bounce_indicator.play_animation(intensity)

# Match the signal parameters exactly
func _on_bounce_value_changed(value: float, id: int) -> void:
    if id == instance_id:
        bounce_force = value * 1300.0

func _on_bounce_area_entered(body: Node2D) -> void:
    if body is BaseProjectile:
        var projectile = body as BaseProjectile
        # Calculate bounce direction (upward and slightly away from obstacle)
        var bounce_direction = Vector2.UP + (body.global_position - global_position).normalized()
        bounce_direction = bounce_direction.normalized()
        
        # Apply the bounce
        projectile.linear_velocity = bounce_direction * bounce_force
        
        # Create pulse animation
        if tween:
            tween.kill()  # Kill any existing tween
        tween = create_tween()
        tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)  # Expand
        tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)  # Contract

func get_bounce_value() -> float:
    var bounce = bounce_force / 1000.0
    return bounce
