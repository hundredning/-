extends Camera3D

# 相机参数
@export var move_speed: float = 30
@export var rotate_speed: float = 0.5
@export var zoom_speed: float = 2.0
@export var min_height: float = 2.0
@export var max_height: float = 30.0

var pivot: Vector3 = Vector3.ZERO
var mouse_delta: Vector2 = Vector2.ZERO

# ✅ 新增：控制锁（默认 false）
var can_control: bool = false

func _ready() -> void:
	pivot = global_position


func _input(event: InputEvent) -> void:
	# ✅ 新增：没解锁就不记录鼠标输入
	if not can_control:
		return 
		
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

func _process(delta: float) -> void:
	# ✅ 新增：没解锁就直接退出，不执行移动
	if not can_control:
		return
		
	if not get_parent().is_god_mode:
		mouse_delta = Vector2.ZERO
		return
	
	move_camera(delta)
	rotate_camera()
	zoom_camera()
	mouse_delta = Vector2.ZERO

# ✅ 新增：用于解锁的函数
func enable_control():
	can_control = true

# WASD平移
func move_camera(delta: float) -> void:
	var input = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_forward", "move_backward")
	)
	if input.length() > 0:
		input = input.normalized()
		pivot += global_transform.basis.x * input.x * move_speed * delta
		pivot += global_transform.basis.z * input.y * move_speed * delta
		global_position = pivot

# 右键旋转
func rotate_camera() -> void:
	if Input.is_action_pressed("camera_rotate"):
		rotate_y(-mouse_delta.x * rotate_speed * 0.01)
		var new_x = rotation.x + mouse_delta.y * rotate_speed * 0.01
		rotation.x = clamp(new_x, deg_to_rad(-80), deg_to_rad(-10))

# 滚轮缩放
func zoom_camera() -> void:
	# ✅ 正确获取轴输入：负向=缩小/下移，正向=放大/上移
	var zoom = Input.get_axis("zoomout", "zoomin")
	
	if zoom != 0:
		# ✅ 你的逻辑：控制相机【上下平移】（不是缩放）
		var new_height = global_position.y - zoom * zoom_speed
		global_position.y = clamp(new_height, min_height, max_height)
		pivot = global_position
