extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_speed: float = 4.0
@export var gravity: float = -9.8
@export var mouse_sensitivity: Vector2 = Vector2(0.002, 0.002)
@export var step_height: float = 0.5  # 自动上楼梯高度

var camera: Camera3D
var rotation_x: float = 0.0

# ✅ 新增：控制锁（默认 false，一开始不能动）
var can_control: bool = false

func _ready() -> void:
	camera = get_node("Camera3D")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
	# ✅ 新增：如果还没解锁，直接 return 不处理视角转动
	if not can_control:
		return
	# 鼠标控制视角
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_x -= event.relative.y * mouse_sensitivity.y
		rotation_x = clamp(rotation_x, deg_to_rad(-89), deg_to_rad(89))
		camera.rotation.x = rotation_x
		rotate_y(-event.relative.x * mouse_sensitivity.x)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# ✅ 新增：根据控制锁决定能不能走和跳
	if can_control:
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = jump_speed
			
		var input_dir = Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_forward", "move_backward")
		)
		if input_dir.length() > 0:
			input_dir = input_dir.normalized()
			var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else:
		# ✅ 新增：不能控制时，强制把速度降为 0（防止滑动）
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	var step_offset = Vector3(0, step_height, 0)
	if is_on_floor() and velocity.length() > 0 and test_move(transform, step_offset):
		global_position += step_offset

	move_and_slide()

# ✅ 新增：专门用来解锁的函数
func enable_control():
	can_control = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
