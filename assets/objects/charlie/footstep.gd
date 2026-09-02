extends RayCast2D

@export var sounds: Dictionary[String, AudioStreamPlayer2D]

@onready var charlie: CharacterBody2D = get_parent()
var tilemap: TileMapLayer
var material_type: String = "default"
var local_position: Vector2
var tilemap_location: Vector2
var cell_tile_data: TileData

func _physics_process(_delta: float) -> void:
	if is_colliding():
		var collider: Node2D = get_collider()
		if get_collider() is PhysicsBody2D && has_method("material_type"):
			parse_phys_body(collider)
		elif collider is TileMapLayer:
			parse_tile(collider)

func play_footstep() -> void:
	sounds[material_type].volume_db = 3.0 if charlie.is_walking else 10.0
	sounds[material_type].play()

func parse_tile(collider: TileMapLayer) -> void:
	tilemap = collider
	local_position = get_parent().to_local(tilemap.global_position) * Vector2(-1, -1) + Vector2(0, 1)
	tilemap_location = tilemap.local_to_map(local_position)
	cell_tile_data = tilemap.get_cell_tile_data(tilemap_location)
	material_type = material_type if !cell_tile_data else cell_tile_data.get_custom_data("material")
	material_type = material_type if material_type != "" else "default"

func parse_phys_body(body: PhysicsBody2D) -> void:
	material_type = body.material_type if body.has_method("material_type") else "default"
