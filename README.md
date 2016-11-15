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
