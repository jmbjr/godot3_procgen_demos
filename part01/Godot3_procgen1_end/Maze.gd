extends Node2D

const NN = 1
const EE = 2
const SS = 4
const WW = 8

var N
var E
var S
var W

const ICON = 0
const NO_ICON = -1

export var use_yield = true
export var use_single_tile = false


var cell_walls
var tile_size = 64  # tile size (in pixels)
var width = 20  # width of map (in tiles)
var height = 12  # height of map (in tiles)

# get a reference to the map for convenience
onready var Map = $TileMap
onready var Map2 = $TileMap2

onready var start_time = OS.get_ticks_msec()

func _ready():
	randomize()
	if use_single_tile:
		N = 0
		S = 0
		E = 0
		W = 0
	else:
		N = NN
		S = SS
		E = EE
		W = WW
	
	cell_walls = {Vector2(0, -1): N, Vector2(1, 0): E, 
					  Vector2(0, 1): S, Vector2(-1, 0): W}
					
	tile_size = Map.cell_size
	make_maze()
	
func check_neighbors(cell, unvisited):
	# returns an array of cell's unvisited neighbors
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list
	
func make_maze():
	var iiframe = 1
	var unvisited = []  # array of unvisited tiles
	var stack = []
	# fill the map with solid tiles
	Map.clear()
	for x in range(width):
		for y in range(height):
			unvisited.append(Vector2(x, y))
			Map.set_cellv(Vector2(x, y), N|E|S|W)
	var current = Vector2(0, 0)
	unvisited.erase(current)
	# execute recursive backtracker algorithm
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			# remove walls from *both* cells
			var dir = next - current
			var current_walls = Map.get_cellv(current) - cell_walls[dir]
			var next_walls = Map.get_cellv(next) - cell_walls[-dir]
			Map2.set_cellv(current, NO_ICON)
			Map2.set_cellv(next, ICON)
			
			Map.set_cellv(current, current_walls)
			Map.set_cellv(next, next_walls)
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()
		
		if use_yield:
			yield(get_tree(), 'idle_frame')
			print("frame: %s, time: %s ms" % [iiframe, OS.get_ticks_msec() - start_time])
		iiframe+=1
	print("COMPLETE: frame: %s, time: %s ms" % [iiframe, OS.get_ticks_msec() - start_time])		
	