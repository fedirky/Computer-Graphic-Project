extends CharacterBody3D

@onready var animation_tree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@onready var move_tilt_path: String = "parameters/StateMachine/Move/tilt/add_amount"

var run_tilt = 0.0: set = _set_run_tilt
var target_rotation := Transform3D()

@export var blink = true: set = set_blink
@onready var blink_timer = $BlinkTimer
@onready var closed_eyes_timer = $ClosedEyesTimer
@onready var eye_mat = $sophia/rig/Skeleton3D/Sophia.get("surface_material_override/2")

const SPEED = 5.0
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
    
func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += 2 * get_gravity() * delta

    # Стрибок, який активується при натисканні пробілу
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():  # ui_accept - стандартна клавіша для пробілу
        velocity.y = JUMP_VELOCITY
        jump()
    
    elif is_on_floor():
        idle()
    
    # Отримуємо напрямок з W, A, S, D
    var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

    # Отримуємо напрямок, куди дивиться камера
    var camera_direction = $Camera3D.global_transform.basis.z.normalized() # Не інвертуємо
    camera_direction.y = 0 # Не враховуємо вертикальний компонент
    camera_direction = camera_direction.normalized()

    # Визначаємо напрямок руху з урахуванням обертання камери
    var direction = (camera_direction * input_dir.y - transform.basis.x * input_dir.x).normalized()

    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED

        # Повертаємо персонажа лише вперед, без обертання вліво/вправо
        look_at(position + camera_direction, Vector3.UP)
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)
    
    if velocity.length() > 0.0 and velocity.y == 0.0:
        move()
    
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
