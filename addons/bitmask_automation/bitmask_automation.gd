@tool
extends EditorPlugin

const BitMaskAutomation = preload("res://addons/bitmask_automation/context_menu.gd")
var plugin: BitMaskAutomation

func _enter_tree() -> void:
	plugin = BitMaskAutomation.new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, plugin)

func _exit_tree() -> void:
	remove_context_menu_plugin(plugin)
