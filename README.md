# Cereal game

A small 2D grid-based game built with Godot. Work in progress.

## Requirements

- Godot 4.7
- Git LFS (art and audio source files are stored with LFS, run `git lfs install` once before cloning)

## Run

1. Open `project.godot` in Godot 4.7.
2. Press F5 to run the main scene.

### Controls

| Action | Keys |
|---|---|
| Move | WASD or arrow keys |
| Restart | R or Enter |

## Tests

Unit tests use [GUT](https://github.com/bitwes/Gut) and live in `test/unit/`.
Open the GUT panel at the bottom of the editor and run them from there.

## Project layout

```
addons/   third-party plugins (GUT)
src/      game scenes and scripts
test/     unit tests
```

## Credits

Third-party software and assets are listed in [CREDITS.md](CREDITS.md).
