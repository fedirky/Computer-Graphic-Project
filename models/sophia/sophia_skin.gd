extends CharacterBody3D

@onready var animation_tree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@onready var move_tilt_path: String = "parameters/StateMachine/Move/tilt/add_amount"

var run_tilt = 0.0: set = _set_run_tilt
var target_rotation := Transform3D()

@export var missile_scene: PackedScene
@export var blink = true: set = set_blink
@onready var blink_timer = $BlinkTimer
@onready var closed_eyes_timer = $ClosedEyesTimer
@onready var eye_mat = $sophia/rig/Skeleton3D/Sophia.get("surface_material_override/2")



const SPEED = 5.0
const LERP_AFK_SPEED = 50.0
const JUMP_VELOCITY = 4.5 * 2
const mouse_sensitivity = 0.002

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	blink_timer.connect("timeout", func():
		eye_mat.set("uv1_offset", Vector3(0.0, 0.5, 0.0))
		closed_eyes_timer.start(0.2)
	)
		
	closed_eyes_timer.connect("timeout", func():
		eye_mat.set("uv1_offset", Vector3.ZERO)
		blink_timer.start(randf_range(1.0, 4.0))
	)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:  # Перевірка, чи є подія натисканням кнопки миші
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:  # Ліва кнопка миші натиснута
			spawn_missle()
	
func spawn_missle():
	if missile_scene:
		var missile_instance = missile_scene.instantiate()
		missile_instance.position = $Marker3D.global_position
		
		# Get the camera's forward direction
		var camera_direction = $Camera3D.global_transform.basis.z.normalized()
		camera_direction.y = 0  # Ignore the vertical component
		camera_direction = camera_direction.normalized()

		# Set the missile's direction
		missile_instance.direction = -camera_direction

		get_parent().add_child(missile_instance)

	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += 2 * get_gravity() * delta

	# Jump activated by pressing the space bar
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump()
	
	elif is_on_floor():
		idle()
	
	# Get movement direction from W, A, S, D
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

	# Get the camera direction
	var camera_direction = $Camera3D.global_transform.basis.z.normalized()
	camera_direction.y = 0  # Ignore the vertical component
	camera_direction = camera_direction.normalized()

	# Get the camera's right direction (for left-right movement)
	var camera_right = $Camera3D.global_transform.basis.x.normalized()
	camera_right.y = 0  # Ignore the vertical component
	camera_right = camera_right.normalized()

	# Determine the movement direction considering camera rotation
	var direction = (camera_direction * input_dir.y + camera_right * input_dir.x).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		# Calculate the target rotation based on the movement direction
		var target_rotation = atan2(direction.x, direction.z)  # Calculate angle based on direction

		# Smoothly rotate the character towards the target rotation
		var current_rotation = rotation.y
		rotation.y = lerp_angle(current_rotation, target_rotation, 0.1)  # Adjust 0.1 to change rotation speed
		
		if velocity.y == 0:
			move()
	else:
		# Use lerp to decelerate the velocity when there's no input
		velocity.x = lerp(velocity.x, 0.0, LERP_AFK_SPEED * delta)
		velocity.z = lerp(velocity.z, 0.0, LERP_AFK_SPEED * delta)
	
	move_and_slide()

func set_blink(state: bool):
	if blink == state: return
	blink = state
	if blink:
		blink_timer.start(0.2)
	else:
		blink_timer.stop()
		closed_eyes_timer.stop()

func _set_run_tilt(value: float):
	run_tilt = clamp(value, -1.0, 1.0)
	animation_tree.set(move_tilt_path, run_tilt)

func idle():
	state_machine.travel("Idle")

func move():
	state_machine.travel("Move")

func fall():
	state_machine.travel("Fall")

func jump():
	state_machine.travel("Jump")

func edge_grab():
	state_machine.travel("EdgeGrab")

func wall_slide():
	state_machine.travel("WallSlide")
