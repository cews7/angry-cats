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
    4,   # Inner ring (closest)
    3,   # Second ring
    2,   # Third ring
    1    # Outer ring
]

var scored_rings = []

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

        area.body_entered.connect(_on_ring_entered.bind(i))
        ring_areas.append(area)

func _on_ring_entered(body: Node2D, ring_index: int):
    # First check if the body is a valid projectile that can score
    if body.is_in_group("projectiles") and body.can_score():
        # Check if this ring hasn't been scored yet
        if !scored_rings.has(ring_index):
            # Add the ring to scored rings and highlight it
            scored_rings.append(ring_index)
            highlight_ring(ring_index)
            add_score(ring_scores[ring_index])

func add_score(points: int):
    score_updated.emit(points)

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
