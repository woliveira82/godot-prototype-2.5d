# Godot Action Dungeon Crawler Prototype

A gameplay prototype built with **Godot 4.6** focusing on real-time action combat and core systems validation.

**Author:** Weiner Oliveira — https://github.com/woliveira82  
**License:** MIT (code only)

---

## Overview

This project is a gameplay prototype built with **Godot 4.6**, featuring:

- 3D gameplay space
- 2D animated sprite characters
- Isometric camera
- Real-time action combat

The current focus is on validating combat mechanics, enemy interactions, and core gameplay systems before expanding into content production.

---

## Features

### Player

- CharacterBody3D controller
- 4-direction movement
- 4-direction idle and walk animations
- Melee attacks
- Knockback reactions
- Temporary invulnerability (i-frames)
- Health system
- HUD health bar
- Camera follow system

### Combat

- Hitbox / Hurtbox architecture
- Animation-driven attacks
- Contact damage
- Knockback effects
- Damage feedback
- Death handling

### Enemies

- Basic chase AI
- Contact damage
- Hurtbox support
- Knockback when hit
- Death state

### World

- Basic prototype map
- CSG-based level blockout
- Enemy spawning system
- Isometric camera setup

---

## Current Architecture

```text
Player
├── Movement
├── State Machine
├── Animation
├── Health
├── Hitbox
└── Hurtbox

Enemy
├── AI
├── Health
├── Hitbox
└── Hurtbox

Combat
├── Damage
├── Knockback
└── Invulnerability Frames

HUD
└── Health Display