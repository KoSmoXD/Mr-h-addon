-- Install ONLY this file in mspaint/addons; remove the old full mr_h_addon.lua.
-- Requires the GitHub repository to be public. Full mspaint is required.
local url = "https://raw.githubusercontent.com/KoSmoXD/Mr-h-addon/main/mr_h_addon.lua"
local ok, source = pcall(function()
    return game:HttpGet(url .. "?reload=" .. game:GetService("HttpService"):GenerateGUID(false))
end)
if not ok or type(source) ~= "string" then
    error("Mr H addon: download failed. Check your connection and that KoSmoXD/Mr-h-addon is public. " .. tostring(source))
end
local chunk, err = loadstring(source, "@MrHAddon/GitHub")
if not chunk then error("Mr H addon: downloaded source could not compile: " .. tostring(err)) end
-- Keep the addon environment supplied by mspaint.
if setfenv and getfenv then setfenv(chunk, getfenv(1)) end
return chunk()
