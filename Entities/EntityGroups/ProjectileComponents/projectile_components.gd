extends Node2D

@onready var projectile: RigidBody2D = $RegularCat
@onready var sling: Node2D = $Slingshot

var dragging = false
var release_power = 10  # Adjust this to change the launch power
var max_drag_distance = 100  # Maximum distance the projectile can be dragged

func _ready():
    projectile.freeze = true  # Start with the projectile frozen

func _unhandled_input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            handle_mouse_press()
        elif event.is_released():
            handle_mouse_release()

func handle_mouse_press():
    var mouse_position = get_global_mouse_position()
    var shape = projectile.get_node("CollisionShape2D").shape
    var local_mouse_position = projectile.to_local(mouse_position)
    
    if shape.get_class() == "CircleShape2D":
        if local_mouse_position.length() <= shape.radius:
            start_dragging()

func start_dragging():
    dragging = true
    projectile.global_position = sling.global_position

func handle_mouse_release():
    if dragging:
        launch_projectile()
    dragging = false

func _process(_delta):
    if dragging:
        var mouse_position = get_global_mouse_position()
        var drag_vector = sling.global_position - mouse_position
        drag_vector = drag_vector.limit_length(max_drag_distance)
        projectile.global_position = sling.global_position - drag_vector

func launch_projectile():
    var launch_vector = sling.global_position - projectile.global_position
    projectile.freeze = false
    projectile.apply_impulse(launch_vector * release_power)
