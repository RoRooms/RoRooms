---
sidebar_position: 2
---

# Easy Loader

Easily load and configure RoRooms without ever touching a line of code! Instead, use Roblox instances and attributes.

![alt text](image.png)

# Items 🔧

Items are `Tool` objects, and go under `Config.Items`.

| Attribute          | Type     | Optional |
| ------------------ | -------- | -------- |
| `ItemId`           | `string` | ❌        |
| `Tool`             | `Tool`   | ❌        |
| `DisplayName`      | `string` | ✅        |
| `LevelRequirement` | `number` | ✅        |
| `Category`         | `string` | ✅        |
| `Color`            | `Color3` | ✅        |
| `LabelText`        | `string` | ✅        |
| `LabelIcon`        | `string` | ✅        |

# Emotes 💃

Emotes are `Animation` objects, and go under `Config.Emotes`.

| Attribute          | Type        | Optional |
| ------------------ | ----------- | -------- |
| `ItemId`           | `string`    | ❌        |
| `Animation`        | `Animation` | ❌        |
| `Emoji`            | `string`    | ✅        |
| `DisplayName`      | `string`    | ✅        |
| `LevelRequirement` | `number`    | ✅        |
| `Category`         | `string`    | ✅        |
| `Color`            | `Color3`    | ✅        |
| `LabelText`        | `string`    | ✅        |
| `LabelIcon`        | `string`    | ✅        |

# Music 🎶

Simply drop `Sound` instances into your `Config.Music` folder!

![alt text](image-1.png)

# Worlds 🌐

## Disabling discovery

You may not want to participate in RoRooms' worlds network, and that choice is supported. Understand that by doing this, your world will not receive support from any other worlds.

1. Open the Config module

![alt text](image-2.png)

2. Type this in:

![alt text](image-4.png)

3. Additionally, you can set `Enabled = false` to disable the worlds menu entirely. Otherwise, you can still promote your own worlds by pasting their PlaceIds into `FeaturedWorlds`.