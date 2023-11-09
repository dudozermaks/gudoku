extends AspectRatioContainer

@export var spacing := 4
@export var horizontal_spacing := true

func _ready():
	resized.connect(_on_resized)

# Let's imagine we have a window with this size:
# x x x x
# x     x
# x x x x
# 4x3
# Grid should be full size square, like this:
# G G G x
# G   G x
# G G G x
# How do we do that?
# well, we have what's called stetch_ratio in godot
# For example, the stretch ratio of grid, in our case should be 3 (it occupies 3/4 of biggest window side)
# stretch_ratio of other part should be 1 (it occupies 1/4 of biggest window size)
# Or
# grid ratio: 3/4 = 0.75
# other ratio: 1/4 = 0.25
# How to calculate this in code?
func _on_resized():
# Step 1. Get window size
	var window_size := DisplayServer.window_get_size()
	# var window_size := get_viewport().get_visible_rect().size
	# Step 2. Get grid ratio (min side is size of square)
	var grid_ratio : float
	if horizontal_spacing:
		grid_ratio = (min(window_size.x, window_size.y)+spacing) / float(max(window_size.x, window_size.y))
	else:
		grid_ratio = (min(window_size.x, window_size.y)-spacing) / float(max(window_size.x, window_size.y))
# Step 3. Because we can't change other node's ratio, we assume it's 1 and ajust grid ratio by some amount
	var scale_ratio : float = 1 / (1 - grid_ratio)
	size_flags_stretch_ratio = scale_ratio * grid_ratio
	print("Changed grid stretch ratio to: ", size_flags_stretch_ratio)
