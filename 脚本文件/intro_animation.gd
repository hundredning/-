extends Control

@onready var blur = $BlurMask
@onready var title = $TitleLabel
@onready var blur_material = blur.material   
signal intro_finished
func _ready():

	self.visible = true
	
	# 初始状态：遮罩完全不透明（最暗）、文字隐藏
	blur.modulate.a = 1.0  # 初始全暗（对应你要的“初始模糊”）
	title.modulate.a = 0.0 
		# 文字一开始不显示
	
	play_intro()

func play_intro():
	var tween = create_tween()
	
	# 1. 第一步：初始全暗，等待1秒（这1秒保持最暗，无变化）
	tween.tween_interval(2.0)
	
	# 2. 第二步：1秒后文字快速淡入（0.3秒显示）
	tween.tween_callback(func():
		var title_fade_in = create_tween()
		title_fade_in.tween_property(title, "modulate:a", 1.0, 1)
	)
	tween.tween_interval(2.5)
	# 3. 第三步：文字显示后，遮罩慢慢变透明（2秒内从1.0→0.0，即从暗变亮）
	tween.tween_property(blur, "modulate:a", 0.0, 3.0)
	
	# 4. 第四步：遮罩完全变亮（透明）后，文字2秒内淡出消失
	tween.tween_property(title, "modulate:a", 0.0, 2.0)
	
	# 5. 第五步：文字消失后，隐藏整个UI
	tween.tween_callback(func():
		self.visible = false
		emit_signal("intro_finished")
	
	)	
