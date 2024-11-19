extends Camera2D

@export var design_resolution := Vector2(1920, 1080)

func _ready() -> void:
    make_current()
    adjust_camera()
    get_tree().root.size_changed.connect(adjust_camera)

func adjust_camera() -> void:
    var viewport_size = get_viewport_rect().size
    
    # Calculate scale needed for both dimensions
    var scale_x = viewport_size.x / design_resolution.x
    var scale_y = viewport_size.y / design_resolution.y
    
    # Use the smaller scale for both dimensions to ensure everything fits
    var final_scale = min(scale_x, scale_y)
    zoom = Vector2(1/final_scale, 1/final_scale)
    
    # Center the camera on the game area
    # Assuming your game world is centered at design_resolution/2
    position = design_resolution / 2