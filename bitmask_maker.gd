@tool
class_name BitmaskMaker extends Node

@export var tilemap: TileMapLayer
@export var template: Texture2D

@export var run = false:
	set(new_value):
		if new_value == true:
			update_tilemap()
			pass

# const BITMASK_TEPLATE = "res://mask16-g.png"
const CELL_WIDTH = 16
const CELL_HEIGHT = 16
const TERRAIN_SET_ID = 0

class BitMaskImageCell:
	var cell_x: int
	var cell_y: int

	var top_left: Color
	var top_side: Color
	var top_right: Color
	var left_side: Color
	var center: Color
	var right_side: Color
	var bottom_left: Color
	var bottom_side: Color
	var bottom_right: Color
	
	func _to_string() -> String:
		return "X: %s, Y: %s\n%s %s %s\n%s %s %s\n%s %s %s" % [cell_x, cell_y, top_left.to_html(), top_side.to_html(),top_right.to_html(),left_side.to_html(),center.to_html(),right_side.to_html(),bottom_left.to_html(),bottom_side.to_html(),bottom_right.to_html()]

class BitMaskImageParseResult:
	var terrains: Array[Color]
	var cells: Array[BitMaskImageCell]

func parse_image(img: Image, cell_width: int, cell_height: int):
	var hex_codes: Array[String] = []
	var terrains: Array[Color] = []
	var cells: Array[BitMaskImageCell] = []

	var img_size = img.get_size()
	for y in range(img_size.y / cell_height):
		for x in range(img_size.x / cell_width):
			var x_offset = x * cell_width
			var y_offset = y * cell_height

			var top_left = img.get_pixel( x_offset + 0, y_offset + 0 )
			var top_side = img.get_pixel( x_offset + floor(cell_width / 2.0), y_offset + 0 )
			var top_right = img.get_pixel( x_offset + cell_width - 1, y_offset + 0 )

			var middle_left = img.get_pixel( x_offset + 0, y_offset + floor(cell_height / 2.0) )
			var middle_side = img.get_pixel( x_offset + floor(cell_width / 2.0), y_offset + floor(cell_height / 2.0) )
			var middle_right = img.get_pixel( x_offset + cell_width - 1, y_offset + floor(cell_height / 2.0) )

			var bottom_left = img.get_pixel( x_offset + 0, y_offset + cell_height - 1 )
			var bottom_side = img.get_pixel( x_offset + floor(cell_width / 2.0), y_offset + cell_height - 1 )
			var bottom_right = img.get_pixel( x_offset + cell_width - 1, y_offset + cell_height - 1 )

			for color in [top_left,top_side,top_right,middle_left,middle_side,middle_right,bottom_left,bottom_side,bottom_right]:
				if color.a == 0.0:
					continue
				var hex_code = color.to_html()
				if !hex_codes.has(hex_code):
					hex_codes.push_back(hex_code)
					terrains.push_back(color)

			var cell = BitMaskImageCell.new()
			cell.cell_x = x
			cell.cell_y = y
			cell.top_left = top_left
			cell.top_side = top_side
			cell.top_right = top_right
			cell.left_side = middle_left
			cell.center = middle_side
			cell.right_side = middle_right
			cell.bottom_left = bottom_left
			cell.bottom_side = bottom_side
			cell.bottom_right = bottom_right

			cells.push_back(cell)
	
	var result = BitMaskImageParseResult.new()
	result.terrains = terrains
	result.cells = cells
	return result

func update_tilemap() -> void:
	var tile_set = tilemap.tile_set
	# template.

	# var img = Image.load_from_file(BITMASK_TEPLATE)
	var result = parse_image(template.get_image(), CELL_WIDTH, CELL_HEIGHT)
	# print(result.terrains)

	var terrainColorToId = {}
	for terrain_id in range(tile_set.get_terrains_count(TERRAIN_SET_ID)):
		var terrain_color = tile_set.get_terrain_color(TERRAIN_SET_ID, terrain_id).to_html()
		terrainColorToId[terrain_color] = terrain_id
	
	var new_terrain_index = tile_set.get_terrains_count(TERRAIN_SET_ID)
	for terrain in result.terrains:
		var color = terrain.to_html()
		if !terrainColorToId.has(color):
			tile_set.add_terrain(TERRAIN_SET_ID)
			tile_set.set_terrain_color(TERRAIN_SET_ID,new_terrain_index,terrain)
			new_terrain_index += 1

	for terrain_id in range(tile_set.get_terrains_count(TERRAIN_SET_ID)):
		var terrain_color = tile_set.get_terrain_color(TERRAIN_SET_ID, terrain_id).to_html()
		terrainColorToId[terrain_color] = terrain_id

	var src: TileSetAtlasSource = tile_set.get_source(0)
	# print(tile_set.get_source_count())

	# var grid_size = src.get_atlas_grid_size()
	for cell in result.cells:
		var data = src.get_tile_data(Vector2i(cell.cell_x, cell.cell_y), 0)
		if terrainColorToId.has(cell.top_left.to_html()):
			data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER, terrainColorToId[cell.top_left.to_html()])
		if terrainColorToId.has(cell.top_side.to_html()):
			data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_SIDE, terrainColorToId[cell.top_side.to_html()])
		if terrainColorToId.has(cell.top_right.to_html()):
			data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER, terrainColorToId[cell.top_right.to_html()])
		if terrainColorToId.has(cell.left_side.to_html()):
			data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_LEFT_SIDE, terrainColorToId[cell.left_side.to_html()])
		if terrainColorToId.has(cell.center.to_html()):
			data.terrain = terrainColorToId[cell.center.to_html()]
		if terrainColorToId.has(cell.right_side.to_html()):
			data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_RIGHT_SIDE, terrainColorToId[cell.right_side.to_html()])
		if terrainColorToId.has(cell.bottom_left.to_html()):
			data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, terrainColorToId[cell.bottom_left.to_html()])
		if terrainColorToId.has(cell.bottom_side.to_html()):
			data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, terrainColorToId[cell.bottom_side.to_html()])
		if terrainColorToId.has(cell.bottom_right.to_html()):
			data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, terrainColorToId[cell.bottom_right.to_html()])

