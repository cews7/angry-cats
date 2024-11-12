extends Node2D

signal out_of_projectiles

@onready var blue_projectile: PackedScene = preload("res://Entities/Projectiles/Blue/blue.tscn")
@onready var sling: Node2D = $Slingshot
@onready var pull_line: Line2D = $PullLine
@onready var trajectory_line: PackedScene = preload("res://Entities/Projectiles/trajectory_line.tscn")

var level_projectile_counts = {
    "level_one": 4,
    "level_two": 2,
    "level_three": 3,
}

var trajectory_line_instance: Line2D
var active_projectile: RigidBody2D = null
var dragging = false
var max_drag_distance = 100
var launch_power_multiplier = 2.2  # Replace the hardcoded *2 with this
var projectiles: Array[RigidBody2D] = []


var current_drag_direction := Vector2.ZERO
var current_drag_power := 0.0

func _ready():
    out_of_projectiles.connect(get_parent()._on_projectile_components_empty)
    pull_line.hide()

    # Initialize projectiles based on current level
    var parent_scene_file = get_parent().scene_file_path
    var level_name = parent_scene_file.get_file().get_basename()
    var projectile_count = level_projectile_counts.get(level_name)
    
    # Initialize projectiles
    for i in range(projectile_count):
        var projectile_instance = blue_projectile.instantiate()
        add_child(projectile_instance)
        projectile_instance.projectile_hit_ground.connect(_on_projectile_hit_ground)
        add_projectile(projectile_instance)

    for projectile in projectiles:
        projectile.freeze = true

    trajectory_line_instance = trajectory_line.instantiate()
    add_child(trajectory_line_instance)
    setup_line_trajectory()


func _process(_delta):
    if dragging and active_projectile:
        var mouse_position = get_global_mouse_position()
        var drag_vector = sling.global_position - mouse_position
        drag_vector = drag_vector.limit_length(max_drag_distance)
        active_projectile.global_position = sling.global_position - drag_vector
        update_pull_line(mouse_position)

        # Calculate launch velocity to match actual launch
        var launch_vector = sling.global_position - active_projectile.global_position
        var launch_power = launch_vector.length() * launch_power_multiplier
        var launch_velocity = launch_vector.normalized() * launch_power

        trajectory_line_instance.update_trajectory(active_projectile.global_position, launch_velocity)
        trajectory_line_instance.show()
    else:
        trajectory_line_instance.hide()


func load_next_projectile() -> void:
    # Wait to load next projectile until the first has cleared the sling
    await get_tree().create_timer(0.3).timeout
    
    if projectiles.is_empty():
        return
    
    active_projectile = projectiles[0]
    active_projectile.freeze = true
    active_projectile.is_active = true  # Set the new projectile as active
    active_projectile.global_position = sling.global_position
    
    update_projectile_positions()

func update_projectile_positions():
    var spacing = 32
    var start_x = sling.global_position.x - spacing
    # Skip the first projectile (index 0) if it exists
    for i in range(1, projectiles.size()):
        projectiles[i].global_position = Vector2(
            start_x - (spacing * (i-1)),
            sling.global_position.y + 110
        )

func handle_mouse_press():
    var mouse_position = get_global_mouse_position()

    for projectile in projectiles:
        if !projectile.is_active:  # Skip if not the active projectile
            continue
            
        if projectile.freeze:  # Only consider frozen (unused) projectiles
            var shape = projectile.get_node("CollisionShape2D").shape
            var local_mouse_position = projectile.to_local(mouse_position)

            if shape.get_class() == "CircleShape2D":
                if local_mouse_position.length() <= shape.radius:
                    start_dragging(projectile)
                    return

func handle_mouse_release():
    if dragging:
        launch_projectile()
    dragging = false
    active_projectile = null
    pull_line.hide()
    trajectory_line_instance.hide()

func _unhandled_input(event):
    if event is InputEventMouseButton:
        match event.button_index:
            MOUSE_BUTTON_LEFT:
                if event.pressed:
                    handle_mouse_press()
                elif event.is_released():
                    handle_mouse_release()
            MOUSE_BUTTON_RIGHT:
                if event.pressed:
                    reset_active_projectile()

func remove_projectile(projectile: RigidBody2D):
    projectiles.erase(projectile)
    # Disable bouncing when removing projectile
    var physics_material = PhysicsMaterial.new()
    physics_material.bounce = 0.0
    physics_material.friction = 1.0
    projectile.set_physics_material_override(physics_material)
    if projectiles.size() == 0:
        out_of_projectiles.emit()

func add_projectile(projectile: RigidBody2D):
    projectiles.append(projectile)
    projectile.freeze = true

    # If this is the first projectile, position it in the slingshot and set as active
    if projectiles.size() == 1:
        projectile.global_position = sling.global_position
        projectile.is_active = true
        active_projectile = projectile
    else:
        projectile.is_active = false  # Ensure subsequent projectiles start inactive
        # Calculate position for the new projectile
        var spacing = 32
        var start_x = sling.global_position.x - spacing
        var index = projectiles.size() - 2
        projectile.global_position = Vector2(
            start_x - (spacing * index), 
            sling.global_position.y + 110
        )

func start_dragging(projectile: RigidBody2D):
    active_projectile = projectile
    dragging = true
    active_projectile.global_position = sling.global_position
    pull_line.show()  # Show the line when dragging starts
    update_pull_line(sling.global_position)  # Initialize the line

func update_pull_line(end_position: Vector2):
    pull_line.clear_points()

    # Convert sling position to pull_line's local coordinates
    var local_sling_pos = pull_line.to_local(sling.global_position)
    pull_line.add_point(local_sling_pos)

    var drag_vector = sling.global_position - end_position
    drag_vector = drag_vector.limit_length(max_drag_distance)
    var end_point = pull_line.to_local(sling.global_position - drag_vector)

    pull_line.add_point(end_point)

func launch_projectile():
    if active_projectile:
        var launch_vector = sling.global_position - active_projectile.global_position
        active_projectile.freeze = false
        active_projectile.is_active = false  # Deactivate the projectile when launched
        var launch_power = launch_vector.length() * launch_power_multiplier
        active_projectile.launch(launch_vector.normalized(), launch_power)
        # Reset the projectile's position to the sling position before launch
        active_projectile.global_position = sling.global_position

func setup_line_trajectory():
    # Create a gradient for the trajectory line
    var gradient = Gradient.new()
    gradient.colors = [Color(1, 1, 1, 1), Color(1, 1, 1, 0.2)]  # Solid white to transparent white
    trajectory_line_instance.width = 5.0
    trajectory_line_instance.gradient = gradient
    trajectory_line_instance.z_index = 1000
    trajectory_line_instance.show()

func _on_projectile_hit_ground(projectile: RigidBody2D):
    remove_projectile(projectile)
    load_next_projectile()

func reset_active_projectile():
    if active_projectile:
        active_projectile.global_position = sling.global_position
        dragging = false
        pull_line.hide()
        trajectory_line_instance.hide()
