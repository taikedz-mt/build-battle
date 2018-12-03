# Build Battle

Provide Build Battle environment on servers where there is no creative mode.

If you want to organize a  Build Batter on your non-creative server, this should help you.

The mod re-registers identical copies of nodes from the specified mods, but as `build_battle:*` nodes. These are not affected by the original ABMs, and can only be placed near a `build_battle:marker` node.

## Configuration

Edit the `depends.txt` file to specify which mods' nodes should be included in the build battle set

Adjust the Build Battle Marker radius by setting a `buildbattle.radius` config in minetest.conf -- by default, this is `7`

Use the `/bbsearch TERMS ...` command to find itemstrings - only itemstrings containing *all* the terms will be returned.

Give build battle moderators the `bbattle_moderator` and `give` privileges so that they can give players the blocks they need.

## Use

1. Prepare a Build Battle space by placing `build_battle:marker` blocks
2. Give contestants the blocks for building

That's it. Contestants will not be able to place the blocks far away from the markers, not derive items from the build battle nodes.

## Forceloading

Marker blocks cause the position they are located at to be forceloaded.

Without it, if you set a large radius (say, 30), your server may start unloading blocks when the player is away - if they're far away from the marker, it gets unloaded from memory - and the build_battle blocks can no longer be placed, as there apparently isn't any marker.

You can run `/bbattle_showfl` to see all the forceload locations set in this way, and `/bbattle_clearfl` to clear any that no longer have a marker block at the specified location.
