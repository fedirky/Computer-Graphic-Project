extends Camera3D

# Змінні для контролю камери
var target: Node3D # персонаж (вже є материнською нодою)
var distance: float = 3.0 # відстань камери до мішені
var vertical_angle: float = 0.3 # початковий вертикальний кут (в радіанах)
var horizontal_angle: float = 0.0 # початковий горизонтальний кут (в радіанах)
var rotation_speed: float = 0.005 # швидкість обертання камери (зменшена для точності)

# Максимальні кути по вертикалі
var max_vertical_angle: float = 1.0 # максимальний кут (вгору)
var min_vertical_angle: float = -0.0 # мінімальний кут (вниз)

# Викликається при завантаженні сцени
func _ready() -> void:
	target = get_parent() # материнська нода — це персонаж
	set_position_around_target()

# Обчислюємо позицію камери навколо мішені
func set_position_around_target() -> void:
	# Обчислюємо позицію камери на сферичній орбіті навколо мішені
	var target_position = target.global_transform.origin + Vector3(0, 1.0, 0) # Позиція вище персонажа на 2 одиниці
	var offset = Vector3(
		distance * cos(vertical_angle) * sin(horizontal_angle),
		distance * sin(vertical_angle), # Тепер не додаємо 2.0, оскільки ми це вже зробили в target_position
		distance * cos(vertical_angle) * cos(horizontal_angle)
	)
	
	global_transform.origin = target_position + offset
	look_at(target_position, Vector3.UP)

# Обробка подій вводу
func _input(event) -> void:
	if event is InputEventMouseMotion:
		# Отримуємо зміщення миші
		var mouse_input = event.relative * rotation_speed
		
		# Оновлюємо кути камери
		horizontal_angle -= mouse_input.x # Інвертуємо горизонтальне переміщення
		vertical_angle = clamp(vertical_angle - mouse_input.y, min_vertical_angle, max_vertical_angle) # Обмежуємо вертикальний кут

		set_position_around_target()

# Оновлюємо камеру кожен кадр
func _process(delta: float) -> void:
	set_position_around_target() # Оновлюємо позицію камери