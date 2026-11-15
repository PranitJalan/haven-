extends CanvasLayer

const TILE_WIDTH := 1440.0

# layer name -> [how much it follows the camera, self drift in px/sec]
# 0 barely moves and reads as distant, 1 would track the world exactly.
const LAYERS := {
	"Sky": [0.03, 0.0],
	"Forest09": [0.10, 0.0],
	"Forest08": [0.18, 0.0],
	"Forest07": [0.27, 0.0],
	"Forest06": [0.36, 0.0],
	"Motes": [0.44, 7.0],
	"Forest04": [0.52, 0.0],
	"Dust": [0.62, -11.0],
	"Bushes": [0.75, 0.0],
	"Mist": [0.88, -18.0],
}

var _drift := {}


func _ready() -> void:
	for layer_name in LAYERS:
		_drift[layer_name] = 0.0


func _process(delta: float) -> void:
	var camera := get_viewport().get_camera_2d()

	if camera == null:
		return

	var camera_x := camera.get_screen_center_position().x

	for layer_name in LAYERS:
		var layer := get_node_or_null(NodePath(layer_name)) as Node2D

		if layer == null:
			continue

		var follow: float = LAYERS[layer_name][0]
		var drift_speed: float = LAYERS[layer_name][1]

		_drift[layer_name] = _drift[layer_name] + drift_speed * delta

		# Each layer holds three copies side by side, so wrapping the offset
		# into one tile width keeps the seam off screen.
		var offset: float = -camera_x * follow + _drift[layer_name]
		layer.position.x = fposmod(offset, TILE_WIDTH) - TILE_WIDTH
