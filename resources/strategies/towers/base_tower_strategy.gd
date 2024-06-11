class_name BaseTowerStrategy
extends Resource

@export var base_texture: Texture2D
@export var turret_texture: Texture2D
@export var scale: float = 2

var tower: Tower

func init(t: Tower):
	tower = t
	if base_texture is AtlasTexture:
		base_texture = base_texture.atlas
	if turret_texture is AtlasTexture:
		turret_texture = turret_texture.atlas
	tower.set_base_texture(base_texture)
	tower.set_turret_texture(turret_texture)
	tower.generate_hitbox_shape()
