# Cereal game

A Xonix-style arcade game built with Godot 4 and GDScript. You draw trails across open sea to claim land while enemies bounce around and try to cut your trail. Work in progress.

<!-- Add a screenshot or GIF here once recorded, for example: ![Gameplay](docs/gameplay.gif) -->

I built it to learn Godot and to practice keeping game code small, testable and easy to change. The game rules are kept separate from rendering, so the same rules can later drive a 3D view.

## How to play

- Walk freely on land. Step into the sea to start drawing a trail.
- Close the trail by returning to land. Every patch of sea that no enemy can reach is claimed as new land.
- If an enemy hits your trail, the trail burns outward from the hit point in both directions. Reach land before the fire reaches you, or you lose a life.
- Press Space while drawing to open a short parry window. A parried hit bounces the enemy away instead of setting the trail on fire. You get one parry per trip into the sea, and the player and trail change color while the window is open.
- Claim 75% of the land to win. You have 3 lives. Both values can be changed in the Inspector on the main scene.

### Controls

| Action | Keys |
|---|---|
| Move | WASD or arrow keys |
| Parry | Space (while drawing a trail) |
| Switch color palette | Tab |
| Restart | R or Enter |

## Run

Requires Godot 4.7 (the standard build is enough).

1. Clone the repository.
2. Open `project.godot` in Godot 4.7.
3. Press F5 to run the main scene.

## Tests

Unit tests use [GUT](https://github.com/bitwes/Gut) and live in `test/unit/`. They currently cover `GridData`: index math, claiming land with flood fill, and change signals.
Open the GUT panel at the bottom of the editor and run them from there.

## Code structure

```
addons/gut/   GUT test framework (third-party)
src/actors/   GridActor base class, player (with Parry), enemy
src/hud/      HUD scene and labels
src/main/     main scene: game loop and wiring
src/map/      GridData, Map, MapView, Trail
src/palette/  Palette resource and the three color sets
test/unit/    GUT unit tests
```

Design notes:

- **Data first.** `GridData` stores the board as one flat `PackedByteArray` and owns the grid rules, such as the flood fill that claims land. It has no nodes and no rendering, which is what makes it easy to unit test.
- **Rules and view are separate.** `Map` applies the game rules. `MapView` only draws, and it redraws when `GridData` emits `cell_changed`. A 3D view should be able to replace `MapView` without touching the rules.
- **Fixed-step actors.** `GridActor` moves in whole-cell steps from a fixed-rate accumulator in `_physics_process` and interpolates the sprite in `_process`, so movement stays smooth at any refresh rate. The player and enemies share this base class.
- **Small, testable helpers.** `Trail` (burning logic) and `Parry` (window and charges) are plain `RefCounted` classes. `Parry` receives the current time as an argument instead of reading a clock.
- **Call down, signal up.** `Main` wires the scenes together through exported node references and signals. Child nodes do not reach into their parents.
- **Palettes are resources.** Each color set is a `Palette` resource, switched at runtime.

## Roadmap

- 3D visuals driven by the same grid rules: raised land, slopes where land meets sea, animated waves.
- More unit tests, starting with `Trail` and `Parry`.
- Exported builds for people without Godot.

## License

The source code is released under the [PolyForm Noncommercial License 1.0.0](LICENSE). You may use, study, change and share it for noncommercial purposes. Commercial use, including selling the game or a game derived from this code, requires permission from the author. Prospective employers and clients are welcome to read, build and run this project to evaluate my work.

Third-party software and assets keep their own licenses and are listed in [CREDITS.md](CREDITS.md). For example, the GUT addon in `addons/gut/` is MIT licensed (see `addons/gut/LICENSE.md`).
