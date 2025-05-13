@tool
extends Control

const Utils = preload("res://addons/bitmask_automation/utils.gd")
const TERRAIN_TILEMAP_TEMPLATE = preload("res://addons/bitmask_automation/terrain-tilemap-template.png")

@onready var source_select: ItemList = %SourceSelect
@onready var source_texture_rect: TextureRect = %SourceTextureRect
@onready var template_texture_rect: TextureRect = %TemplateTextureRect
@onready var apply_button: Button = %ApplyButton

@export var tile_map: TileMapLayer:
	get():
		return tile_map
	set(value):
		tile_map = value
		clear_item_list()
		populate_item_list()

var selected_source: TileSetAtlasSource:
	get():
		return selected_source
	set(value):
		selected_source = value
		if source_texture_rect and selected_source:
			source_texture_rect.texture = selected_source.texture

var item_to_source_map: Dictionary[int, TileSetAtlasSource] = {}

func clear_item_list():
	if source_select:
		for item_id in range(source_select.item_count - 1, -1, -1):
			source_select.remove_item(item_id)
func populate_item_list():
	if source_select and tile_map and tile_map.tile_set:
		for source in Utils.get_atlas_sources(tile_map.tile_set):
			var name := source.texture.resource_path.split("/")[-1]
			var id = source_select.add_item(name, source.texture, true)
			item_to_source_map[id] = source

func _ready() -> void:
	tile_map = tile_map
	source_select.select(0)
	template_texture_rect.texture = TERRAIN_TILEMAP_TEMPLATE
	_on_item_list_item_selected(0)

func _on_item_list_item_selected(index: int) -> void:
	var source := item_to_source_map[index]
	selected_source = source

func _on_apply_button_pressed() -> void:
	Utils.update_tile_map(tile_map, TERRAIN_TILEMAP_TEMPLATE, selected_source)
