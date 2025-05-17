@tool
extends Control

const Utils = preload("res://addons/bitmask_automation/utils.gd")

@onready var source_select: ItemList = %SourceSelect
@onready var source_texture_rect: TextureRect = %SourceTextureRect
@onready var template_texture_rect: TextureRect = %TemplateTextureRect
@onready var apply_button: Button = %ApplyButton

@export var tile_map: TileMapLayer:
	get():
		return tile_map
	set(value):
		#if(tile_map):
			#tile_map.changed.disconnect(setup_source_list)
		tile_map = value
		#tile_map.changed.connect(setup_source_list)
		setup_source_list()
		check_apply_btn_disabled()

var template_texture: Texture2D:
	get():
		return template_texture
	set(value):
		template_texture = value
		if template_texture_rect:
			template_texture_rect.texture = template_texture
		check_apply_btn_disabled()

var selected_source: TileSetAtlasSource:
	get():
		return selected_source
	set(value):
		selected_source = value
		if source_texture_rect and selected_source:
			source_texture_rect.texture = selected_source.texture
		check_apply_btn_disabled()

var item_to_source_map: Dictionary[int, TileSetAtlasSource] = {}

func setup_source_list():
	clear_item_list()
	populate_item_list()

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

func check_apply_btn_disabled():
	if apply_button:
		if tile_map and template_texture and selected_source:
			apply_button.disabled = false
		else:
			apply_button.disabled = true

func _ready() -> void:
	tile_map = tile_map
	source_select.select(0)
	_on_item_list_item_selected(0)

func _on_item_list_item_selected(index: int) -> void:
	var source := item_to_source_map[index]
	selected_source = source

func _on_apply_button_pressed() -> void:
	if tile_map and template_texture and selected_source:
		Utils.update_tile_map(tile_map, template_texture, selected_source)

@onready var file_dialog: FileDialog = $FileDialog

func _on_pick_template_button_pressed() -> void:
	file_dialog.show()

func _on_file_dialog_file_selected(path: String) -> void:
	var res = load(path)
	if res is Texture2D:
		template_texture = res
