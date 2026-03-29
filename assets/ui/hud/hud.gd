extends CanvasLayer

#region load hud textures
@onready var ui: Texture2D = load("res://assets/ui/hud/hud.png")
@onready var ui_veryhurt: Texture2D = load("res://assets/ui/hud/veryhurt.png")
@onready var ui_crit: Texture2D = load("res://assets/ui/hud/crit.png")
@onready var ui_heal: Texture2D = load("res://assets/ui/hud/heal.png")
@onready var ui_dead: Texture2D = load("res://assets/ui/hud/dead.png")
#endregion
#region load charlie pics
@onready var char_default: Texture2D = load("res://assets/ui/hud/charlie_icons/1neutral.png")
@onready var char_hurt: Texture2D = load("res://assets/ui/hud/charlie_icons/2hurt.png")
@onready var char_veryhurt: Texture2D = load("res://assets/ui/hud/charlie_icons/3veryhurt.png")
@onready var char_healed: Texture2D = load("res://assets/ui/hud/charlie_icons/4healed.png")
@onready var char_goddamn: Texture2D = load("res://assets/ui/hud/charlie_icons/5goddamn.png")
@onready var char_death: Texture2D = load("res://assets/ui/hud/charlie_icons/6death.png")
#endregion
#region load numbers
@onready var zero: Texture2D = load("res://assets/ui/hud/numbers/0.png")
@onready var one: Texture2D = load("res://assets/ui/hud/numbers/1.png")
@onready var two: Texture2D = load("res://assets/ui/hud/numbers/2.png")
@onready var three: Texture2D = load("res://assets/ui/hud/numbers/3.png")
@onready var four: Texture2D = load("res://assets/ui/hud/numbers/4.png")
@onready var five: Texture2D = load("res://assets/ui/hud/numbers/5.png")
@onready var six: Texture2D = load("res://assets/ui/hud/numbers/6.png")
@onready var seven: Texture2D = load("res://assets/ui/hud/numbers/7.png")
@onready var eight: Texture2D = load("res://assets/ui/hud/numbers/8.png")
@onready var nine: Texture2D = load("res://assets/ui/hud/numbers/9.png")
@onready var trans: Texture2D = load("res://assets/ui/hud/numbers/trans.png")

@onready var hud_num: Array = [zero, one, two, three, four, five, six, seven, eight, nine]
#endregion
#region number timers
@export var ones_timer: Timer
@export var tens_timer: Timer
@export var hund_timer: Timer
var ones_temp: int
var tens_temp: int
var hund_temp: int
var previous_health: String
#endregion

@onready var crit_sound: AudioStreamOggVorbis = load("res://assets/ui/hud/sound-crit.ogg")
@onready var supercrit_sound: AudioStreamOggVorbis = load("res://assets/ui/hud/sound-supercrit.ogg")

@export var container: Node2D
@export var container_anim_player: AnimationPlayer
@export var hud: Sprite2D
@export var charlie_face: Sprite2D
@export var ones: Sprite2D
@export var tens: Sprite2D
@export var hundreds: Sprite2D
@export var wibl_counter: Label

@onready var health_change_sfx: AudioStreamPlayer = $HealthChange
var obi_scene: PackedScene = load("res://assets/ui/hud/obi.tscn")
var string_health: String

var is_critting_out_rn: bool = false

func _ready() -> void:
	PlayerVar.connect("change_health_display", change_health)
	PlayerVar.connect("change_hud_maybe", change_hud)
	Staglobals.connect("wiblings_collected", wibl_collect)
	SignalBus.connect("crit_delivered", crit_delivered)
	SignalBus.connect("charlie_death", charlie_death)
	SignalBus.connect("show_hud", show_hud) # the player setting
	Staglobals.connect("show_hud", show_hud_stage) # for dramatic effect
	SignalBus.connect("show_obi", show_obi)
	
	show_hud(PlayerVar.show_hud)
	
	string_health = str(PlayerVar.health).pad_zeros(3)
	hundreds.texture = hud_num[int(string_health[0])]
	tens.texture = hud_num[int(string_health[1])]
	ones.texture = hud_num[int(string_health[2])]

