extends CharacterBody3D

@onready var animation_player = $AnimationPlayer  # Animation Player for the player character

var run_tilt = 0.0: set = _set_run_tilt
var target_rotation := Transform3D()
var current_animation: String = ""  # Internal variable to track the current animation

@export var missile_scene: PackedScene

var SPEED = 6.0
const LERP_AFK_SPEED = 50.0
const JUMP_VELOCITY = 4.5 * 2
const mouse_sensitivity = 0.002
const BLEND_TIME = 0.2  # Desired blend time between animations

const SPELLCAST_DURATION = 0.9333  # Duration of the spellcast animation
const MISSILE_SPAWN_DELAY = 0.85   # Delay before spawning missile after spellcast starts
var is_casting_spell = false  # Flag to indicate if the spell is currently being cast
var spellcast_timer = 0.0  # Timer to track the spellcasting duration

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            cast_spell()  # Trigger spellcast on RMB press

func spawn_missile():
    if missile_scene:
        var missile_instance = missile_scene.instantiate()
        missile_instance.position = $Marker3D.global_position  # Позиція запуску снаряда
        
        # Отримати позицію та напрямок камери
        var camera_position = $Camera3D.global_position
        var camera_direction = -$Camera3D.global_transform.basis.z.normalized()
        
        # Передати позицію та напрямок камери снаряду
        missile_instance.camera_position = camera_position
        missile_instance.camera_direction = camera_direction
        get_parent().add_child(missile_instance)

func _physics_process(delta: float) -> void:
    # Jumping logic
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY
        jump()
        return  # Stop further checks if jump animation is triggered
    
    # Apply gravity if not on the floor
    if not is_on_floor():
        jump()
        velocity += 2 * get_gravity() * delta
    
    # Movement and animation logic based on the character state
    var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

    if is_on_floor():
        if input_dir.length() > 0:  # Running if there's movement input
            move()
        else:  # Idle if on the floor and no movement input
            idle()
    if is_casting_spell:
        SPEED = 3
    else:
        SPEED = 6
    
    # Movement direction calculation for movement and rotation
    var camera_direction = $Camera3D.global_transform.basis.z.normalized()
    camera_direction.y = 0  # Ignore the vertical component
    camera_direction = camera_direction.normalized()
    var camera_right = $Camera3D.global_transform.basis.x.normalized()
    camera_right.y = 0
    camera_right = camera_right.normalized()
    var direction = (camera_direction * input_dir.y + camera_right * input_dir.x).normalized()

    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED

        # Calculate the target rotation based on the movement direction
        var local_target_rotation = atan2(direction.x, direction.z)
        var current_rotation = rotation.y
        rotation.y = lerp_angle(current_rotation, local_target_rotation, 0.1)
    else:
        # Decelerate when there’s no movement input
        velocity.x = lerp(velocity.x, 0.0, LERP_AFK_SPEED * delta)
        velocity.z = lerp(velocity.z, 0.0, LERP_AFK_SPEED * delta)

    move_and_slide()

    # Update spellcasting timer if casting
    if is_casting_spell:
        spellcast_timer -= delta
        if spellcast_timer <= MISSILE_SPAWN_DELAY and spellcast_timer > MISSILE_SPAWN_DELAY - delta:
            spawn_missile()  # Spawn the missile at 0.85 seconds after casting starts
        if spellcast_timer <= 0:
            is_casting_spell = false  # Reset the casting flag when the duration is over

func _set_run_tilt(value: float):
    run_tilt = clamp(value, -1.0, 1.0)

func idle():
    if not is_casting_spell:  # Only play idle if not casting
        _play_animation("Idle")

func move():
    if not is_casting_spell:  # Only play move if not casting
        _play_animation("Running_A")

func jump():
    if not is_casting_spell:  # Only play jump if not casting
        _play_animation("Jump_Idle")

func cast_spell():
    if not is_casting_spell:  # Only start casting if not currently casting
        _play_animation("Spellcast_Shoot")  # Call to play the spellcasting animation
        is_casting_spell = true  # Set casting flag to true
        spellcast_timer = SPELLCAST_DURATION  # Reset the timer for the spellcast animation

func _play_animation(anim_name: String) -> void:
    # Check if the requested animation is different from the current animation
    if current_animation != anim_name:
        animation_player.play(anim_name, BLEND_TIME)  # Use blend time for smooth transition
        current_animation = anim_name  # Update the internal variable with the new animation name
