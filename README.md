# Tower of Loki

## Assets
| Used on  | Link |
| ------------- | ------------- |
| Floor 3  | [Castle Tileset](https://alchymy.itch.io/castle-tileset)  |
| Home  | [FREE - Pixel Art Sidescroller Asset Pack 32x32 Overworld](https://gandalfhardcore.itch.io/free-pixel-art-sidescroller-asset-pack-32x32-overworld)  |


## Resource
| Name  | Link |
| ------------- | ------------- |
| Interaction Manager  | [Interact With Objects in Godot 4](https://youtu.be/ajCraxGAeYU?si=cjQu1_OCXZK1I8R4)  |
| Dialogue Manager  | [Using Dialogue Manager in Godot 4](https://youtu.be/Ydzj1bT_pC8?si=5SGU71texiEqLmg4)  |
| Customize Dialogue Manager Balloon  | [Custom dialogue balloons in Godot](https://youtu.be/Rd4bZEX2RCg?si=SdtGLMBuGELpLFRe)  |


## Plugin
| Name  | Link | License |
| ------------- | ------------- | ------------- |
| Dialogue Manager 3 | [nathanhoad/godot_dialogue_manager](https://github.com/nathanhoad/godot_dialogue_manager)  | [MIT](https://github.com/nathanhoad/godot_dialogue_manager?tab=MIT-1-ov-file)

## Folder Structure
```
└── 📁TrickTower                           ; Root
    └── 📁addons                             ; Plugin Folder
        └── 📁dialogue_manager               ; Dialogue manager 3 plugin
    └── 📁assets                             ; Assets Folder
        └── 📁fonts                          ; Font
        └── 📁sprites 
            └── 📁npcs
            └── 📁objects
            └── 📁player
        └── 📁tilesets
    └── 📁autoload
    └── 📁dialogue_balloon                   ; Custom Dialogue Balloon
    └── 📁interaction                        ; Interaction Manager
        └── 📁interaction area                 ; Interaction Area
    └── 📁scenes
        └── 📁characters
            └── 📁calliopi
            └── 📁player
        └── 📁floors
            └── 📁floor3                     ; Floor3 dialogue resource & scene
            └── 📁house                      ; House dialogue resource & scene
        └── 📁mainn
        └── 📁mechanics
            └── 📁ascension
            └── 📁common
            └── 📁floor1
```
## Guide
### Interaction Manager
1. Tambah node `InteractionArea` di scene yang mau diberi interact.
2. Define dimana dialogue resournya dan panggil `InteractionManager` di script object/spritnya.
#### Contoh
```
# Define InteractionArea
@onready var interaction_area: InteractionArea = $InteractionArea

# Panggil interaction manager dan beri command (Disini bakal manggil dialog di fungsi _on_interact)
func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
```

### Dialogue Manager
1. Isi/content dari dialognya bisa ditambah di folder content/resource. Filenya yang ada extension `.dialogue`
2. Buat foto/portrait di dialognya, ditaruh di folder `res://scenes/characters/[Nama Character dari dialogue resource]` dengan nama `portrait.png`.
3. Define dan panggil dialognya.
#### Contoh
```
# Define path dialogue resournya
var dialogue_resource = load("res://scenes/floors/floor3/floor3.dialogue")

# Panggil dialogoe manager
func _on_interact():
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
```
