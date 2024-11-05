extends Node3D

# Declare variables for camera position and direction
@export var target_point: Vector3  # Target point to fly towards
@export var camera_position: Vector3  # Position of the camera
@export var camera_direction: Vector3  # Direction of the camera
var velocity: Vector3       # Variable for velocity
var speed: float = 10.0     # Speed of the missile

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Calculate direction towards the target point
	var direction = (target_point - global_position).normalized()  # Calculate direction to the target
	velocity = direction * speed  # Set the missile's velocity

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update position based on the velocity
	position += velocity * delta  # Move the missile forward

	# Check if the missile has reached the target point
	if global_position.distance_to(target_point) < 0.5:  # Distance to target
		queue_free()  # Destroy the missile if it's close to the target

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		body.queue_free()  # Destroy enemy on collision
		queue_free()  # Destroy the missile
