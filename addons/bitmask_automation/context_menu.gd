@tool
class_name BitmapAutomationContextMenuPlugin
extends EditorContextMenuPlugin

func _popup_menu(paths: PackedStringArray) -> void:
	print(paths)
	add_context_menu_item('Apply Terrain Bitmap', on_test)

const template = preload("res://terrain-tilemap-template.png")

func on_test(args: Array) -> void:
	for arg in args:
		if arg is TileMapLayer:
			update_tile_map(arg)
	pass

class BitMaskImageCell:
	var coords: Vector2i
	var terrain: Color
	var neighbors: Dictionary[TileSet.CellNeighbor, Color]

class BitMaskImageParseResult:
	var colors: Array[Color]
	var cells: Array[BitMaskImageCell]

func parse_image(img: Image, cell_width: int, cell_height: int) -> BitMaskImageParseResult:
	var result = BitMaskImageParseResult.new()
	result.colors = [] as Array[Color]
	result.cells = [] as Array[BitMaskImageCell]

	var img_size = img.get_size()
	var hex_codes: Array[String] = []
	for y in range(img_size.y / cell_height):
		for x in range(img_size.x / cell_width):
			var cell = BitMaskImageCell.new()
			cell.coords = Vector2(x, y)
			
			var x_offset = x * cell_width
			var y_offset = y * cell_height

			cell.neighbors[TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER] = img.get_pixel(x_offset + 0, y_offset + 0)
			cell.neighbors[TileSet.CELL_NEIGHBOR_TOP_SIDE] = img.get_pixel(x_offset + floor(cell_width / 2.0), y_offset + 0)
			cell.neighbors[TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER] = img.get_pixel(x_offset + cell_width - 1, y_offset + 0)

			cell.neighbors[TileSet.CELL_NEIGHBOR_LEFT_SIDE] = img.get_pixel(x_offset + 0, y_offset + floor(cell_height / 2.0))
			cell.terrain = img.get_pixel(x_offset + floor(cell_width / 2.0), y_offset + floor(cell_height / 2.0))
			cell.neighbors[TileSet.CELL_NEIGHBOR_RIGHT_SIDE] = img.get_pixel(x_offset + cell_width - 1, y_offset + floor(cell_height / 2.0))

			cell.neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER] = img.get_pixel(x_offset + 0, y_offset + cell_height - 1)
			cell.neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_SIDE] = img.get_pixel(x_offset + floor(cell_width / 2.0), y_offset + cell_height - 1)
			cell.neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER] = img.get_pixel(x_offset + cell_width - 1, y_offset + cell_height - 1)
			
			for color: Color in [cell.terrain] + cell.neighbors.values():
				if color.a == 0.0:
					continue
				var hex_code = color.to_html()
				if !hex_codes.has(hex_code):
					hex_codes.push_back(hex_code)
					result.colors.push_back(color)

			result.cells.push_back(cell)
			
	return result

func update_tile_map(tile_map: TileMapLayer) -> void:
	var tile_set: TileSet = tile_map.tile_set
	var result = parse_image(template.get_image(), tile_set.tile_size.x, tile_set.tile_size.y)

	# Ensure there is at least one terrain set
	var terrain_sets_count = tile_set.get_terrain_sets_count()
	if terrain_sets_count == 0:
		tile_set.add_terrain_set()
		terrain_sets_count += 1
	var terrain_set_index = terrain_sets_count - 1

	# Collect existing terrains from the tile set
	var terrainColorToId = {}
	for terrain_index in range(tile_set.get_terrains_count(terrain_set_index)):
		var color = tile_set.get_terrain_color(terrain_set_index, terrain_index).to_html()
		terrainColorToId[color] = terrain_index
	
	# Add new terrains from the parsed image
	var new_terrain_index = tile_set.get_terrains_count(terrain_set_index)
	for terrain: Color in result.colors:
		var color = terrain.to_html()
		if !terrainColorToId.has(color):
			tile_set.add_terrain(terrain_set_index)
			tile_set.set_terrain_color(terrain_set_index, new_terrain_index, terrain)
			terrainColorToId[color] = new_terrain_index
			new_terrain_index += 1
	
	# Update the tile map's terrain and peering bits to match template image
	var src: TileSetAtlasSource = tile_set.get_source(0)
	for cell: BitMaskImageCell in result.cells:
		var has_tile = src.has_tile(cell.coords)
		if (!has_tile): continue
		var data = src.get_tile_data(cell.coords, 0)
		
		data.terrain_set = terrain_set_index

		if terrainColorToId.has(cell.terrain.to_html()):
			data.terrain = terrainColorToId[cell.terrain.to_html()]
		else:
			data.terrain = -1
		for neighbor in cell.neighbors:
			var color = cell.neighbors[neighbor].to_html()
			if terrainColorToId.has(color):
				data.set_terrain_peering_bit(neighbor, terrainColorToId[color])
			else:
				data.set_terrain_peering_bit(neighbor, -1)
