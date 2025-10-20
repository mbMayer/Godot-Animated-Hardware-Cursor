@tool
extends EditorPlugin
const AnimatedHardwareCursor = "res://addons/animated_hardware_cursor/AnimatedHardwareCursor.gd"
var cfg = preload("res://addons/animated_hardware_cursor/AnimatedCursorConfig.tres")

var vbox_container = VBoxContainer.new()
var fps_label = Label.new()
var fps_spin_box = SpinBox.new()
var hotspot_label = Label.new()
var hbox_hotspot_container_x = HBoxContainer.new()
var hbox_hotspot_container_y = HBoxContainer.new()
var vbox_hbox_hotspot_x_y = VBoxContainer.new()
var spinbox_x_label = Label.new()
var spinbox_hotspot_x = SpinBox.new()
var spinbox_y_label = Label.new()
var spinbox_hotspot_y = SpinBox.new()
var confirm_button = Button.new()
var cursor_spriteframes = SpriteFrames.new()
var cursor_preview_animated_sprite = AnimatedSprite2D.new()
var sprite_frames_label = Label.new()
var resoure_picker = EditorResourcePicker.new()
var sub_viewport_container = SubViewportContainer.new()
var sub_viewport = SubViewport.new()
var hotspot_gizmo = Sprite2D.new()
var credits_label = LinkButton.new()


func _enable_plugin() -> void:
	add_autoload_singleton("Animated_Hadrware_Cursor", AnimatedHardwareCursor)

func _disable_plugin() -> void:
	remove_autoload_singleton("Animated_Hadrware_Cursor")
	_remove_vbox()

func _init() -> void:
	vbox_container.name = "Animated Cursor"
	_add_vbox()

func _add_vbox():
	_preview()
	vbox_container.add_child(sub_viewport_container)
	sub_viewport_container.add_child(sub_viewport)
	sub_viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	sub_viewport_container.connect("gui_input", _change_hotspot)
	sub_viewport_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox_container.add_child(fps_label)
	fps_label.text = "Animation Speed"
	fps_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox_container.add_child(fps_spin_box)
	fps_spin_box.alignment = HORIZONTAL_ALIGNMENT_CENTER
	fps_spin_box.suffix = "fps"
	fps_spin_box.step = 0.1
	vbox_container.add_child(hotspot_label)
	hotspot_label.text = "Cursor HotSpot"
	hotspot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox_container.add_child(vbox_hbox_hotspot_x_y)
	vbox_hbox_hotspot_x_y.add_child(hbox_hotspot_container_x)
	vbox_hbox_hotspot_x_y.add_child(hbox_hotspot_container_y)
	hbox_hotspot_container_x.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox_hotspot_container_x.add_child(spinbox_x_label)
	spinbox_x_label.text = "x"
	spinbox_x_label.add_theme_color_override("font_color", Color(0.753, 0.184, 0.0, 1.0))
	hbox_hotspot_container_x.add_child(spinbox_hotspot_x)
	spinbox_hotspot_x.step = 0.1
	spinbox_hotspot_x.max_value = 256
	spinbox_hotspot_x.alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox_hotspot_container_y.add_child(spinbox_y_label)
	hbox_hotspot_container_y.add_child(spinbox_hotspot_y)
	spinbox_y_label.text = "y"
	spinbox_y_label.add_theme_color_override("font_color", Color(0.329, 0.714, 0.404, 1.0))
	spinbox_hotspot_y.step = 0.1
	spinbox_hotspot_y.max_value = 256
	spinbox_hotspot_y.alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox_hotspot_container_y.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox_container.add_child(sprite_frames_label)
	sprite_frames_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sprite_frames_label.text = "Cursor Resource"
	vbox_container.add_child(resoure_picker)
	resoure_picker.base_type = "SpriteFrames"
	vbox_container.add_child(confirm_button)
	confirm_button.text = "Confirm"
	var new_stylebox_normal = confirm_button.get_theme_stylebox("normal").duplicate()
	new_stylebox_normal.bg_color = Color(0.145, 0.169, 0.204, 1.0)
	var new_stylebox_hover = confirm_button.get_theme_stylebox("hover").duplicate()
	new_stylebox_hover.bg_color = Color(0.212, 0.227, 0.251, 1.0)
	confirm_button.add_theme_stylebox_override("normal", new_stylebox_normal)
	confirm_button.add_theme_stylebox_override("hover", new_stylebox_hover)
	confirm_button.add_theme_stylebox_override("pressed", new_stylebox_normal)
	confirm_button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	confirm_button.set_focus_mode(Control.FOCUS_CLICK)
	confirm_button.pressed.connect(_confirm_changes)
	vbox_container.add_spacer(false)
	vbox_container.add_child(credits_label)
	vbox_container.focus_mode = Control.FOCUS_CLICK
	credits_label.text = "by mbMayer"
	credits_label.uri = "https://github.com/mbMayer"
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_LEFT, vbox_container)

func _remove_vbox():
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_LEFT, vbox_container)

func _confirm_changes():
	cursor_spriteframes = resoure_picker.edited_resource
	var cursor_hotspot = Vector2(float(spinbox_hotspot_x.value), float(spinbox_hotspot_y.value))
	cfg.frames_per_second = float(fps_spin_box.value)
	cfg.cursor_hotspot = cursor_hotspot
	cfg.cursor_sprite_frames = cursor_spriteframes
	hotspot_gizmo.position = cursor_hotspot
	hotspot_gizmo.texture = cfg.CROSS_HAIR
	hotspot_gizmo.scale = Vector2(0.2, 0.2)
	ResourceSaver.save(cfg)
	_change_preview(cfg.cursor_sprite_frames, cfg.frames_per_second)

func _preview():
	cursor_preview_animated_sprite.centered = false
	cursor_preview_animated_sprite.set_sprite_frames(cfg.cursor_sprite_frames)
	cursor_preview_animated_sprite.play("default")
	cursor_preview_animated_sprite.speed_scale = 1.0
	sub_viewport.transparent_bg = true
	sub_viewport_container.custom_minimum_size = Vector2(256, 256)
	sub_viewport.size = Vector2(256, 256)
	sub_viewport.add_child(cursor_preview_animated_sprite)
	cursor_preview_animated_sprite.position = sub_viewport.size/2
	cursor_preview_animated_sprite.add_child(hotspot_gizmo)
	hotspot_gizmo.position = Vector2(64, 64)
	hotspot_gizmo.texture = cfg.CROSS_HAIR
	hotspot_gizmo.scale = Vector2(0.2, 0.2)
	

func _change_preview(texture, speed):
	cfg.cursor_sprite_frames.set_animation_speed("default", speed)
	cursor_preview_animated_sprite.sprite_frames = texture
	cursor_preview_animated_sprite.play("default")
	

func _change_hotspot(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var local_gizmo_pos = cursor_preview_animated_sprite.get_local_mouse_position()
			hotspot_gizmo.position = local_gizmo_pos
			spinbox_hotspot_x.value = local_gizmo_pos.x
			spinbox_hotspot_y.value = local_gizmo_pos.y
			
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
			cursor_preview_animated_sprite.scale += Vector2(0.1, 0.1)
			cursor_preview_animated_sprite.scale = clamp(cursor_preview_animated_sprite.scale, Vector2(0.1, 0.1), Vector2(5.0, 5.0))
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
			cursor_preview_animated_sprite.scale -= Vector2(0.1, 0.1)
			cursor_preview_animated_sprite.scale = clamp(cursor_preview_animated_sprite.scale, Vector2(0.1, 0.1), Vector2(5.0, 5.0))
