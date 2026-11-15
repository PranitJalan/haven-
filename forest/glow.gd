class_name Glow
extends RefCounted
## Shared helpers for the soft, Ori-style light the whole forest is built on.

static var _texture: GradientTexture2D
static var _additive: CanvasItemMaterial


static func texture() -> GradientTexture2D:
	if _texture == null:
		var gradient := Gradient.new()
		gradient.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
		gradient.colors = PackedColorArray([
			Color(1, 1, 1, 1),
			Color(1, 1, 1, 0.32),
			Color(1, 1, 1, 0),
		])
		_texture = GradientTexture2D.new()
		_texture.gradient = gradient
		_texture.fill = GradientTexture2D.FILL_RADIAL
		_texture.fill_from = Vector2(0.5, 0.5)
		_texture.fill_to = Vector2(1.0, 0.5)
		_texture.width = 256
		_texture.height = 256
	return _texture


static func additive() -> CanvasItemMaterial:
	if _additive == null:
		_additive = CanvasItemMaterial.new()
		_additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _additive


## A soft point light. `size` is the diameter of the lit area in pixels.
static func make_light(color: Color, energy: float, size: float) -> PointLight2D:
	var light := PointLight2D.new()
	light.texture = texture()
	light.texture_scale = size / 256.0
	light.color = color
	light.energy = energy
	return light


## A one-shot puff of glowing motes.
static func burst(
	parent: Node,
	pos: Vector2,
	color: Color,
	amount: int = 18,
	speed: float = 240.0
) -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = false
	p.amount = amount
	p.lifetime = 1.0
	p.explosiveness = 1.0
	p.direction = Vector2(0, -1)
	p.spread = 180.0
	p.gravity = Vector2(0, 90)
	p.initial_velocity_min = speed * 0.35
	p.initial_velocity_max = speed
	p.damping_min = 40.0
	p.damping_max = 90.0
	p.scale_amount_min = 0.03
	p.scale_amount_max = 0.07
	p.texture = texture()
	p.material = additive()
	p.color = color

	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 1.0])
	ramp.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	p.color_ramp = ramp

	parent.add_child(p)
	p.global_position = pos
	p.emitting = true
	p.finished.connect(p.queue_free)
