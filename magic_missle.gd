extends Node3D

var direction: Vector3
var velocity: Vector3  # Declare the velocity variable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set a speed for the missile
	var speed = 20.0
	# Initialize velocity based on the direction
	velocity = direction * speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update position based on the velocity
	position += velocity * delta  # Move the missile forward


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		body.queue_free()
	queue_free()
