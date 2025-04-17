@tool
extends EditorPlugin

const BitmaskAutomation = preload("res://addons/bitmask_automation/context_menu.gd")
var plugin: BitmapAutomationContextMenuPlugin

func _enter_tree() -> void:
	plugin = BitmaskAutomation.new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, plugin)

func _exit_tree() -> void:
	remove_context_menu_plugin(plugin)
