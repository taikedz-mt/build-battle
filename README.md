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

## Settings

* `buildbattle.radius` - How far from the marker Build Battle blocks can be placed, default `16`
* `buildbattle.mods` - Mods to includein build battle. You also need to add these to the `depends.txt` of the mod so that they are loaded before Build Battle itself
    * `default,butterflies,flowers,bones,beds,doors,fire,farming,stairs,farming,stairs,vessels,walls,wool,xpanes`
* `buildbattle.forbidden` - Nodes that cannot be cloned, ever
* `buildbattle.report_registration_failures` - whether to report registration failures to the log
* `buildbattle.allow_hidden_inventory` - Items normally marked as `not_in_creative_inventory` are cloned to inventory items for BUild Battle

## Forceloading

Marker blocks cause the position they are located at to be forceloaded when the radius is larger than 32.

Without it, if you set a large radius (say, 40), your server may start unloading blocks when the player is away - if they're far away from the marker, it gets unloaded from memory - and the `build_battle` blocks can no longer be placed, as no marker can be found by the check function.

You can run `/bbattle_showfl` to see all the forceload locations set in this way, and `/bbattle_clearfl` to clear any that no longer have a marker block at the specified location.
