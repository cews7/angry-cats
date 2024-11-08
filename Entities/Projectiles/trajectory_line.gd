extends Line2D

const SIMULATION_STEPS = 35  # Number of points to simulate
const TIME_STEP = 0.1  # Time between each point
const GRAVITY = 30.0  # Match your project's gravity setting

func update_trajectory(start_position: Vector2, initial_velocity: Vector2) -> void:
    clear_points()
    
    var pos = start_position
    var vel = initial_velocity
    
    for _i in range(SIMULATION_STEPS):
        add_point(pos)
        
        # Update position and velocity using physics formulas
        pos += vel * TIME_STEP
        vel.y += GRAVITY * TIME_STEP
        
        # Optional: Stop if the trajectory hits the ground
        if pos.y > 1000:  # Adjust this value based on your ground level
            break


