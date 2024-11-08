extends Node2D

var rings: Array[Line2D] = []
const MAX_RING_COUNT = 6  # Maximum number of rings at 100% intensity

func _ready() -> void:
    # Create all potential rings (they'll be enabled/disabled based on intensity)
    for i in range(MAX_RING_COUNT):
        var line = Line2D.new()
        add_child(line)
        rings.append(line)
        
        # Set up line properties
        line.width = 3.0
        line.default_color = Color(1, 1, 1, 0.8)
        
        # Create oval points with increasing size for each ring
        var points = []
        var segments = 32
        var width = 60.0 + (i * 15.0)
        var height = 30.0 + (i * 7.5)
        
        for j in range(segments + 1):
            var angle = (j / float(segments)) * TAU
            var x = cos(angle) * width
            var y = sin(angle) * height
            points.append(Vector2(x, y))
        
        line.points = points
        line.modulate.a = 0.0  # Start invisible
    
    scale = Vector2(0.2, 0.2)

func play_animation(intensity: float) -> void:
    # Calculate how many rings to show based on intensity (0.0 to 1.0)
    var active_rings = int(ceil(intensity * MAX_RING_COUNT))
    active_rings = clamp(active_rings, 0, MAX_RING_COUNT)
    
    # Fixed duration (matching 12% slider speed)
    var base_duration = 0.7  # Adjust this value to match the desired speed
    
    # Only animate the active rings
    for i in range(active_rings):
        var ring_tween = create_tween()
        ring_tween.set_trans(Tween.TRANS_QUAD)
        ring_tween.set_ease(Tween.EASE_OUT)
        
        var delay = i * 0.08
        var fade_in_duration = base_duration * 0.2
        var hold_duration = base_duration * 0.1
        var fade_out_duration = base_duration * 0.7
        
        ring_tween.tween_property(rings[i], "modulate:a", 0.8, fade_in_duration)\
            .set_delay(delay)
        ring_tween.tween_property(rings[i], "modulate:a", 0.8, hold_duration)
        ring_tween.tween_property(rings[i], "modulate:a", 0.0, fade_out_duration)
    
    var scale_tween = create_tween()
    scale_tween.set_trans(Tween.TRANS_QUAD)
    scale_tween.set_ease(Tween.EASE_OUT)
    scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), base_duration)
    scale_tween.tween_callback(queue_free)