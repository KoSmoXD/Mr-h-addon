# Mr H addon

Requires full mspaint in a DOORS run. The repository must be public for anonymous Roblox downloads; private repositories return 404 without authentication.

1. Download `mr_h_loader.lua` and place it in your executor workspace's `mspaint/addons` folder.
2. Remove the previous full `mr_h_addon.lua` from that folder to avoid loading two copies.
3. Reload the addon. Each reload downloads `main/mr_h_addon.lua` with a cache-busting query.

Changes take effect only after they are committed to main and you reload. Network or GitHub errors are shown instead of silently running a stale copy. Do not put GitHub tokens in the loader.

Original feature code: tplaygd (user-supplied v2.4.0). Custom additions and integration: Mr H addon project. Source retains original attribution comments. Runtime features have not been verified in live Roblox.
