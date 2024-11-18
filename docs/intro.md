---
sidebar_position: 1
---

# Installation

## Roblox - Easy loader ✅

1. Get the [Rorooms Loader](https://create.roblox.com/store/asset/131892669922226) model
2. Insert it from the Toolbox
3. Place into `ReplicatedStorage`
4. [Start configuring!](/docs/easy-loader)

## Roblox - Custom 🔧

1. Download the `Rorooms.rbxm` file [listed here](https://github.com/Rorooms/Rorooms/releases/latest/)
2. Insert `Rorooms.rbxm` into `ReplicatedStorage`
3. Require `ReplicatedStorage.Rorooms`
4. Call `Rorooms:Start()` from both the server and client
5. Reference the [API pages](/api)

## Wally 🐶

1. Copy the [Wally details](https://wally.run/package/rorooms/rorooms)
2. Paste it into your `wally.toml` dependencies
3. Run `wally install`

# Game Settings

For Rorooms to properly function, you need to enable a few Security settings within your Game Settings. This allows Rorooms to access the APIs its features rely on.

![Security walkthrough](/docs/Security.png)