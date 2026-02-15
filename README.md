# The Equalizer

The Equalizer is a top-down action-puzzle game focused on evasion, timing, and level navigation. The player must avoid enemies, collect speed upgrades, and reach the goal diamond to complete each level.

## Gameplay Overview

- Top-down 2D camera with smooth scrolling
- Mouse-based movement toward the cursor
- Enemies act as moving obstacles
- Instant failure on enemy contact
- Speed increases by collecting items
- One clear objective per level: reach the diamond

## Controls

- Mouse Click / Hold: Move toward cursor
- P: Pause the game
- SPACE: Resume from pause
- Q: Quit game (from pause)
- Mouse Click (Menus): Start game / advance levels

## Game States

- Start Screen
- Playing
- Paused
- Level Complete
- Game Finished

## Level System

- Levels are loaded from CSV map files
- Tile-based world layout
- Each tile defines walls, player spawn, enemies, items, or goal
- Game ends after completing all available levels

## Core Mechanics

- Collision-based movement with wall blocking
- Enemy movement with direction changes on collision
- Item pickups increase player speed
- Camera follows the player smoothly within map bounds

## Technologies Used

- Processing (Java mode)
- Processing Sound library
- CSV-based level design
- Sprite-based animation

## Assets

- Sprites and images are loaded dynamically
- Missing assets fall back to simple geometric shapes
- Background music changes per level if available

## Status

Prototype / early version  
More levels and content can be added by extending map files and assets.

## Coming soon
- Hidden mines and a gadget that lets the player see the mines
- Chasing guards (using manhattan distance calculations)
- Laser beams (moving or on/off type)
- Dusk mode where only steps of enemies can be detected and a limited field of view
- Moving walls

## Notes
- Currently the music and the sprites are mostly borrowed from Hotline Miami video game
