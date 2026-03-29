@tool
class_name CarouselContainer extends Node2D

@export var spacing: float = 20

@export var wraparound_enabled: bool = false
@export var wraparound_radius: float = 300
@export var wraparound_height: float = 50

@export_range(0, 1) var opacity_strength: float = 0.35
@export_range(0, 1) var scale_strength: float = 0.25
@export_range(0.01, 0.99, 0.01) var scale_min: float = 0.1

@export var smoothing_speed: float = 6.5
@export var selected_index: int = 0
@export var follow_button_focus: bool = false

@export var position_offset_node: Control = null

func _process(delta: float) -> void:
	if !position_offset_node or position_offset_node.get_child_count() == 0:
		return
	
	selected_index = clamp(selected_index, 0, position_offset_node.get_child_count() - 1)
	
	for i in position_offset_node.get_children():
		if wraparound_enabled:
			var max_index_range: float = max(1, (position_offset_node.get_child_count() - 1) / 2.0)
			var angle: float = clamp((i.get_index() - selected_index) / max_index_range, -1, 1.0) * PI
			var x: float = sin(angle) * wraparound_radius
			var y: float = cos(angle) * wraparound_height
			var target_pos: Vector2 = Vector2(x, y - wraparound_height) - i.size/2.0
			i.position = lerp(i.position, target_pos, smoothing_speed * delta)
		else:
			var position_x: float = 0
			if i.get_index() > 0:
				position_x = position_offset_node.get_child(i.get_index()-1).position.x + position_offset_node.get_child(i.get_index()-1).size.x + spacing
			i.position = Vector2(position_x, - i.size.y / 2.0)
			
		#i.pivot_offset = Vector2(i.size.x/2.0, i.size.y)
		i.pivot_offset = i.size/2
		var target_scale: float = 1.0 - (scale_strength * abs(i.get_index() - selected_index))
		target_scale = clamp(target_scale, scale_min, 1.0)
		i.scale = lerp(i.scale, Vector2.ONE * target_scale, smoothing_speed * delta)
		
		var target_opacity: float = 1.0 - (opacity_strength * abs(i.get_index() - selected_index))
		target_opacity = clamp(target_opacity, 0.0, 1.0)
		i.modulate.a = lerp(i.modulate.a, target_opacity, smoothing_speed * delta)
		
		if i.get_index() == selected_index:
			i.z_index = 1
			i.mouse_filter = Control.MOUSE_FILTER_STOP
			i.focus_mode = Control.FOCUS_ALL
		else:
			i.z_index = -abs(i.get_index() - selected_index)
			i.mouse_filter = Control.MOUSE_FILTER_IGNORE
			i.focus_mode = Control.FOCUS_NONE
		
		if follow_button_focus and i.has_focus():
			selected_index = i.get_index()
		
	if wraparound_enabled:
		position_offset_node.position.x = lerp(position_offset_node.position.x, 0.0, smoothing_speed * delta)
	else:
		position_offset_node.position.x = lerp(position_offset_node.position.x, -(position_offset_node.get_child(selected_index).position.x + position_offset_node.get_child(selected_index).size.x/2.0), smoothing_speed * delta)
			
func _left() -> void:
	if selected_index < 0:
		selected_index = position_offset_node.get_child_count() - 1
	else:
		selected_index -= 1
	

func _right() -> void:
	if selected_index > position_offset_node.get_child_count() - 1:
		selected_index = 1
	else:
		selected_index += 1
