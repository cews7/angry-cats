extends Node2D

var ring_colors = [
    Color(1.0, 0.2, 0.8, 0.4),  # Inner ring - Bright Magenta
    Color(1.0, 0.4, 0.0, 0.4),  # Vivid Orange
    Color(0.3, 1.0, 0.3, 0.4),  # Bright Lime
    Color(0.0, 0.8, 1.0, 0.4)   # Bright Cyan
]

var highlighted_rings = [false, false, false, false]
var ring_areas: Array[Area2D] = []

@export var inner_ring_radius: float = 50
@export var second_ring_radius: float = 100
@export var third_ring_radius: float = 150
@export var outer_ring_radius: float = 200

signal score_updated(points: int)

var ring_scores = [
    1000,  # Inner ring (closest)
    500,   # Second ring
    250,   # Third ring
    100    # Outer ring
]

var current_score = 0

func _ready():
    create_ring_areas()
    queue_redraw()

func create_ring_areas():
    var radii = [inner_ring_radius, second_ring_radius, third_ring_radius, outer_ring_radius]
    
    for i in range(radii.size()):
        var area = Area2D.new()
        var collision = CollisionShape2D.new()
        var shape = CircleShape2D.new()
        
        shape.radius = radii[i]
        collision.shape = shape
        area.add_child(collision)
        add_child(area)
        
        # Connect the area's signal
        area.body_entered.connect(_on_ring_entered.bind(i))
        ring_areas.append(area)

func _on_ring_entered(body: Node2D, ring_index: int):
    if body.is_in_group("projectiles"):
        if body.can_score():
            highlight_ring(ring_index)
            add_score(ring_scores[ring_index])

func add_score(points: int):
    current_score += points
    score_updated.emit(current_score)

func _draw():
    var radii = [inner_ring_radius, second_ring_radius, third_ring_radius, outer_ring_radius]
    var points = 64  # Number of points to create smooth circles
    
    for i in range(radii.size() - 1, -1, -1):
        var color = ring_colors[i]
        if highlighted_rings[i]:
            color.a = 0.6  # Increased alpha for highlights
            color = color.lightened(0.3)  # Make it brighter when highlighted
            
        # Calculate inner radius (0 for innermost ring)
        var inner_rad = 0.0 if i == 0 else radii[i-1]
        
        # Draw ring as filled polygon between outer and inner radius
        var vertices = PackedVector2Array()
        for j in range(points + 1):
            var angle = j * 2.0 * PI / points
            # Add outer vertex
            vertices.append(Vector2(cos(angle) * radii[i], sin(angle) * radii[i]))
        for j in range(points, -1, -1):
            var angle = j * 2.0 * PI / points
            # Add inner vertex
            vertices.append(Vector2(cos(angle) * inner_rad, sin(angle) * inner_rad))
        
        draw_colored_polygon(vertices, color)

func highlight_ring(ring_index: int):
    if ring_index >= 0 and ring_index < highlighted_rings.size():
        highlighted_rings[ring_index] = true
        queue_redraw()

func reset_highlights():
    highlighted_rings = [false, false, false, false]
    queue_redraw()

func reset_score():
    current_score = 0
    reset_highlights()
    score_updated.emit(current_score)