func show_obi() -> void:
	var obi_inst: CanvasLayer = obi_scene.instantiate()
	add_child(obi_inst)

func show_hud(yes: bool) -> void:
	if yes:
		visible = true
	else:
		visible = false

func show_hud_stage(yes: bool = true) -> void:
	if yes && PlayerVar.show_hud:
		container_anim_player.play_backwards("show->hide")
		Staglobals.hud_hidden = false
	elif !yes:
		container_anim_player.play("show->hide")
		Staglobals.hud_hidden = true

#region changing health
func change_health() -> void:
	health_change_sfx.play()
	previous_health = string_health
	string_health = str(PlayerVar.health).pad_zeros(3)
	
	change_ones(int(string_health[2]))
	change_tens(int(string_health[1]))
	change_hund(int(string_health[0]))
	
	if (!string_health == str(PlayerVar.target_health).pad_zeros(3)):
		var tween : Tween = create_tween()
		tween.tween_property(container, "position", Vector2( \
			randf_range(-1.0, 0) * 10, \
			randf_range(-1.0, 0) * 10 \
		), PlayerVar.health_speed).set_trans(Tween.TRANS_EXPO)
		tween.parallel().tween_property(container, "rotation", randf_range(-0.01, 0.01), \
		PlayerVar.health_speed).set_trans(Tween.TRANS_EXPO)
	else:
		var tween : Tween = create_tween().set_ease(Tween.EASE_OUT)
		tween.tween_property(container, "position", Vector2(0,0),\
		0.25).set_trans(Tween.TRANS_EXPO)
		tween.parallel().tween_property(container, "rotation", 0, 0.25)

func change_ones(num: int) -> void:
	ones_temp = num
	if ones_timer.is_stopped && (int(previous_health[2]) != num):
		ones_timer.start()
		ones.texture = trans

func change_tens(num: int) -> void:
	tens_temp = num
	if tens_timer.is_stopped && (int(previous_health[1]) != num):
		tens_timer.start()
		tens.texture = trans

func change_hund(num: int) -> void:
	hund_temp = num
	if hund_timer.is_stopped && (int(previous_health[0]) != num):
		hund_timer.start()
		hundreds.texture = trans

func _on_ones_timer_timeout() -> void:
	ones.texture = hud_num[ones_temp]

func _on_tens_timer_timeout() -> void:
	tens.texture = hud_num[tens_temp]

func _on_hund_timer_timeout() -> void:
	hundreds.texture = hud_num[hund_temp]
#endregion

func wibl_collect(amount: int) -> void:
	wibl_counter.text = str(amount)

func change_hud() -> void:
	if !is_critting_out_rn:
		match PlayerVar.health_state:
			0, 1:
				@warning_ignore("integer_division")
				if PlayerVar.health < (PlayerVar.base_health / 3):
					hud.texture = ui_veryhurt
					charlie_face.texture = char_veryhurt
					wibl_counter.modulate = Color.html("#CD1907")
				else:
					hud.texture = ui
					wibl_counter.modulate = Color.WHITE
					if PlayerVar.health_state == 1:
						charlie_face.texture = char_hurt
					else:
						charlie_face.texture = char_default
			2:
				hud.texture = ui_heal
				charlie_face.texture = char_healed
				wibl_counter.modulate = Color.WHITE

func crit_delivered(supercrit:bool) -> void:
	is_critting_out_rn = true
	hud.texture = ui_crit
	charlie_face.texture = char_goddamn
	wibl_counter.modulate = Color.BLACK
	
	if !supercrit:
		SoundManager.play_ui_sound(crit_sound)
	else:
		SoundManager.play_ui_sound(supercrit_sound)
	
	await get_tree().create_timer(0.8).timeout
	is_critting_out_rn = false
	change_hud()

func charlie_death() -> void:
	charlie_face.texture = char_death
	hud.texture = ui_dead
