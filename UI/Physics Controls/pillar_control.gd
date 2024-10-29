extends Node2D

signal bounce_value_changed(value: float, instance_id: int)

var my_instance_id: int
@onready var bounce_slider: VSlider = $BounceSlider
@onready var bounce_value_label: Label = $BounceValue
@onready var interaction_area: Area2D = $InteractionArea
@onready var current_bounce: float = 0.0
@onready var min_bounce: float = 0.0
@onready var max_bounce: float = 100.0

var is_dragging: bool = false
var mouse_start_pos: Vector2
var initial_bounce: float


func setup(instance_id: int) -> void:
    my_instance_id = instance_id
    if bounce_slider:
        bounce_slider.value = current_bounce
        update_bounce_display()

func _ready() -> void:
    # set slider values
    bounce_slider.min_value = min_bounce
    bounce_slider.max_value = max_bounce
    bounce_slider.value = current_bounce
    update_bounce_display()
    # Connect the slider's value_changed signal
    bounce_slider.value_changed.connect(_on_slider_value_changed)

func _unhandled_input(event: InputEvent) -> void:
    # Only process events if mouse is over our interaction area
    if not interaction_area.has_overlapping_bodies():
        return
    # Get the mouse position and check if it's in the interaction area
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        var mouse_pos = get_viewport().get_mouse_position()
        if event.pressed:
            var local_point = interaction_area.to_local(mouse_pos)
            # Get the collision shape and check if the point is inside based on shape type
            var collision_shape = interaction_area.get_node("CollisionShape2D")
            var shape = collision_shape.shape
            var is_point_inside = false
            
            if shape is RectangleShape2D:
                var half_extents = shape.size / 2
                is_point_inside = local_point.x >= -half_extents.x and local_point.x <= half_extents.x and \
                                local_point.y >= -half_extents.y and local_point.y <= half_extents.y
                
            if interaction_area.get_overlapping_areas().size() > 0 or is_point_inside:
                _start_drag(event.position)
        else:
            _end_drag()
    elif event is InputEventMouseMotion and is_dragging:
        print("dragging1")
        _handle_drag(event.position)

func _on_slider_value_changed(value: float) -> void:
    current_bounce = value
    print("current_bounce: ", value)
    print("my_instance_id: ", my_instance_id)
    bounce_value_changed.emit(current_bounce / 100.0, my_instance_id)  # Convert to 0-1 range when emitting
    update_bounce_display()
func _start_drag(pos: Vector2) -> void:
    is_dragging = true
    mouse_start_pos = pos
    initial_bounce = current_bounce
    _handle_drag(pos)

func _end_drag() -> void:
    is_dragging = false

func _handle_drag(pos: Vector2) -> void:
    if not is_dragging:
        return
    print("dragging2")
    var delta = (mouse_start_pos.y - pos.y) / 100.0 * 100.0  # Adjust delta for percentage scale
    var new_bounce = clamp(initial_bounce + delta, min_bounce, max_bounce)
    current_bounce = new_bounce
    bounce_slider.value = new_bounce
    update_bounce_display()
    bounce_value_changed.emit(new_bounce / 100.0, my_instance_id)  # Convert to 0-1 range when emitting

# never used
func set_bounce_value(value: float) -> void:
    # Expect value to be in 0-1 range, convert to percentage
    var percentage = value * 100.0
    current_bounce = percentage
    bounce_slider.value = percentage
    update_bounce_display()

func update_bounce_display() -> void:
    # current_bounce is already in percentage (0-100), so use it directly
    bounce_value_label.text = str(current_bounce) + "%"