extends AnimatedSprite2D
const ANIMATED_CURSOR_CONFIG = preload("uid://cc7664bywpfcy")

func _ready() -> void:
	sprite_frames = ANIMATED_CURSOR_CONFIG.cursor_sprite_frames
	ANIMATED_CURSOR_CONFIG.cursor_sprite_frames.set_animation_speed("default", ANIMATED_CURSOR_CONFIG.frames_per_second)
	play("default")
	hide()
	connect("frame_changed", _update_mouse_cursor)

func _update_mouse_cursor():
#	DisplayServer.cursor_set_custom_image(sprite_frames.get_frame_texture("default", frame), DisplayServer.CURSOR_ARROW, ANIMATED_CURSOR_CONFIG.cursor_hotspot)
	Input.set_custom_mouse_cursor(sprite_frames.get_frame_texture("default", frame), Input.CURSOR_ARROW, ANIMATED_CURSOR_CONFIG.cursor_hotspot)
