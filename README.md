# Automated-Terrain-Bitmasks

An extremely rough proof of concept for generating terrain bitmasks autmatically from a template png image.

Roadmap

Bugs:

- [ ] Make sure the tilemap template ui listens for updates to the tilemap. specifically source changes. update lists / uis so it's not stale
- [ ] use godot file picker instead of native

Features:

- [ ] add tool to save the current bitmaps to an image
- [ ] add ui to remap colors in the image to specific terrains from the tilemap
- [ ] have the tool auto select a template image based on file paths. if a source is res://source.png and a res://source.template.png exists, preselect it for the ui, and default to that for saving templates
- [ ] add default templates for simple 2x2 and 3x3 with ui to support

## Usage

The terrain template is currently loaded from addons/tilemap_templates/terrain-tilemap-template.png

Select a TileMapLayer in the node editor and choose "Terrain Templates" in the bottom menu.

Pick the source you want to apply the template to and then click apply.

![image](https://github.com/user-attachments/assets/5835c492-0145-4f40-b9fd-ddc0eda2920b)
